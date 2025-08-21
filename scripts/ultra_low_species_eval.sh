
set -e
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
abundance_cal_scirpt=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208/evaluation_scripts/abundance_cal_13404.py
species_eval_script=$scripts_dir/species_metrics_eval.py
report_out_dir=$scripts_dir/species_report/low_30species
true_abund=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto/kraken2/strain_level/simlow-low/ngs/true_species_abundance.txt

# > $report_out_dir/evaluation_report.txt

# # kraken
# tool=kraken2
# cd $wd/$tool/strain_level/simlow-low/ngs
# python $abundance_cal_scirpt kraken2_query_reads $tool short 5
# # python $species_eval_script -i kraken2_query_reads -t $tool -rt short -dt 5 > $report_out_dir/evaluation_report.txt
# python $species_eval_script -i kraken2_query_reads -t $tool -rt short -dt 5 -e 0 >> $report_out_dir/evaluation_report.txt

# tool=bracken
# cd $wd/$tool/strain_level/simlow-low/ngs
# python $abundance_cal_scirpt bracken_query_report_species $tool short 5
# # python $species_eval_script -i bracken_query_report_species -t $tool -rt short -dt 5 >> $report_out_dir/evaluation_report.txt
# python $species_eval_script -i bracken_query_report_species -t $tool -rt short -dt 5 -e 0 >> $report_out_dir/evaluation_report.txt

# tool=centrifuge
# cd $wd/$tool/strain_level/simlow-low/ngs
# python $abundance_cal_scirpt centrifuge_query_reads $tool short 5
# # python $species_eval_script -i centrifuge_query_reads -t $tool -rt short -dt 5 >> $report_out_dir/evaluation_report.txt
# python $species_eval_script -i centrifuge_query_reads -t $tool -rt short -dt 5 -e 0 >> $report_out_dir/evaluation_report.txt

# tool=centrifuger
# cd $wd/$tool/strain_level/simlow-low/ngs
# python $scripts_dir/centrifuger_species_process.py centrifuger_report.tsv
# # python $species_eval_script -i - -t $tool -rt short -dt 5 -ta $true_abund >> $report_out_dir/evaluation_report.txt
# python $species_eval_script -i - -t $tool -rt short -dt 5 -ta $true_abund -e 0 >> $report_out_dir/evaluation_report.txt

# tool="kmcp"
# cd $wd/$tool/strain_level/simlow-low/ngs
# python $scripts_dir/kmcp_species_process.py result.metaphlan.profile
# # python $species_eval_script -i - -t $tool -rt short -dt 5 -ta $true_abund >> $report_out_dir/evaluation_report.txt
# python $species_eval_script -i - -t $tool -rt short -dt 5 -ta $true_abund -e 0 >> $report_out_dir/evaluation_report.txt

# tool="ganon"
# cd $wd/$tool/strain_level/simlow-low/ngs
# python $scripts_dir/ganon_species_process.py tax_profile.tre
# # python $species_eval_script -i - -t $tool -rt short -dt 5 -ta $true_abund >> $report_out_dir/evaluation_report.txt
# python $species_eval_script -i - -t $tool -rt short -dt 5 -ta $true_abund -e 0 >> $report_out_dir/evaluation_report.txt

# tool=pantax
# cd $wd/$tool/strain_level/simlow-low_mode0/ngs
# echo "mode0" >> $report_out_dir/evaluation_report.txt
# # python $species_eval_script -i pantax_db_tmp/reads_classification.tsv -t $tool -rt short -dt 5 -ta $true_abund >> $report_out_dir/evaluation_report.txt
# python $species_eval_script -i pantax_db_tmp/reads_classification.tsv -t $tool -rt short -dt 5 -ta $true_abund -e 0 >> $report_out_dir/evaluation_report.txt

tool=pantax
cd $wd/$tool/strain_level/simlow-low_mode1/ngs
echo "mode1_95" >> $report_out_dir/evaluation_report.txt
# python $species_eval_script -i pantax_db_tmp/reads_classification.tsv -t $tool -rt short -dt 5 -ta $true_abund >> $report_out_dir/evaluation_report.txt
python $species_eval_script -i pantax_db_tmp/reads_classification.tsv -t $tool -rt short -dt 5 -ta $true_abund -e 0 >> $report_out_dir/evaluation_report.txt

# tool="metaphlan"
# echo $tool >> $report_out_dir/evaluation_report.txt
# cd /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208/tool/metaphlan4/low_30species2
# metaphlan_eval_script=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208/tool/metaphlan4/metric_evaluate/precision_recall.py
# # python $metaphlan_eval_script >> $report_out_dir/evaluation_report.txt 
# python $metaphlan_eval_script -e 0 >> $report_out_dir/evaluation_report.txt 

# tool=sylph
# cd $wd/$tool/strain_level/simlow-low/ngs
# genomes_info_file=/home/work/wenhai/PanTax/genomes_info/RefDB_13404_genomes_info.txt
# python $scripts_dir/sylph_species_process.py sylph_abundance.txt $genomes_info_file
# python $species_eval_script -i - -t $tool -rt short -dt 5 -ta $true_abund -e 0 >> $report_out_dir/evaluation_report.txt
