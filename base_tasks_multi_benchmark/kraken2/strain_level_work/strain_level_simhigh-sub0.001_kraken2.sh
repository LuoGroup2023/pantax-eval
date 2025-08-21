
set -e
kraken2="kraken2"
tool_name="kraken2"
threads=64

###### simhigh-sub0.001 ngs
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-sub0.001
data_type=1000
read_type=short
samplesID=ngs
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_mutation/simhigh/ngs/mut_rate0.001/simhigh-ngs-mut_rate0.001.fq.gz
read1=/home/work/wenhai/simulate_genome_data/PanTax_mutation/simhigh/ngs/mut_rate0.001/read1.fq
read2=/home/work/wenhai/simulate_genome_data/PanTax_mutation/simhigh/ngs/mut_rate0.001/read2.fq
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax/prepare/1000strains/distribution.txt
read_length=150
genome_length=-
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/kraken2_db
tax2genome=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/kraken2_strain_taxid.tsv
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# short
if [ ! -f kraken2_query_report ]; then
    /usr/bin/time -v -o query_time.log kraken2 --db $db --output kraken2_query_reads --report kraken2_query_report --threads $threads --paired $read1 $read2
fi
if [ ! -f "evaluation_report.txt" ]; then
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    # not yet test, maybe can't work at species level
    if [ $profile_level == "species_level" ]; then
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path -e 0
    elif [ $profile_level == "strain_level" ] || [ $profile_level == "zymo1_strain_level" ]; then
        python $scripts_dir/kraken_format_strain_abundance_est.py kraken2_query_report kraken2_query_reads S1 $genomes_length_for_strains $tax2genome
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simhigh-sub0.001 hifi
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-sub0.001
data_type=1000
read_type=long
samplesID=hifi
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_mutation/simhigh/hifi/mut_rate0.001/simhigh-hifi-mut_rate0.001.fq.gz
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
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/kraken2_db
tax2genome=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/kraken2_strain_taxid.tsv
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f kraken2_query_report ]; then
    /usr/bin/time -v -o query_time.log kraken2 --db $db --output kraken2_query_reads --report kraken2_query_report --threads $threads $read
fi
if [ ! -f "evaluation_report.txt" ]; then
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    # not yet test, maybe can't work at species level
    if [ $profile_level == "species_level" ]; then
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path -e 0
    elif [ $profile_level == "strain_level" ] || [ $profile_level == "zymo1_strain_level" ]; then
        python $scripts_dir/kraken_format_strain_abundance_est.py kraken2_query_report kraken2_query_reads S1 $genomes_length_for_strains $tax2genome
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simhigh-sub0.001 ontR9
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-sub0.001
data_type=1000
read_type=long
samplesID=ontR9
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_mutation/simhigh/ontR9/mut_rate0.001/simhigh-ontR9-mut_rate0.001.fq.gz
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
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/kraken2_db
tax2genome=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/kraken2_strain_taxid.tsv
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f kraken2_query_report ]; then
    /usr/bin/time -v -o query_time.log kraken2 --db $db --output kraken2_query_reads --report kraken2_query_report --threads $threads $read
fi
if [ ! -f "evaluation_report.txt" ]; then
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    # not yet test, maybe can't work at species level
    if [ $profile_level == "species_level" ]; then
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path -e 0
    elif [ $profile_level == "strain_level" ] || [ $profile_level == "zymo1_strain_level" ]; then
        python $scripts_dir/kraken_format_strain_abundance_est.py kraken2_query_report kraken2_query_reads S1 $genomes_length_for_strains $tax2genome
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simhigh-sub0.001 ontR10
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-sub0.001
data_type=1000
read_type=long
samplesID=ontR10
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_mutation/simhigh/ontR10/mut_rate0.001/simhigh-ontR10-mut_rate0.001.fq.gz
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
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/kraken2_db
tax2genome=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/kraken2_strain_taxid.tsv
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f kraken2_query_report ]; then
    /usr/bin/time -v -o query_time.log kraken2 --db $db --output kraken2_query_reads --report kraken2_query_report --threads $threads $read
fi
if [ ! -f "evaluation_report.txt" ]; then
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    # not yet test, maybe can't work at species level
    if [ $profile_level == "species_level" ]; then
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path -e 0
    elif [ $profile_level == "strain_level" ] || [ $profile_level == "zymo1_strain_level" ]; then
        python $scripts_dir/kraken_format_strain_abundance_est.py kraken2_query_report kraken2_query_reads S1 $genomes_length_for_strains $tax2genome
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simhigh-sub0.001 clr
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-sub0.001
data_type=1000
read_type=long
samplesID=clr
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_mutation/simhigh/clr/mut_rate0.001/simhigh-clr-mut_rate0.001.fq.gz
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
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/kraken2_db
tax2genome=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/kraken2_strain_taxid.tsv
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f kraken2_query_report ]; then
    /usr/bin/time -v -o query_time.log kraken2 --db $db --output kraken2_query_reads --report kraken2_query_report --threads $threads $read
fi
if [ ! -f "evaluation_report.txt" ]; then
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    # not yet test, maybe can't work at species level
    if [ $profile_level == "species_level" ]; then
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path -e 0
    elif [ $profile_level == "strain_level" ] || [ $profile_level == "zymo1_strain_level" ]; then
        python $scripts_dir/kraken_format_strain_abundance_est.py kraken2_query_report kraken2_query_reads S1 $genomes_length_for_strains $tax2genome
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
