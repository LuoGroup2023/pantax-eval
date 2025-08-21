
set -e
kraken2="kraken2"
tool_name="kraken2"
threads=64

###### simlow-gtdb-mut0.01 ngs
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simlow-gtdb-mut0.01
data_type=30
read_type=short
samplesID=ngs
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simlow_mut0.01/ngs/simlow_ngs_mut0.01/2025.03.02_19.14.55_sample_0/reads/anonymous_reads.fq.gz
read1=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simlow_mut0.01/ngs/simlow_ngs_mut0.01/2025.03.02_19.14.55_sample_0/reads/read1.fq
read2=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simlow_mut0.01/ngs/simlow_ngs_mut0.01/2025.03.02_19.14.55_sample_0/reads/read2.fq
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/prepare/simlow/distribution.txt
read_length=150
genome_length=-
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/gtdb100/kraken2_db
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
tax2genome=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/gtdb_taxonomy/strain_taxid.tsv
genomes_length_for_strains=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genome_statics_gtdb.txt
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
###### simlow-gtdb-mut0.01 hifi
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simlow-gtdb-mut0.01
data_type=30
read_type=long
samplesID=hifi
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simlow_mut0.01/hifi/simlow_hifi_mut0.01/2025.03.02_19.15.04_sample_0/reads/anonymous_reads.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/prepare/simlow/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/gtdb100/kraken2_db
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
tax2genome=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/gtdb_taxonomy/strain_taxid.tsv
genomes_length_for_strains=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genome_statics_gtdb.txt
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
###### simlow-gtdb-mut0.01 ontR9
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simlow-gtdb-mut0.01
data_type=30
read_type=long
samplesID=ontR9
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simlow_mut0.01/ontR941/simlow_ontR941_mut0.01/2025.03.02_19.15.45_sample_0/reads/anonymous_reads.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/prepare/simlow/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/gtdb100/kraken2_db
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
tax2genome=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/gtdb_taxonomy/strain_taxid.tsv
genomes_length_for_strains=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genome_statics_gtdb.txt
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
###### simlow-gtdb-mut0.01 ontR10
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simlow-gtdb-mut0.01
data_type=30
read_type=long
samplesID=ontR10
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simlow_mut0.01/ontR104/simlow_ontR104_mut0.01/2025.03.02_19.16.17_sample_0/reads/anonymous_reads.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/prepare/simlow/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/gtdb100/kraken2_db
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
tax2genome=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/gtdb_taxonomy/strain_taxid.tsv
genomes_length_for_strains=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genome_statics_gtdb.txt
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
###### simlow-gtdb-mut0.01 clr
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simlow-gtdb-mut0.01
data_type=30
read_type=long
samplesID=clr
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simlow_mut0.01/clr/simlow_clr_mut0.01/2025.03.02_19.15.29_sample_0/reads/anonymous_reads.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/prepare/simlow/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/gtdb100/kraken2_db
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
tax2genome=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/gtdb_taxonomy/strain_taxid.tsv
genomes_length_for_strains=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genome_statics_gtdb.txt
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
