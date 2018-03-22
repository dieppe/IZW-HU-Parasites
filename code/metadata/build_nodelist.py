import traceback
import csv
import datetime
import sys
from code.utilities.Helpers import print_time
from time import gmtime, strftime

from Bio import Phylo
from termcolor import colored

freelivings_state_path = "./data/interaction_data/freelivings.csv"
parasites_state_path = "./data/interaction_data/parasites.csv"

def print_stats(stats):
    print('Number of leaves:', stats['leaves'])
    print('Number of parasites:', stats['tagged_as_P'])
    print('Number of freelivings:', stats['tagged_as_FL'])
    print('Number of double tags:', stats['doubly_tagged'])
    print('Number of unknown:', stats['not_tagged'])
    print('Percentage unkown:', stats['not_tagged'] / stats['leaves'])

# Using set allow for very fast lookups
def get_state_set(path):
    state_set = set()
    with open(path, 'r') as state_file:
        state_file_reader = csv.reader(state_file, delimiter=',')
        for row in state_file_reader:
            if row != []: state_set.add("ott" + row[0])
    print('number of tags', len(state_set))
    return state_set

def load_known_states():
    return {
        'freelivings': get_state_set(freelivings_state_path),
        'parasites': get_state_set(parasites_state_path),
    }

def main():
    try:
        _, subtree_name = sys.argv
        stats = {
            'leaves': 0,
            'tagged_as_FL': 0,
            'tagged_as_P': 0,
            'not_tagged': 0,
            'doubly_tagged': 0,
        }
        CURRENT_TIME = datetime.datetime.now().replace(microsecond=0)

        print(colored(strftime("[%Y-%m-%d %H:%M:%S] ", gmtime()) + "BUILDING NODELIST", "green"))
        print(colored("- Loading freelivings and parasites states...", "green"))
        known_states = load_known_states()
        CURRENT_TIME = print_time(CURRENT_TIME)

        print(colored('- Reading ' + subtree_name + ' subtree', "green"))
        subtree_path = './data/subtree/' + subtree_name + '.tre'
        tree = Phylo.read(subtree_path, 'newick')
        CURRENT_TIME = print_time(CURRENT_TIME)

        print(colored("- Tagging tree", "green"))
        nodelist = []
        build_nodelist_for_subtree_from_known_states(nodelist, tree.clade, known_states, 0, stats)
        CURRENT_TIME = print_time(CURRENT_TIME)

        print_stats(stats)
        print("Rootnode, Depth, Heigths: [Min, Max, Mean], Originaltag, Finaltag, Nr_children")
        print(nodelist[0])

        csv_path = './data/nodelist/' + subtree_name + '.csv'
        print(colored("- Writing csv file to " + csv_path, "green"))
        with open(csv_path, 'w') as nodelist_file:
            writer = csv.writer(nodelist_file)
            writer.writerows(nodelist)
        CURRENT_TIME = print_time(CURRENT_TIME)
    except:
        print(colored("Unexpected error: ", "red"))
        traceback.print_exc()
    return

def build_nodelist_for_subtree_from_known_states(nodelist, subtree, known_states, depth, stats):
    ott = subtree.name
    #                   0    1              2       3       4           5
    # nodelist      - [id, originaltag, finaltag, depth, heights, nr_children]
    nodelist.append([ott, "", "", depth, None, len(subtree.clades)])
    current_list_index = len(nodelist) - 1

    if subtree.is_terminal():
        tag_leaf(nodelist, current_list_index, ott, known_states, stats)
        # min height, max height, mean height at leaf level
        heights = [1, 1, 1]
    else:
        min_height, max_height, mean_height, child_height = [float('inf'), 0, 0, 0]
        for clade in subtree.clades:
            # Build nodelist for children first
            heights = build_nodelist_for_subtree_from_known_states(
                nodelist, clade, known_states, depth + 1, stats
            )
            if heights[0] < min_height:
                # Min height of the child is lower than current min height
                min_height = heights[0]
            if heights[1] > max_height:
                # Max height of the child is greater than current max height
                max_height = heights[1]
            # Add the child mean height to the current sum of all children mean height
            child_height = child_height + heights[2]
        # Divide the sum of children mean heights by the number of children
        mean_height = child_height/len(subtree.clades)
        heights = [min_height + 1, max_height + 1, mean_height + 1]
    nodelist[current_list_index][4] = heights
    # -------------------------------------------------
    return heights

def tag_leaf(nodelist, current_list_index, ott, states, stats):
    #                   0    1              2       3       4           5
    # nodelist      - [id, originaltag, finaltag, depth, heights, nr_children]
    # current_list_index - index of current node
    # ott
    # species_lists - [freelivings, parasites]
    # stats         - [number_of_leaves, number_of_tagged_P, number_of_tagged_FL, number_of_unknown, number_of_double_tags]
    stats['leaves'] += 1

    flag = "NA"
    is_parasite = is_in_state_set(ott, states['parasites'])
    is_freeliving = is_in_state_set(ott, states['freelivings'])

    if is_parasite:
        print(ott, 'is parasite')
        flag = "2"
        stats['tagged_as_P'] += 1
    elif is_freeliving:
        print(ott, 'is freeliving')
        flag = "1"
        stats['tagged_as_FL'] += 1
    else:
        # print(ott, 'is unknown')
        stats['not_tagged'] += 1

    if is_parasite and is_freeliving:
        print(ott, 'is actually both')
        stats['tagged_as_P'] -= 1
        stats['doubly_tagged'] += 1

    nodelist[current_list_index][1] = flag
    return

def is_in_state_set(name, states):
    if name in states:
        states.remove(name)
        return True
    return False

main()
