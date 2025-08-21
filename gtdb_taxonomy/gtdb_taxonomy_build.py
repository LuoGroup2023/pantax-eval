import collections, re, sys

def main():
    gtdb_taxonomy_file = sys.argv[1]
    with open(gtdb_taxonomy_file, "r") as in_file:
        build_gtdb_taxonomy(in_file)

def build_gtdb_taxonomy(in_file):
    rank_codes = {
        # "d": "domain",
        "d": "superkingdom",
        "p": "phylum",
        "c": "class",
        "o": "order",
        "f": "family",
        "g": "genus",
        "s": "species",
    }
    accession_map = {}
    seen_it = collections.defaultdict(int)
    child_data = collections.defaultdict(lambda: collections.defaultdict(int))
    for line in in_file:
        line = line.strip()
        accession, taxonomy_string = line.split("\t")
        start = accession.find("GCA")
        if start < 0:
            start = accession.find("GCF")
        accession = accession[start:]
        taxonomy_string = re.sub("(;[a-z]__)+$", "", taxonomy_string)
        accession_map[accession] = taxonomy_string
        seen_it[taxonomy_string] += 1
        if seen_it[taxonomy_string] > 1:
            continue
        while True:
            match = re.search("(;[a-z]__[^;]+$)", taxonomy_string)
            if not match:
                break
            level = match.group(1)
            taxonomy_string = re.sub("(;[a-z]__[^;]+$)", "", taxonomy_string)
            key = taxonomy_string + level
            child_data[taxonomy_string][key] += 1
            seen_it[taxonomy_string] += 1
            if seen_it[taxonomy_string] > 1:
                break
        if seen_it[taxonomy_string] == 1:
            child_data["cellular organisms"][taxonomy_string] += 1
            child_data["root"]["cellular organisms"] += 1
    child_data["root"]["Other"] += 1
    child_data["root"]["Unclassified"] += 1
            

    id_map = {}
    next_node_id = 1
    print("Generating nodes.dmp and names.dmp\n")
    with open("names.dmp", "w") as names_file:
        with open("nodes.dmp", "w") as nodes_file:
            bfs_queue = [["root", 1]]
            while len(bfs_queue) > 0:
                node, parent_id = bfs_queue.pop()
                display_name = node
                rank = None
                match = re.search("([a-z])__([^;]+)$", node)
                if match:
                    rank = rank_codes[match.group(1)]
                    display_name = match.group(2)
                rank = rank or "no rank"
                node_id, next_node_id = next_node_id, next_node_id + 1
                id_map[node] = node_id
                names_file.write(
                    "{:d}\t|\t{:s}\t|\t-\t|\tscientific name\t|\n".format(
                        node_id, display_name
                    )
                )
                nodes_file.write(
                    "{:d}\t|\t{:d}\t|\t{:s}\t|\t-\t|\n".format(
                        node_id, parent_id, rank
                    )
                )
                children = (
                    sorted([key for key in child_data[node]])
                    if node in child_data
                    else []
                )
                for node in children:
                    bfs_queue.insert(0, [node, node_id])
    with open("gtdb.accession2taxid", "w") as f:
        for accession in sorted([key for key in accession_map]):
            taxid = id_map[accession_map[accession]]
            accession_without_revision = accession.split(".")[0]
            f.write("{:s}\t{:s}\t{:d}\t-\n".format(
                accession_without_revision,
                accession, taxid
            ))


if __name__ == "__main__":
    sys.exit(main())