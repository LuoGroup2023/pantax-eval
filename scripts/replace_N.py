import gzip
import sys

def open_file(file_path, mode='rt'):
    if file_path.endswith('.gz'):
        return gzip.open(file_path, mode)
    else:
        return open(file_path, mode)

def replace_n_in_fastq(input_file, output_file):
    with open_file(input_file, 'rt') as fin, open_file(output_file, 'wt') as fout:
        while True:
            lines = [fin.readline() for _ in range(4)]
            if not lines[0]:
                break  

            lines[1] = lines[1].replace('N', 'A').replace('n', 'A')
            fout.writelines(lines)

replace_n_in_fastq(sys.argv[1], "reads_noN.fastq.gz")
