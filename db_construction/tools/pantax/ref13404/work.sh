

set -e

# build_time
pantax -f /home/work/wenhai/PanTax/genomes_info/RefDB_13404_genomes_info.txt --create -g -t 64 -v --debug

# build_index
vg gbwt -g reference_pangenome.giraffe.gbz --gbz-format -G reference_pangenome.gfa --num-jobs 64 --num-threads 64
vg index -j reference_pangenome.dist reference_pangenome.giraffe.gbz -t 64
vg minimizer -d reference_pangenome.dist -o reference_pangenome.min reference_pangenome.giraffe.gbz