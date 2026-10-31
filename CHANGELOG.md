# Changelog

Version numbers have the form MAJOR.MINOR.PATCH. MAJOR changes when existing calls may stop working.

## 1.0.0 (2026-10-31)

First numbered version.

- Version function `matlab_utils_version`
- `package_version_check`: compare installed packages with required versions
- Convex sampling helpers, `qp_solve`, optional Gurobi support in `lp_solve` and `qp_solve`
- Tests and README
- `network_derivative` moved to the Metabolic Network Toolbox
- Added `my_lp_one_norm`, `bayesian_linear_model`, `wheelchart`, `scale_to_centre`, `logNormal_to_Normal`, `make_symmetric` and `save_matlab_structure_to_tsv`, which other packages need
- `dependencies_check_once`: runs a package's dependency check once per Matlab session; `package_version_check` also warns if a package has a newer major version than required
- `annotate_list` moved to SBtab for Matlab

The state before the cleanup of October 2026 is available under the git tag `v0.9-legacy`.
