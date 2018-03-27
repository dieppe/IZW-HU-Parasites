"""Maximum parsimony algorithm from Sankoff implemented in the R package castor"""
import datetime
import sys

from rpy2 import rinterface, robjects
from Bio import Phylo
from termcolor import colored

from code.utilities.Helpers import print_time, read_nodelist_as_df


def r_print(x):
    print('R > ' + x, flush=True)


def main():
    CURRENT_TIME = datetime.datetime.now().replace(microsecond=0)
    subtree_name = sys.argv[1]

    rinterface.set_writeconsole_regular(r_print)

    print(
        colored(
            'RUN CASTOR WITH SANKOFF PARSIMONY FOR ' + subtree_name,
            'green'
        )
    )
    print(colored('- Read nodelist for ' + subtree_name, 'green'))
    nodelist_path = './data/nodelist/' + subtree_name + '.csv'
    nodelist = read_nodelist_as_df(nodelist_path)
    CURRENT_TIME = print_time(CURRENT_TIME)
    # print(nodelist.loc['ott5360923'])

    tree_path = './data/subtree/Eukaryota.tre'
    print(colored('- Read tree at ' + tree_path, 'green'))
    tree = Phylo.read(tree_path, 'newick')
    CURRENT_TIME = print_time(CURRENT_TIME)

    print(colored('- Prepare tagged tree', 'green'))
    tag_leaves(tree, nodelist)
    CURRENT_TIME = print_time(CURRENT_TIME)

    print(
        colored(
            '- Cache tagged tree to code/bufferfiles/tagged_tree.tre',
            'green'
        )
    )
    Phylo.write(tree, 'code/bufferfiles/tagged_tree.tre', 'newick')
    CURRENT_TIME = print_time(CURRENT_TIME)

    print(colored('- Running R code (Castor with Sankoff parsimony)', 'green'))
    run_R_code()
    CURRENT_TIME = print_time(CURRENT_TIME)

    print(colored('- Update nodelist with final tags', 'green'))
    update_nodelist_with_castor_results(nodelist)
    CURRENT_TIME = print_time(CURRENT_TIME)

    nodelist_path = './data/nodelist/' + subtree_name + '-castor.csv'
    print(colored('- Writing csv file to ' + nodelist_path, "green"))
    nodelist.to_csv(nodelist_path, index=False)
    CURRENT_TIME = print_time(CURRENT_TIME)
    return


R_PATH = "./code/utilities/castor_parsimony_simulation.R"


def run_R_code():
    global R_PATH
    with open(R_PATH, "r") as r_file:
        code = ''.join(r_file.readlines())
    robjects.r(code)


def update_nodelist_with_castor_results(nodelist):
    # The rows in this matrix will be in the order in which tips and
    # nodes are indexed in the tree, i.e. the rows 1,..,Ntips store the
    # probabilities for tips, while rows (Ntips+1),..,(Ntips+Nnodes) store the
    # probabilities for nodes.
    # ---
    # likelihoods is a RPy2 Matrix which can be accessed as follow:
    # likelihoods[row * (col+1)]
    # (so i in [0..nrow] is first column, i in [nrow+1..2*nrow] is second, ...)
    likelihoods = robjects.globalenv['likelihoods'][0]

    leaf_nodes = robjects.globalenv['state_ids']
    internal_nodes = robjects.globalenv['internal_nodes']

    number_of_states = likelihoods.ncol
    number_of_leaves = len(leaf_nodes)

    # We select the second column - parasites probability
    for index, leaf_ott in enumerate(leaf_nodes):
        likelihood_index = index * number_of_states
        if nodelist.at[leaf_ott, 'finaltag'] == '':
            nodelist.at[leaf_ott, 'finaltag'] = likelihoods[likelihood_index]

    for index, internal_ott in enumerate(internal_nodes):
        likelihood_index = (index + number_of_leaves) * number_of_states
        nodelist.at[internal_ott, 'finaltag'] = likelihoods[likelihood_index]
    return


# TODO why do we only tag leaves?
# Sankoff parsimony only uses leaves states
def tag_leaves(tree, nodelist):
    # Arguments:
    #   subtree
    #                   0    1              2       3       4           5
    # nodelist      - [id, originaltag, finaltag, depth, heights, nr_children]
    leaves = tree.get_terminals()
    for leaf in leaves:
        leaf.name = str(nodelist.at[leaf.name, 'originaltag'])
    return


main()
