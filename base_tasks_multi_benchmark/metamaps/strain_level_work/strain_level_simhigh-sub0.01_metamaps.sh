
set -e
pantax="metamaps"
tool_name="metamaps"
threads=64

###### simhigh-sub0.01 hifi
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-sub0.01
data_type=1000
read_type=long
samplesID=hifi
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_mutation/simhigh/hifi/mut_rate0.01/simhigh-hifi-mut_rate0.01.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax/prepare/1000strains/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/metamaps/databases/strain_level_metamaps_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f classification_results.EM ] && [ ! -f strain_classification.csv ]; then
    /usr/bin/time -v -o query_time1.log metamaps mapDirectly -r $db/DB.fa -q $read -t $threads -o classification_results
    /usr/bin/time -v -o query_time2.log metamaps classify --mappings classification_results --DB $db -t $threads
    python $scripts_dir/time_process.py query_time1.log > time_evaluation1.txt
    python $scripts_dir/time_process.py query_time2.log > time_evaluation2.txt
fi
if [ ! -f "evaluation_report.txt" ]; then
    # not yet test, maybe can't work at species level
    if [ $profile_level == "species_level" ]; then
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path -e 0
    elif [ $profile_level == "strain_level" ] || [ $profile_level == "zymo1_strain_level" ]; then
        if [ ! -f strain_classification.csv ]; then
            python $scripts_dir/metamaps_strain_process.py classification_results.EM $genome2seqid
        fi
        if [ $read_length == "None" ]; then
            python $scripts_dir/get_read_len.py -fq $read -s long
            read_length=long_read_length.txt
        fi
        python $scripts_dir/strain_abundance_estimate.py -rc strain_classification.csv -rl $read_length -gl $genomes_length_for_strains -s $samplesID -o . -f $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simhigh-sub0.01 ontR9
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-sub0.01
data_type=1000
read_type=long
samplesID=ontR9
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_mutation/simhigh/ontR9/mut_rate0.01/simhigh-ontR9-mut_rate0.01.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax/prepare/1000strains/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/metamaps/databases/strain_level_metamaps_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f classification_results.EM ] && [ ! -f strain_classification.csv ]; then
    /usr/bin/time -v -o query_time1.log metamaps mapDirectly -r $db/DB.fa -q $read -t $threads -o classification_results
    /usr/bin/time -v -o query_time2.log metamaps classify --mappings classification_results --DB $db -t $threads
    python $scripts_dir/time_process.py query_time1.log > time_evaluation1.txt
    python $scripts_dir/time_process.py query_time2.log > time_evaluation2.txt
fi
if [ ! -f "evaluation_report.txt" ]; then
    # not yet test, maybe can't work at species level
    if [ $profile_level == "species_level" ]; then
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path -e 0
    elif [ $profile_level == "strain_level" ] || [ $profile_level == "zymo1_strain_level" ]; then
        if [ ! -f strain_classification.csv ]; then
            python $scripts_dir/metamaps_strain_process.py classification_results.EM $genome2seqid
        fi
        if [ $read_length == "None" ]; then
            python $scripts_dir/get_read_len.py -fq $read -s long
            read_length=long_read_length.txt
        fi
        python $scripts_dir/strain_abundance_estimate.py -rc strain_classification.csv -rl $read_length -gl $genomes_length_for_strains -s $samplesID -o . -f $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simhigh-sub0.01 ontR10
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-sub0.01
data_type=1000
read_type=long
samplesID=ontR10
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_mutation/simhigh/ontR10/mut_rate0.01/simhigh-ontR10-mut_rate0.01.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax/prepare/1000strains/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/metamaps/databases/strain_level_metamaps_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f classification_results.EM ] && [ ! -f strain_classification.csv ]; then
    /usr/bin/time -v -o query_time1.log metamaps mapDirectly -r $db/DB.fa -q $read -t $threads -o classification_results
    /usr/bin/time -v -o query_time2.log metamaps classify --mappings classification_results --DB $db -t $threads
    python $scripts_dir/time_process.py query_time1.log > time_evaluation1.txt
    python $scripts_dir/time_process.py query_time2.log > time_evaluation2.txt
fi
if [ ! -f "evaluation_report.txt" ]; then
    # not yet test, maybe can't work at species level
    if [ $profile_level == "species_level" ]; then
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path -e 0
    elif [ $profile_level == "strain_level" ] || [ $profile_level == "zymo1_strain_level" ]; then
        if [ ! -f strain_classification.csv ]; then
            python $scripts_dir/metamaps_strain_process.py classification_results.EM $genome2seqid
        fi
        if [ $read_length == "None" ]; then
            python $scripts_dir/get_read_len.py -fq $read -s long
            read_length=long_read_length.txt
        fi
        python $scripts_dir/strain_abundance_estimate.py -rc strain_classification.csv -rl $read_length -gl $genomes_length_for_strains -s $samplesID -o . -f $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simhigh-sub0.01 clr
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-sub0.01
data_type=1000
read_type=long
samplesID=clr
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_mutation/simhigh/clr/mut_rate0.01/simhigh-clr-mut_rate0.01.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax/prepare/1000strains/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/metamaps/databases/strain_level_metamaps_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f classification_results.EM ] && [ ! -f strain_classification.csv ]; then
    /usr/bin/time -v -o query_time1.log metamaps mapDirectly -r $db/DB.fa -q $read -t $threads -o classification_results
    /usr/bin/time -v -o query_time2.log metamaps classify --mappings classification_results --DB $db -t $threads
    python $scripts_dir/time_process.py query_time1.log > time_evaluation1.txt
    python $scripts_dir/time_process.py query_time2.log > time_evaluation2.txt
fi
if [ ! -f "evaluation_report.txt" ]; then
    # not yet test, maybe can't work at species level
    if [ $profile_level == "species_level" ]; then
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path -e 0
    elif [ $profile_level == "strain_level" ] || [ $profile_level == "zymo1_strain_level" ]; then
        if [ ! -f strain_classification.csv ]; then
            python $scripts_dir/metamaps_strain_process.py classification_results.EM $genome2seqid
        fi
        if [ $read_length == "None" ]; then
            python $scripts_dir/get_read_len.py -fq $read -s long
            read_length=long_read_length.txt
        fi
        python $scripts_dir/strain_abundance_estimate.py -rc strain_classification.csv -rl $read_length -gl $genomes_length_for_strains -s $samplesID -o . -f $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
