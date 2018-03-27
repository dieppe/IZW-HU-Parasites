import csv
from time import gmtime, strftime


INTERACTIONS_FILE_PATH = './data/GloBI_Dump/interactions.tsv'
FREELIVING_OUTPUT_PATH = './data/interaction_data/freelivings.csv'
PARASITE_OUTPUT_PATH = './data/interaction_data/parasites.csv'

PARASITE_SOURCES = [
    'parasiteOf',
    'pathogenOf',
]
PARASITE_TARGETS = [
    'hasParasite',
    'hasPathogen',
]
FREELIVING_SOURCES = [
    'preysOn',
    'eats',
    'flowersVisitedBy',
    'hasPathogen',
    'pollinatedBy',
    'hasParasite',
    'hostOf',
]
FREELIVING_TARGETS = [
    'preyedUponBy',
    'parasiteOf',
    'visitsFlowersOf',
    'pathogenOf',
    'hasHost',
]


def main():
    print(strftime('%Y-%m-%d %H:%M:%S', gmtime()))
    print('-------------------')

    #           [['ott_id','taxon_name']]
    freelivings = {}
    parasites = {}

    index = 0

    # We favour parasites over freelivings
    # Given the source / target tests, we can have a parasite that would be
    # tagged as a freeliving. Once a parasite has been identified, it is
    # clear it can not be a free living.
    def add_parasite(ott, name, interaction):
        freelivings.pop(ott, None)
        parasites[ott] = [ott, name, interaction]

    def add_freeliving(ott, name, interaction):
        if (ott not in parasites):
            freelivings[ott] = [ott, name, interaction]

    with open(INTERACTIONS_FILE_PATH, 'r', encoding='utf8') as tsv_file:
        reader = csv.reader(tsv_file, delimiter='\t')
        for row in reader:
            index += 1
            interaction = row[10]
            # eliminate useless interactions
            if any(
                interaction in source
                    for source in (FREELIVING_SOURCES, PARASITE_SOURCES)
            ):
                if row[0] != '' and 'OTT' in row[0]:
                    ott = row[0].split(':')
                    name = row[1]
                    # normal case (otherwise no ott available,
                    # but maybe another one):
                    if len(ott) >= 2:
                        if interaction in FREELIVING_SOURCES:
                            add_freeliving(ott[1], name, interaction)
                        elif interaction in PARASITE_SOURCES:
                            add_parasite(ott[1], name, interaction)
            if any(
                interaction in target
                    for target in (FREELIVING_TARGETS, PARASITE_TARGETS)
            ):
                if row[11] != '' and 'OTT' in row[11]:
                    ott = row[11].split(':')
                    name = row[12]
                    # normal case (otherwise no ott available,
                    # but maybe another one):
                    if len(ott) >= 2:
                        if interaction in FREELIVING_TARGETS:
                            add_freeliving(ott[1], name, interaction)
                        elif interaction in PARASITE_TARGETS:
                            add_parasite(ott[1], name, interaction)

    print('-------------------')
    print(strftime('%Y-%m-%d %H:%M:%S', gmtime()))
    print('-------------------')
    print('tsv_len =', index)

    print('Number of freelivings:', len(freelivings.items()))
    print('Number of parasites:', len(parasites.items()))

    # -------------------------------------------------
    with open(FREELIVING_OUTPUT_PATH, 'w') as f:
        writer = csv.writer(f)
        writer.writerows(freelivings.items())

    with open(PARASITE_OUTPUT_PATH, 'w') as f:
        writer = csv.writer(f)
        writer.writerows(parasites.items())
    # -------------------------------------------------
    print('-------------------')
    print(strftime('%Y-%m-%d %H:%M:%S', gmtime()))
    return


main()
