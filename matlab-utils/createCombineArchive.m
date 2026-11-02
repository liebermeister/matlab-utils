function omexFile = createCombineArchive(omexFile, meta, files, opts)
%CREATECOMBINEARCHIVE Build a COMBINE archive (.omex) with manifest and OMEX metadata.
%
%   omexFile = createCombineArchive(omexFile, meta, files)
%   omexFile = createCombineArchive(omexFile, meta, files, Name, Value, ...)
%
%   Creates a ZIP-based COMBINE archive containing manifest.xml (COMBINE
%   Archive 1.0) and metadata.rdf (OMEX Metadata 1.2, RDF/XML). Files are
%   copied into one subfolder per field of FILES.
%
%   INPUTS
%   omexFile  Output path. The extension is forced to .omex. The file name
%             (without extension) is used in the metadata URIs
%             http://omex-library.org/<name>.omex/...
%
%   meta      Struct with archive-level metadata.
%             Required:
%               .title        char/string
%               .description  char/string
%               .creators     struct array with fields
%                               .name   (required)
%                               .orcid  (optional, e.g. '0000-0002-1825-0097')
%                               .email  (optional)
%             Optional:
%               .contributors struct array, same fields as creators
%               .created      datetime or ISO 8601 char (default: now)
%               .license      URL, e.g. 'https://creativecommons.org/licenses/by/4.0/'
%               .taxon        NCBI Taxonomy ID, numeric or char (e.g. 511145)
%               .citations    cellstr of DOIs ('10.1038/...') or identifiers
%                             ('pubmed:12345') or full URIs
%               .modelIds     cellstr of identifiers for the (first) SBML model,
%                             e.g. {'bigg.model:iML1515'}
%
%   files     Struct; each field is a folder name in the archive and holds a
%             cellstr/string array of source file paths. Standard fields:
%             .model, .simulation, .code, .results, .figures
%             Other field names are allowed (letters, digits, _ and -).
%             Empty fields are skipped. Subfolders are flattened: only the
%             file name is kept, so file names within a folder must be unique.
%
%   NAME-VALUE OPTIONS
%   'Master'       Archive path or file name of the master file
%                  (default: first SED-ML file, otherwise first SBML file).
%   'Descriptions' N-by-2 cell: {fileNameOrArchivePath, description; ...}.
%                  Written as dc:description for each file in metadata.rdf.
%   'Overwrite'    Overwrite an existing archive (default false).
%   'KeepStaging'  Keep the temporary staging folder for inspection
%                  (default false).
%
%   EXAMPLE
%   meta.title       = 'FBA and FVA of iML1515 under glucose limitation';
%   meta.description = ['FBA/FVA with COBRA Toolbox 3.x, MATLAB R2024b, ' ...
%                       'Gurobi 11. Units: mmol/gDW/h.'];
%   meta.creators    = struct('name', 'Jane Doe', ...
%                             'orcid', '0000-0002-1825-0097', ...
%                             'email', 'jane.doe@example.org');
%   meta.license     = 'https://creativecommons.org/licenses/by/4.0/';
%   meta.taxon       = 511145;
%   meta.citations   = {'10.1038/nbt.3956'};
%   meta.modelIds    = {'bigg.model:iML1515'};
%
%   files.model      = {'out/iML1515.xml'};
%   files.simulation = {'out/fba.sedml'};
%   files.code       = {'run_analysis.m', 'README.md'};
%   files.results    = {'out/fluxes.csv', 'out/fva.csv'};
%   files.figures    = {'out/flux_map.png'};
%
%   desc = {'fluxes.csv', 'Optimal fluxes; columns are SBML reaction IDs'; ...
%           'fva.csv',    'FVA minimum and maximum per reaction'};
%
%   createCombineArchive('results/iML1515_fba.omex', meta, files, ...
%                        'Descriptions', desc, 'Overwrite', true);
%
%   Requires MATLAB R2019b or later (arguments block).

arguments
    omexFile            {mustBeTextScalar}
    meta          (1,1) struct
    files         (1,1) struct
    opts.Master         {mustBeTextScalar} = ''
    opts.Descriptions   cell = cell(0, 2)
    opts.Overwrite (1,1) logical = false
    opts.KeepStaging (1,1) logical = false
end

omexFile = char(omexFile);

% ---- output path ---------------------------------------------------------
[outDir, archName, ~] = fileparts(omexFile);
if isempty(outDir)
    outDir = pwd;
end
if ~isfolder(outDir)
    mkdir(outDir);
end
omexFile = fullfile(outDir, [archName '.omex']);
if isfile(omexFile) && ~opts.Overwrite
    error('createCombineArchive:exists', ...
        'File %s exists. Use ''Overwrite'', true to replace it.', omexFile);
end
baseURI = ['http://omex-library.org/' archName '.omex'];

% ---- metadata checks -----------------------------------------------------
for req = {'title', 'description', 'creators'}
    if ~isfield(meta, req{1}) || isempty(meta.(req{1}))
        error('createCombineArchive:meta', 'meta.%s is required.', req{1});
    end
end
checkPersons(meta.creators, 'creators');
if isfield(meta, 'contributors') && ~isempty(meta.contributors)
    checkPersons(meta.contributors, 'contributors');
end
if size(opts.Descriptions, 2) ~= 2 && ~isempty(opts.Descriptions)
    error('createCombineArchive:desc', 'Descriptions must be an N-by-2 cell array.');
end

% ---- staging folder ------------------------------------------------------
staging = tempname;
mkdir(staging);
cleanup = onCleanup(@() removeStaging(staging, opts.KeepStaging)); %#ok<NASGU>

entries = struct('location', {}, 'format', {});
folders = fieldnames(files);
for i = 1:numel(folders)
    f = folders{i};
    if isempty(regexp(f, '^[A-Za-z0-9_\-]+$', 'once'))
        error('createCombineArchive:folder', 'Invalid folder name "%s".', f);
    end
    list = files.(f);
    if isempty(list)
        continue
    end
    list = cellstr(list);
    mkdir(fullfile(staging, f));
    for j = 1:numel(list)
        src = list{j};
        if ~isfile(src)
            error('createCombineArchive:missing', 'File not found: %s', src);
        end
        [~, n, e] = fileparts(src);
        loc = [f '/' n e];
        if any(strcmp({entries.location}, loc))
            error('createCombineArchive:duplicate', ...
                'Duplicate file name in folder %s: %s', f, [n e]);
        end
        copyfile(src, fullfile(staging, f, [n e]));
        entries(end+1) = struct('location', loc, 'format', detectFormat(src)); %#ok<AGROW>
    end
end
if isempty(entries)
    error('createCombineArchive:empty', 'No files given.');
end

% ---- master file ---------------------------------------------------------
fmtSedml = 'http://identifiers.org/combine.specifications/sed-ml';
fmtSbml  = 'http://identifiers.org/combine.specifications/sbml';
if isempty(char(opts.Master))
    masterIdx = find(strcmp({entries.format}, fmtSedml), 1);
    if isempty(masterIdx)
        masterIdx = find(startsWith({entries.format}, fmtSbml), 1);
    end
else
    masterIdx = findEntry(entries, char(opts.Master));
end

% ---- file descriptions ---------------------------------------------------
fileDesc = repmat({''}, 1, numel(entries));
for k = 1:size(opts.Descriptions, 1)
    idx = findEntry(entries, char(opts.Descriptions{k, 1}));
    fileDesc{idx} = char(opts.Descriptions{k, 2});
end

% ---- write manifest and metadata -----------------------------------------
writeManifest(fullfile(staging, 'manifest.xml'), entries, masterIdx);
writeMetadata(fullfile(staging, 'metadata.rdf'), meta, entries, fileDesc, baseURI);

% ---- zip -----------------------------------------------------------------
relList = [{'manifest.xml', 'metadata.rdf'}, ...
           strrep({entries.location}, '/', filesep)];
tmpZip = [tempname '.zip'];
zip(tmpZip, relList, staging);
movefile(tmpZip, omexFile, 'f');

fprintf('COMBINE archive written: %s (%d files)\n', omexFile, numel(entries));
end

% =========================================================================
function idx = findEntry(entries, name)
% Match by archive path ('results/x.csv') or by file name ('x.csv').
name = strrep(name, '\', '/');
name = regexprep(name, '^\./', '');
locs = {entries.location};
idx = find(strcmp(locs, name));
if isempty(idx)
    [~, n, e] = fileparts(name);
    base = cellfun(@baseName, locs, 'UniformOutput', false);
    idx = find(strcmp(base, [n e]));
end
if isempty(idx)
    error('createCombineArchive:notFound', 'No file in the archive matches "%s".', name);
elseif numel(idx) > 1
    error('createCombineArchive:ambiguous', ...
        '"%s" matches several files; use the archive path (folder/file).', name);
end
end

function b = baseName(p)
[~, n, e] = fileparts(p);
b = [n e];
end

% =========================================================================
function fmt = detectFormat(src)
spec = 'http://identifiers.org/combine.specifications/';
mt   = 'http://purl.org/NET/mediatypes/';
[~, ~, e] = fileparts(src);
switch lower(e)
    case {'.xml', '.sbml'}
        hdr = readHeader(src);
        if contains(hdr, '<sbml')
            L = regexp(hdr, '<sbml[^>]*\slevel="(\d+)"', 'tokens', 'once');
            V = regexp(hdr, '<sbml[^>]*\sversion="(\d+)"', 'tokens', 'once');
            if ~isempty(L) && ~isempty(V)
                fmt = sprintf('%ssbml.level-%s.version-%s', spec, L{1}, V{1});
            else
                fmt = [spec 'sbml'];
            end
        elseif contains(hdr, '<sedML')
            fmt = [spec 'sed-ml'];
        elseif contains(hdr, 'cellml')
            fmt = [spec 'cellml'];
        else
            fmt = [mt 'application/xml'];
        end
    case '.sedml',          fmt = [spec 'sed-ml'];
    case '.cellml',         fmt = [spec 'cellml'];
    case '.m',              fmt = [mt 'text/x-matlab'];
    case '.mat',            fmt = [mt 'application/x-matlab-data'];
    case '.py',             fmt = [mt 'text/x-python'];
    case '.r',              fmt = [mt 'text/x-r'];
    case '.csv',            fmt = [mt 'text/csv'];
    case '.tsv',            fmt = [mt 'text/tab-separated-values'];
    case '.txt',            fmt = [mt 'text/plain'];
    case '.md',             fmt = [mt 'text/markdown'];
    case '.json',           fmt = [mt 'application/json'];
    case {'.h5', '.hdf5'},  fmt = [mt 'application/x-hdf5'];
    case '.xlsx',           fmt = [mt 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'];
    case '.png',            fmt = [mt 'image/png'];
    case {'.jpg', '.jpeg'}, fmt = [mt 'image/jpeg'];
    case '.svg',            fmt = [mt 'image/svg+xml'];
    case {'.tif', '.tiff'}, fmt = [mt 'image/tiff'];
    case '.pdf',            fmt = [mt 'application/pdf'];
    case '.zip',            fmt = [mt 'application/zip'];
    otherwise,              fmt = [mt 'application/octet-stream'];
end
end

function hdr = readHeader(src)
fid = fopen(src, 'r');
if fid < 0
    hdr = '';
    return
end
hdr = fread(fid, [1 4096], '*char');
fclose(fid);
end

% =========================================================================
function writeManifest(path, entries, masterIdx)
spec = 'http://identifiers.org/combine.specifications/';
L = {
    '<?xml version="1.0" encoding="UTF-8"?>'
    ['<omexManifest xmlns="' spec 'omex-manifest">']
    ['  <content location="." format="' spec 'omex"/>']
    ['  <content location="./manifest.xml" format="' spec 'omex-manifest"/>']
    ['  <content location="./metadata.rdf" format="' spec 'omex-metadata"/>']
    };
for k = 1:numel(entries)
    m = '';
    if ~isempty(masterIdx) && k == masterIdx
        m = ' master="true"';
    end
    L{end+1, 1} = sprintf('  <content location="./%s" format="%s"%s/>', ...
        xmlEsc(entries(k).location), xmlEsc(entries(k).format), m); %#ok<AGROW>
end
L{end+1, 1} = '</omexManifest>';
writeLines(path, L);
end

% =========================================================================
function writeMetadata(path, meta, entries, fileDesc, baseURI)
L = {
    '<?xml version="1.0" encoding="UTF-8"?>'
    '<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'
    '         xmlns:dc="http://purl.org/dc/terms/"'
    '         xmlns:foaf="http://xmlns.com/foaf/0.1/"'
    '         xmlns:bqmodel="http://biomodels.net/model-qualifiers/"'
    '         xmlns:bqbiol="http://biomodels.net/biology-qualifiers/">'
    ''
    ['  <rdf:Description rdf:about="' xmlEsc(baseURI) '">']
    ['    <dc:title>' xmlEsc(meta.title) '</dc:title>']
    ['    <dc:description>' xmlEsc(meta.description) '</dc:description>']
    };

L = [L; personRefs(meta.creators, 'dc:creator')];
if isfield(meta, 'contributors') && ~isempty(meta.contributors)
    L = [L; personRefs(meta.contributors, 'dc:contributor')];
end

nowStr = isoDate(datetime('now', 'TimeZone', 'local'));
if isfield(meta, 'created') && ~isempty(meta.created)
    created = isoDate(meta.created);
else
    created = nowStr;
end
L = [L; dateBlock('dc:created', created); dateBlock('dc:modified', nowStr)];

if isfield(meta, 'license') && ~isempty(meta.license)
    L{end+1, 1} = ['    <dc:license rdf:resource="' xmlEsc(meta.license) '"/>'];
end
if isfield(meta, 'taxon') && ~isempty(meta.taxon)
    t = meta.taxon;
    if isnumeric(t), t = num2str(t); end
    t = char(t);
    if ~startsWith(t, 'http')
        t = ['http://identifiers.org/taxonomy:' regexprep(t, '^(taxonomy|ncbitaxon):', '', 'ignorecase')];
    end
    L{end+1, 1} = ['    <bqbiol:hasTaxon rdf:resource="' xmlEsc(t) '"/>'];
end
if isfield(meta, 'citations') && ~isempty(meta.citations)
    c = cellstr(meta.citations);
    for k = 1:numel(c)
        L{end+1, 1} = ['    <bqmodel:isDescribedBy rdf:resource="' ...
            xmlEsc(idUri(c{k}, 'doi')) '"/>']; %#ok<AGROW>
    end
end
L{end+1, 1} = '  </rdf:Description>';

% person details (only for persons identified by ORCID)
persons = meta.creators(:);
if isfield(meta, 'contributors') && ~isempty(meta.contributors)
    persons = [persons; meta.contributors(:)];
end
for k = 1:numel(persons)
    p = persons(k);
    if hasValue(p, 'orcid')
        L{end+1, 1} = ''; %#ok<AGROW>
        L{end+1, 1} = ['  <rdf:Description rdf:about="' xmlEsc(orcidUri(p.orcid)) '">']; %#ok<AGROW>
        L = [L; personBody(p, '    ')]; %#ok<AGROW>
        L{end+1, 1} = '  </rdf:Description>'; %#ok<AGROW>
    end
end

% model identifiers -> first SBML file
sbmlIdx = find(startsWith({entries.format}, ...
    'http://identifiers.org/combine.specifications/sbml'), 1);
modelIds = {};
if isfield(meta, 'modelIds') && ~isempty(meta.modelIds)
    modelIds = cellstr(meta.modelIds);
    if isempty(sbmlIdx)
        warning('createCombineArchive:noSbml', ...
            'meta.modelIds given but no SBML file found; identifiers not written.');
        modelIds = {};
    end
end

% file-level descriptions
for k = 1:numel(entries)
    hasDesc = ~isempty(fileDesc{k});
    hasIds  = ~isempty(modelIds) && k == sbmlIdx;
    if ~hasDesc && ~hasIds
        continue
    end
    L{end+1, 1} = ''; %#ok<AGROW>
    L{end+1, 1} = ['  <rdf:Description rdf:about="' ...
        xmlEsc([baseURI '/' entries(k).location]) '">']; %#ok<AGROW>
    if hasDesc
        L{end+1, 1} = ['    <dc:description>' xmlEsc(fileDesc{k}) '</dc:description>']; %#ok<AGROW>
    end
    if hasIds
        for m = 1:numel(modelIds)
            L{end+1, 1} = ['    <bqmodel:is rdf:resource="' ...
                xmlEsc(idUri(modelIds{m}, '')) '"/>']; %#ok<AGROW>
        end
    end
    L{end+1, 1} = '  </rdf:Description>'; %#ok<AGROW>
end

L{end+1, 1} = '</rdf:RDF>';
writeLines(path, L);
end

% =========================================================================
function L = personRefs(persons, tag)
L = {};
for k = 1:numel(persons)
    p = persons(k);
    if hasValue(p, 'orcid')
        L{end+1, 1} = ['    <' tag ' rdf:resource="' xmlEsc(orcidUri(p.orcid)) '"/>']; %#ok<AGROW>
    else
        % blank node when no ORCID is available
        L{end+1, 1} = ['    <' tag '>']; %#ok<AGROW>
        L{end+1, 1} = '      <rdf:Description>'; %#ok<AGROW>
        L = [L; personBody(p, '        ')]; %#ok<AGROW>
        L{end+1, 1} = '      </rdf:Description>'; %#ok<AGROW>
        L{end+1, 1} = ['    </' tag '>']; %#ok<AGROW>
    end
end
end

function L = personBody(p, ind)
L = {[ind '<foaf:name>' xmlEsc(p.name) '</foaf:name>']};
if hasValue(p, 'email')
    L{end+1, 1} = [ind '<foaf:mbox rdf:resource="mailto:' xmlEsc(p.email) '"/>'];
end
end

function checkPersons(p, label)
if ~isstruct(p) || ~isfield(p, 'name')
    error('createCombineArchive:meta', ...
        'meta.%s must be a struct array with at least a "name" field.', label);
end
end

function tf = hasValue(s, field)
tf = isfield(s, field) && ~isempty(s.(field)) && strlength(string(s.(field))) > 0;
end

function u = orcidUri(o)
o = char(o);
if startsWith(o, 'http')
    u = o;
else
    u = ['https://orcid.org/' o];
end
end

function u = idUri(id, defaultPrefix)
% Full URI -> unchanged; 'prefix:accession' -> identifiers.org;
% bare value -> identifiers.org/<defaultPrefix>:<value>.
id = strtrim(char(id));
if startsWith(id, 'http')
    u = id;
elseif ~isempty(defaultPrefix) && startsWith(id, '10.')
    u = ['http://identifiers.org/' defaultPrefix ':' id];
elseif contains(id, ':')
    u = ['http://identifiers.org/' id];
elseif ~isempty(defaultPrefix)
    u = ['http://identifiers.org/' defaultPrefix ':' id];
else
    error('createCombineArchive:id', ...
        'Identifier "%s" needs a prefix, e.g. bigg.model:%s', id, id);
end
end

function L = dateBlock(tag, value)
L = {
    ['    <' tag ' rdf:parseType="Resource">']
    ['      <dc:W3CDTF>' xmlEsc(value) '</dc:W3CDTF>']
    ['    </' tag '>']
    };
end

function s = isoDate(d)
if isdatetime(d)
    if isempty(d.TimeZone)
        d.TimeZone = 'local';
    end
    d.Format = 'yyyy-MM-dd''T''HH:mm:ssxxx';
    s = char(d);
else
    s = char(d);
end
end

function s = xmlEsc(s)
s = char(string(s));
s = strrep(s, '&', '&amp;');
s = strrep(s, '<', '&lt;');
s = strrep(s, '>', '&gt;');
s = strrep(s, '"', '&quot;');
s = strrep(s, '''', '&apos;');
end

function writeLines(path, L)
fid = fopen(path, 'w', 'n', 'UTF-8');
if fid < 0
    error('createCombineArchive:write', 'Cannot write %s', path);
end
c = onCleanup(@() fclose(fid));
fprintf(fid, '%s\n', L{:});
end

function removeStaging(d, keep)
if keep
    fprintf('Staging folder kept: %s\n', d);
elseif isfolder(d)
    rmdir(d, 's');
end
end
