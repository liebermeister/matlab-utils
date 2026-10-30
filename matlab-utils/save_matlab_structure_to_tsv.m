function save_matlab_structure_to_tsv(structure, filename,delimiter)

  switch delimiter,
    case ',',  tflag='comma'; file_extension = 'csv';
    otherwise  tflag=0;       file_extension = 'tsv';
  end
  
%filename_TMP = [filename '_DIR']; 
filename_TMP = filename; 

if exist(filename_TMP) ~= 7,
  mkdir(filename_TMP)
end

fn = fieldnames(structure);

for it = 1:length(fn),
  if isnumeric(structure.(fn{it})(1)),
    structure.(fn{it}) = num2cell(structure.(fn{it}));
  end
  mytable(structure.(fn{it}), tflag, [filename_TMP '/' fn{it} '.' file_extension]);
end

zip([filename '.zip'],'*',filename_TMP);

%rmdir(filename_TMP,'s'); 

display(sprintf('Wrote matrix files to file %s.zip',filename));
