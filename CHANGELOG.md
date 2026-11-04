# Changelog

Version numbers have the form MAJOR.MINOR.PATCH. MAJOR changes when existing calls may stop working.

## Not released yet

- **New colour convention: diverging colormaps go from blue (negative values) via white to red (positive values)**; before, they went from red to blue. Changed: `rb_colors`, `rb_colors_dark`, `my_colors` (and `ryb_colors`), `rby_colors`, `sunrise_colors`. Figures made with these colormaps (e.g. network graphics of the Metabolic Network Toolbox) now show positive values in red. Code that used `flipud(rb_colors)` etc. to get blue for negative values now gets red for them, and should drop the `flipud`. For n = 1, `my_colors` and `sunrise_colors` return red (was: blue)
- `magma_colors`: sequential colormap 'magma' (values from matplotlib)
- `netgraph_find_x_old` removed: it is now part of mnt (as a private function). **Needs mnt with `netgraph_initial_positions`** (later than 1.3.0); older mnt versions call `netgraph_find_x_old` in `netgraph_make_graph`
- `createCombineArchive`: build a COMBINE archive (.omex) with manifest and OMEX metadata
- `multiple_testing_fdr` (moved here from the STM toolbox): Benjamini-Hochberg procedure; the previous version had about twice the nominal false discovery rate
- `convex_sampling_hit_and_run`: end points computed analytically (no linear programs in each step); new optional argument `verbose`

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
- Added `axis_almost_tight_positive`, `axis_tight_positive`, `blue_black_red_colors`, `color_scale_blue`, `color_scale_grey`, `roundsd`, `sort_by_clustering` and `zero_to_nan`, which other packages need

The state before the cleanup of October 2026 is available under the git tag `v0.9-legacy`.
