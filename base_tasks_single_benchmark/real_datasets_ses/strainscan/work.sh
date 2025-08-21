set -e

wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all/strainscan
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all/database_build/strainscan/1282_strainscan_db
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
distribution_origin_file=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all/distribution.txt
genomes_info_all=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all/genomes_info_1282_species.txt

mkdir -p $wd/ery_time1_rep3 && cd $wd/ery_time1_rep3
read1=/home/work/wenhai/dataset/two_S_ep/ery_time1_rep3/read1.fq
read2=/home/work/wenhai/dataset/two_S_ep/ery_time1_rep3/read2.fq
if [ ! -d strainscan_result ]; then
    /usr/bin/time -v -o strainscan_query_time.log strainscan -i $read1 -j $read2 -d $db -o strainscan_result
fi
python $scripts_dir/strain_evaluation.py strainscan_result/final_report.txt strainscan -1 $distribution_origin_file $genomes_info_all

mkdir -p $wd/ery_time2_rep3 && cd $wd/ery_time2_rep3
read1=/home/work/wenhai/dataset/two_S_ep/ery_time2_rep3/SRR10610665/SRR10610665_1.fastq
read2=/home/work/wenhai/dataset/two_S_ep/ery_time2_rep3/SRR10610665/SRR10610665_2.fastq
if [ ! -d strainscan_result ]; then
    /usr/bin/time -v -o strainscan_query_time.log strainscan -i $read1 -j $read2 -d $db -o strainscan_result
fi
python $scripts_dir/strain_evaluation.py strainscan_result/final_report.txt strainscan -1 $distribution_origin_file $genomes_info_all


mkdir -p $wd/ery_time3_rep3 && cd $wd/ery_time3_rep3
read1=/home/work/wenhai/dataset/two_S_ep/ery_time3_rep3/SRR10610664/SRR10610664_1.fastq
read2=/home/work/wenhai/dataset/two_S_ep/ery_time3_rep3/SRR10610664/SRR10610664_2.fastq
if [ ! -d strainscan_result ]; then
    /usr/bin/time -v -o strainscan_query_time.log strainscan -i $read1 -j $read2 -d $db -o strainscan_result
fi
python $scripts_dir/strain_evaluation.py strainscan_result/final_report.txt strainscan -1 $distribution_origin_file $genomes_info_all


mkdir -p $wd/noATB_time1_rep3 && cd $wd/noATB_time1_rep3
read1=/home/work/wenhai/dataset/two_S_ep/noATB_time1_rep3/SRR10610659/SRR10610659_1.fastq
read2=/home/work/wenhai/dataset/two_S_ep/noATB_time1_rep3/SRR10610659/SRR10610659_2.fastq
if [ ! -d strainscan_result ]; then
    /usr/bin/time -v -o strainscan_query_time.log strainscan -i $read1 -j $read2 -d $db -o strainscan_result
fi
python $scripts_dir/strain_evaluation.py strainscan_result/final_report.txt strainscan -1 $distribution_origin_file $genomes_info_all


mkdir -p $wd/noATB_time2_rep3 && cd $wd/noATB_time2_rep3
read1=/home/work/wenhai/dataset/two_S_ep/noATB_time2_rep3/SRR10610658/SRR10610658_1.fastq
read2=/home/work/wenhai/dataset/two_S_ep/noATB_time2_rep3/SRR10610658/SRR10610658_2.fastq
if [ ! -d strainscan_result ]; then
    /usr/bin/time -v -o strainscan_query_time.log strainscan -i $read1 -j $read2 -d $db -o strainscan_result
fi
python $scripts_dir/strain_evaluation.py strainscan_result/final_report.txt strainscan -1 $distribution_origin_file $genomes_info_all


mkdir -p $wd/noATB_time3_rep3 && cd $wd/noATB_time3_rep3
read1=/home/work/wenhai/dataset/two_S_ep/noATB_time3_rep3/SRR10610657/SRR10610657_1.fastq
read2=/home/work/wenhai/dataset/two_S_ep/noATB_time3_rep3/SRR10610657/SRR10610657_2.fastq
if [ ! -d strainscan_result ]; then
    /usr/bin/time -v -o strainscan_query_time.log strainscan -i $read1 -j $read2 -d $db -o strainscan_result
fi
python $scripts_dir/strain_evaluation.py strainscan_result/final_report.txt strainscan -1 $distribution_origin_file $genomes_info_all

