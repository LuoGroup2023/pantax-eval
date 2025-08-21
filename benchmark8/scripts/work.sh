

set -e

wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/solvers_eval
profiling_script=/home/work/wenhai/wh-github/PanTax/pantaxr/target/release/pantaxr

tool_name="pantax"
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
data_type=30
true_abund=/home/work/wenhai/simulate_genome_data/PanTax/short_read/30_species/sim-30species-ngs/distributions/distribution_0.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt

for solver in cbc glpk highs gurobi; do
    mkdir -p $wd/res/$solver && cd $wd/res/$solver
    if [ ! -f strain_abundance.txt ]; then
        echo "Profiling with $solver"
        # /home/work/wenhai/wh-github/PanTax/pantaxr/target/release/pantaxr profile -m $wd/data/short_gfa_mapped.gaf --filtered --db $pantax_db --species --strain --debug -t 64 --solver $solver > eval.log
    fi
    if [ ! -f evaluation_report.txt ]; then 
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
    echo "$solver:"
    python $wd/scripts/get_profiling_time_from_log.py eval.log
done
