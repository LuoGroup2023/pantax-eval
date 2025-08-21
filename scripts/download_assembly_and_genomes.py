import argparse, os, subprocess

usage = "Download assembly file and generate genomes download shell scripts"

def download_assembly_summary(db_dir, division, q = 0):
    path = os.path.join(db_dir, "assembly_summary_" + division + ".txt")
    if os.path.exists(path):
        print(f"assembly_summary_{division}.txt exists")
    else:
        if db_dir != "./" and (not os.path.exists(db_dir.strip("./"))):
            process = subprocess.Popen(["mkdir", db_dir.strip("./")])
        assembly_summary_dir = "ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/" + division + "/assembly_summary.txt"
        if q == 0:
            process = subprocess.Popen(["wget", assembly_summary_dir], stdout=subprocess.PIPE, universal_newlines=True)
            while True:
                output = process.stdout.readline()
                if output == '' and process.poll() is not None:
                    break
                if output:
                    print(output.strip())
        else:
            process = subprocess.Popen(["wget", "-q", assembly_summary_dir])
        process.wait()
        process = subprocess.Popen(["mv", "assembly_summary.txt", path])
        process.wait()
        if os.path.exists(path):
            print(f"assembly_summary_{division}.txt download successfully")
        else:
            print(f"assembly_summary_{division}.txt download fail")

def process_data(db_dir, division):
    download_list = []
    file = os.path.join(db_dir, "assembly_summary_" + division + ".txt")
    with open(file, "r") as fp:
        fp.readline()
        fp.readline()
        for line in fp:
            line = line.strip()
            tokens = line.split('\t')
            fn = tokens[19].split("/")
            fn = fn[-1] + "_genomic.fna"
            download_list.append(tokens[19] + "/" + fn + ".gz")
    print(len(download_list))
    file = os.path.join(db_dir, "genome_download_list.txt")
    with open(file, "w") as fp:
        fp.write("\n".join(download_list) + "\n")
    print("write successfully")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog="download_assembly_and_genomes.py", description=usage)
    parser.add_argument("-d", "--division", type=str, dest="division", default="bacteria", help="division(default: bacteria)")
    parser.add_argument("-o", "--db_dir", type=str, dest="db_dir", default="./", help="download directory")
    parser.add_argument("-y", "--only", dest="download_assembly_only", action="store_true", help="download_assembly_only")
    args = parser.parse_args()
    division = args.division
    db_dir = args.db_dir
    download_assembly_only = args.download_assembly_only
    download_assembly_summary(db_dir, division)
    if not download_assembly_only:
    	process_data(db_dir, division)


# wget -i genome_download_list.txt --output-file="downloadlog.txt" -nc -b

# nohup sh -c 'cat genome_download_list.txt | xargs -n 1 -P 20 sh -c "wget \$1 -o downlog/\$(basename \$1).log -nc" sh' > download.log 2>&1 &
# find ./ -name '*gz' | wc -l
# find ./ -name '*log' | wc -l