set -e

wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all/straingst
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all/database_build/straingst
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
distribution_origin_file=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all/distribution.txt
genomes_info_all=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all/genomes_info_1282_species.txt
mkdir -p $wd/ery_time1_rep3 && cd $wd/ery_time1_rep3
read1=/home/work/wenhai/dataset/two_S_ep/ery_time1_rep3/read1.fq
read2=/home/work/wenhai/dataset/two_S_ep/ery_time1_rep3/read2.fq
if [ ! -f result.strains.tsv ]; then 
    /usr/bin/time -v -o query_time.log bash $wd/straingst_work.sh $read1 $read2 $db
fi
python $scripts_dir/map_cluster.py $distribution_origin_file $db/clusters.tsv straingst
python $scripts_dir/strain_evaluation.py result.strains.tsv straingst -1 distribution.txt $genomes_info_all

mkdir -p $wd/ery_time2_rep3 && cd $wd/ery_time2_rep3
read1=/home/work/wenhai/dataset/two_S_ep/ery_time2_rep3/SRR10610665/SRR10610665_1.fastq
read2=/home/work/wenhai/dataset/two_S_ep/ery_time2_rep3/SRR10610665/SRR10610665_2.fastq
if [ ! -f result.strains.tsv ]; then 
    /usr/bin/time -v -o query_time.log bash $wd/straingst_work.sh $read1 $read2 $db
fi
python $scripts_dir/map_cluster.py $distribution_origin_file $db/clusters.tsv straingst
python $scripts_dir/strain_evaluation.py result.strains.tsv straingst -1 distribution.txt $genomes_info_all


mkdir -p $wd/ery_time3_rep3 && cd $wd/ery_time3_rep3
read1=/home/work/wenhai/dataset/two_S_ep/ery_time3_rep3/SRR10610664/SRR10610664_1.fastq
read2=/home/work/wenhai/dataset/two_S_ep/ery_time3_rep3/SRR10610664/SRR10610664_2.fastq
if [ ! -f result.strains.tsv ]; then 
    /usr/bin/time -v -o query_time.log bash $wd/straingst_work.sh $read1 $read2 $db
fi
python $scripts_dir/map_cluster.py $distribution_origin_file $db/clusters.tsv straingst
python $scripts_dir/strain_evaluation.py result.strains.tsv straingst -1 distribution.txt $genomes_info_all


mkdir -p $wd/noATB_time1_rep3 && cd $wd/noATB_time1_rep3
read1=/home/work/wenhai/dataset/two_S_ep/noATB_time1_rep3/SRR10610659/SRR10610659_1.fastq
read2=/home/work/wenhai/dataset/two_S_ep/noATB_time1_rep3/SRR10610659/SRR10610659_2.fastq
if [ ! -f result.strains.tsv ]; then 
    /usr/bin/time -v -o query_time.log bash $wd/straingst_work.sh $read1 $read2 $db
fi
python $scripts_dir/map_cluster.py $distribution_origin_file $db/clusters.tsv straingst
python $scripts_dir/strain_evaluation.py result.strains.tsv straingst -1 distribution.txt $genomes_info_all


mkdir -p $wd/noATB_time2_rep3 && cd $wd/noATB_time2_rep3
read1=/home/work/wenhai/dataset/two_S_ep/noATB_time2_rep3/SRR10610658/SRR10610658_1.fastq
read2=/home/work/wenhai/dataset/two_S_ep/noATB_time2_rep3/SRR10610658/SRR10610658_2.fastq
if [ ! -f result.strains.tsv ]; then 
    /usr/bin/time -v -o query_time.log bash $wd/straingst_work.sh $read1 $read2 $db
fi
python $scripts_dir/map_cluster.py $distribution_origin_file $db/clusters.tsv straingst
python $scripts_dir/strain_evaluation.py result.strains.tsv straingst -1 distribution.txt $genomes_info_all


mkdir -p $wd/noATB_time3_rep3 && cd $wd/noATB_time3_rep3
read1=/home/work/wenhai/dataset/two_S_ep/noATB_time3_rep3/SRR10610657/SRR10610657_1.fastq
read2=/home/work/wenhai/dataset/two_S_ep/noATB_time3_rep3/SRR10610657/SRR10610657_2.fastq
if [ ! -f result.strains.tsv ]; then 
    /usr/bin/time -v -o query_time.log bash $wd/straingst_work.sh $read1 $read2 $db
fi
python $scripts_dir/map_cluster.py $distribution_origin_file $db/clusters.tsv straingst
python $scripts_dir/strain_evaluation.py result.strains.tsv straingst -1 distribution.txt $genomes_info_all

