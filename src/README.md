# Hidden state prediction on the OTL Eukaryota tree and subtrees

**Foreword:** You need to setup the project first using the shell script `code/build_data.sh`.

## File structure

We use the R package `klmr/modules` to split the code into separate entities. Refer to the documentation for usage. One thing that bothers me after some time using it is the need to `reload` modules after they've been edited, and the fact that it is harder to plug a debugger (in fact I did not manage to). Modules are simply separated environment that don't leak implementation details (see the "Dependency Injection" pattern).

The path given are all relative to the root of the project, not to the `src/` folder (even if this file lies in it).

### Utilities

Inside the `src/common` folder you can find the following utilities that are used in more than one main script:

  * `config.R` allow you to specify all the parameters of your run ; you need to create this file following the template in `config-example.R`
  * `tree-utils.R` contains a set of utilities to work with Phylo trees using `castor`
  * `plot-utils.R` contains the main utilities to produce plots and save them to the disk (by default inside `output/`)
  * `evaluation-utils.R` contains the utilities to run an HSP evaluation on a given (set of) tree(s)
  * `utils.R` only contains a function to install package only if not already installed and to export the data as a `.Rdata` object with a filename derived from the parameters in `config.R`


### Main scripts

There are three main scripts that can be found inside `src/`:

  * `cross-evaluation.R` let you run the cross evaluation,
  * `simulation.R` let you run the simulation (this is a not-really-working-yet WIP),
  * `analysis.R` let you analyse your data.

## Cross evaluation

The cross evalution is meant to be run on a robust machine (or to be run by a very patient person).

It is done by loading the tree from a file and a set of interactions (we load once the set of interactions and save it to a `feather` file which is supposed to be faster - still takes a long time).

Clades are extracted first, then the known states for each of the extracted clades (using functions defined in `src/cross-evaluation/interaction-utils.R`).

For each clade a leave-N-out cross-evaluation is executed: N% of the known states is dropped, the HSP algorithm is run, and the resulting states are compared with the known dropped states (with a replication for every drop percentage).

We make use (we could make better use of it though) of the `parallel` package to run every HSP execution in parallel.

Output filenames from cross evaluation start with `.evaluation?` and are placed accordingly to your `config.R`.

Related options inside `config.R`:

 * `full_tree_path`: where to load the tree from,
 * `interaction_tree_path`: where to load the interaction set from,
 * `clade_otts`: which clades must be extracted from the whole tree prior to the run,
 * `evaluations`: a list of the following parameters:
  * `from_percentage_dropped`: lower bound of the drop percentage
  * `to_percentage_dropped`: upper bound of the drop percentage
  * `number_of_steps`: how many drop percentages between bounds to compute
  * `number_of_replications`: number of replication per drop percentage
  * `transition_costs`: apply a transition cost in the HSP algorithm
 * `output_path`: where to store the results

## Simulation

The simulation works (or is supposed to at one point) like follow:

  * Tree is loaded,
  * Clades are extracted
  * Clades are modeled (tree topology and multifurcation),
  * Simulated trees are generated for each clade,
  * Multifurcations are added to simulated trees,
  * State transition is modeled for each clade,
  * States are simulated for each clade,
  * Leave-N-out evaluation is run

Some part of the code is there, but the biggest problem we encounter is the resource consumption of the `castor::generate_random_tree` method.

Most of the code of interest lies in `src/simulation/simulation-utils.R`

Output filenames from simulation start with `.simulation?` and are placed accordingly to your `config.R`.

Parameters in `config.R` are for now the same as the ones for the cross evaluation.

## Analysis

Once cross evaluation or simulation is run, simply copy the corresponding `.Rdata` file from `output/` (or more precisely the path you set in `config.R` as `output_path`) to your local computer, `load` it and run the analysis you want to perform.

`plot-utils.R` contains a method to generate plots for every clade that has been evaluated, and save them using the same filename patterns as output filenames from cross evaluation and simulation. The type of file and their location on the computer can be changed in `config.R`.
