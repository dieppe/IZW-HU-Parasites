import sys
from copy import deepcopy
import datetime
from code.utilities.Helpers import print_time

from Bio import Phylo
from termcolor import colored

OTL_PATH = "./data/opentree9.1_tree/labelled_supertree/labelled_supertree.tre"

# examples:
# subtree_otts+name = [['ott304358', 'Eukaryota'], ['ott361838', 'Chloroplastida'],
#         ['ott691846', 'Metazoa'], ['ott395057', 'Nematoda'], ['ott801601', 'Vertebrata'],
#         ['ott229562', 'Tetrapoda'], ['ott244265', 'Mammalia'], ['ott913935', 'Primates'],
#         ['ott770311', 'Hominidae'], ['ott352914', 'Fungi'], ['ott844192', 'Bacteria'],
#         ['ott996421', 'Archaea']]

# WE DON'T KEEP THE INDEXES OF THE NODES INSIDE THE TREE CONTRARY TO PREVIOUS
# VERSION
def main():
    try:
        _, subtree_ott, subtree_name = sys.argv
        CURRENT_TIME = datetime.datetime.now().replace(microsecond=0)
        print(colored("BUILDING " + subtree_name + " SUBTREE", "green"))
        print(colored("- Reading OTL", "green"))
        tree = Phylo.read(OTL_PATH, 'newick')
        CURRENT_TIME = print_time(CURRENT_TIME)

        print(colored("- Finding subtree with " + subtree_ott, "green"))
        subtree = next(tree.find_clades(subtree_ott, order='level'))
        CURRENT_TIME = print_time(CURRENT_TIME)
        # DEBUG printing
        # print('Subtree', subtree_name, 'has', subtree.count_terminals(), 'leaves and', len(subtree.get_nonterminals()), 'internal nodes')

        subtree_path = './data/subtree/' + subtree_name + '.tre'
        print(colored('- Saving subtree to ' + subtree_path))
        Phylo.write(subtree, subtree_path, 'newick')
        print_time(CURRENT_TIME)
    except:
        print(colored("Unexpected error: " + sys.exc_info()[0], "red"))

main()
