Matlab utility functions
========================

General-purpose Matlab functions used by my other packages, for example the
[Metabolic Network Toolbox](https://github.com/liebermeister/metabolic-network-toolbox)
and [SBtab for Matlab](https://github.com/wolframliebermeister/sbtab-matlab).

## Installation

Download or clone the repository and add the `matlab-utils` folder to your Matlab path:

```matlab
addpath('/path/to/matlab-utils/matlab-utils');
savepath;   % optional: keep the folder on the path in future sessions
```

## Requirements

- Matlab (tested with R2025b)
- Optimization Toolbox, for the functions that solve linear and quadratic programs
  (`lp_solve`, `qp_solve`, `convex_sampling`, `find_polytope_centre`, ...).
- Optional: [Gurobi](https://www.gurobi.com) (free academic licenses). By default,
  `lp_solve` and `qp_solve` use `linprog` and `quadprog`; after `optim_solver('gurobi')`
  they use Gurobi (the choice is stored as a Matlab preference). This requires the
  Gurobi Matlab interface (folder `matlab` in the Gurobi installation) on the Matlab path.

A few functions call functions from other packages:

| Function                   | Requires |
|----------------------------|----------|
| `annotate_list`            | [SBtab for Matlab](https://github.com/wolframliebermeister/sbtab-matlab) |
| `network_derivative`       | [Metabolic Network Toolbox](https://github.com/liebermeister/metabolic-network-toolbox) |
| `find_metabolites_by_name` | `kegg_name2id` (not publicly available) |

## Contents

**Sampling and linear programming**
`convex_sampling` (uniform sampling in a convex polytope; rejection, extreme-point and
hit-and-run methods), `convex_sampling_rejection_no_eq`, `convex_sampling_extreme_points`,
`convex_sampling_hit_and_run`, `find_polytope_centre`, `find_polytope_centre_randn`,
`lp_solve` and `qp_solve` (wrappers around `linprog` and `quadprog`, optionally using Gurobi),
`optim_solver` (choose the solver for `lp_solve` and `qp_solve`)

**Random numbers and statistics**
`rand_power_law`, `rand_power_law_gaussian`, `rand_given_pdf`, `lognormal_normal2log`,
`lognormal_log2normal`, `lognormal_standard_convention`, `my_corrcoef`, `nanquantile`,
`histogram_fit`, `pca_simple`, `multidimensional_scaling`, `guess_flux_std`

**Matrices and tensors**
`blockrep`, `choose_independent_rows`, `chop`, `column`, `matrix_add_block`,
`matrix_find_blocks`, `tensor_product`, `tensor_scale`, `bit_vector`, `int_to_boolean`

**Strings and names**
`break_names`, `cell_string2num`, `escape_underscores`, `label_names`, `num2cellstr`,
`numbered_names`, `numbered_names_simple`, `Strsplit`, `print_matrix`, `pm`

**Files and tables**
`load_any_table`, `load_file_as_strings`, `load_unformatted_table`, `load_options_table`,
`save_options_table`, `annotate_list`, `mytable`

**Graphics and colours**
`arc`, `circle`, `plot_square`, `plot_range`, `dot_matrix`, `im`, `my_feather`,
`make_colorbar`, `my_colorbar`, `noticks`, `my_xticklabel`, `sfigure`, `subplot_n`,
`line_colors`, `get_color`, `my_colors`, `rb_colors`, `rb_colors_dark`, `rby_colors`,
`ryb_colors`, `sunrise_colors`, `colormapRGBmatrices`, `movie_save`, `listbox`

**Graphs and networks**
`graph_shortest_path`, `graph_circle_plot`, `netgraph_find_x_old`, `network_derivative`,
`numerical_elasticities`, `choose_period`, `find_metabolites_by_name`

**Other**
`default` (default values for function arguments), `join_struct`, `ca`, `my_spectrum`,
`matlab_utils_installed`

Type `help <function name>` in Matlab for details on a function.

## Tests

From the repository folder, run

```matlab
results = runtests('tests')
```

## Versions

To see the installed version, type `matlab_utils_version`. Older versions can be downloaded from the [releases page](https://github.com/liebermeister/matlab-utils/releases) of this repository, and changes between versions are listed in `CHANGELOG.md`.

## License
This package is released under the [GNU General Public License](LICENSE), version 2 or later.

## Contact
Please contact [Wolfram Liebermeister](mailto:wolfram.liebermeister@gmail.com) with any questions or comments.
