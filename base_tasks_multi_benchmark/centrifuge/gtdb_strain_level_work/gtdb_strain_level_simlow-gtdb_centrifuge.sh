
set -e
centrifuge="centrifuge"
tool_name="centrifuge"
threads=64

###### simlow-gtdb ngs
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simlow-gtdb
data_type=30
read_type=short
samplesID=ngs
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simlow/ngs/simlow_ngs/2025.01.20_01.11.15_sample_0/reads/anonymous_reads.fq.gz
read1=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simlow/ngs/simlow_ngs/2025.01.20_01.11.15_sample_0/reads/read1.fq
read2=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simlow/ngs/simlow_ngs/2025.01.20_01.11.15_sample_0/reads/read2.fq
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/prepare/simlow/distribution.txt
read_length=150
genome_length=-
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/centrifuge/gtdb100/centrifuge_db/centrifugeDB
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
genomes_length_for_strains=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genome_statics_gtdb.txt
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/gtdb100_fna_seqID_taxid.txt
# dir
echo "###########################################################################################"
echo "Running centrifuge..."
mkdir -p $wd/centrifuge/$profile_level && cd $wd/centrifuge/$profile_level
mkdir -p $wd/centrifuge/$profile_level/$dataset/$samplesID && cd $wd/centrifuge/$profile_level/$dataset/$samplesID

# short
if [ ! -f "centrifuge_query_reads" ] && [ ! -f strain_classification.csv ]; then
    # if [[ $read == *.fq || $read == *.fastq || $read == *.fq.gz || $read == *.fastq.gz ]]; then
    #     if [ $read_type == "long" ]; then
    #         /usr/bin/time -v -o query_time.log $centrifuge -k 1 -x $db -U $read -S centrifuge_query_reads --report-file centrifuge_query_report --threads $threads
    #     elif [ $read_type == "short" ]; then
    #         /usr/bin/time -v -o query_time.log $centrifuge -k 1 -x $db -1 $read1 -2 $read2 -S centrifuge_query_reads --report-file centrifuge_query_report --threads $threads
    #     fi
    # fi
    if [ $read_type == "long" ]; then
        /usr/bin/time -v -o query_time.log $centrifuge -k 1 -x $db -U $read -S centrifuge_query_reads --report-file centrifuge_query_report --threads $threads
    elif [ $read_type == "short" ]; then
        /usr/bin/time -v -o query_time.log $centrifuge -k 1 -x $db -1 $read1 -2 $read2 -S centrifuge_query_reads --report-file centrifuge_query_report --threads $threads
    fi
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
fi
if [ ! -f "evaluation_report.txt" ]; then
    if [ $profile_level == "strain_level" ]; then
        if [ ! -f strain_classification.csv ]; then
            python $scripts_dir/centrifuge_process.py centrifuge_query_reads $genome2seqid
        fi
        python $scripts_dir/strain_abundance_estimate.py -rc strain_classification.csv -rl $read_length -gl $genomes_length_for_strains -s $samplesID -o . -f $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt centrifuge $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simlow-gtdb hifi
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simlow-gtdb
data_type=30
read_type=long
samplesID=hifi
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simlow/hifi/simlow_hifi/2025.01.20_01.11.45_sample_0/reads/anonymous_reads.fq.gz
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
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/centrifuge/gtdb100/centrifuge_db/centrifugeDB
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
genomes_length_for_strains=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genome_statics_gtdb.txt
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/gtdb100_fna_seqID_taxid.txt
# dir
echo "###########################################################################################"
echo "Running centrifuge..."
mkdir -p $wd/centrifuge/$profile_level && cd $wd/centrifuge/$profile_level
mkdir -p $wd/centrifuge/$profile_level/$dataset/$samplesID && cd $wd/centrifuge/$profile_level/$dataset/$samplesID

# long
if [ ! -f "centrifuge_query_reads" ] && [ ! -f strain_classification.csv ]; then
    if [[ $read == *.fa || $read == *.fasta ]]; then
        if [ $read_type == "long" ]; then
            /usr/bin/time -v -o query_time.log $centrifuge -k 1 -x $db -f $read -S centrifuge_query_reads --report-file centrifuge_query_report --threads 64
        fi
    elif [[ $read == *.fq || $read == *.fastq || $read == *.fq.gz || $read == *.fastq.gz ]]; then
        if [ $read_type == "long" ]; then
            /usr/bin/time -v -o query_time.log $centrifuge -k 1 -x $db -U $read -S centrifuge_query_reads --report-file centrifuge_query_report --threads 64
        fi
    fi
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
fi
if [ ! -f "evaluation_report.txt" ]; then
    if [ $profile_level == "strain_level" ]; then
        if [ ! -f strain_classification.csv ]; then
            python $scripts_dir/centrifuge_process.py centrifuge_query_reads $genome2seqid
        fi
        if [ $read_length == "None" ]; then
            python $scripts_dir/get_read_len.py -fq $read -s long
            read_length=long_read_length.txt
        fi
        python $scripts_dir/strain_abundance_estimate.py -rc strain_classification.csv -rl $read_length -gl $genomes_length_for_strains -s $samplesID -o . -f $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt centrifuge $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simlow-gtdb ontR9
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simlow-gtdb
data_type=30
read_type=long
samplesID=ontR9
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simlow/ontR941/simlow_ontR941/2025.01.21_15.37.49_sample_0/reads/anonymous_reads.fq.gz
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
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/centrifuge/gtdb100/centrifuge_db/centrifugeDB
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
genomes_length_for_strains=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genome_statics_gtdb.txt
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/gtdb100_fna_seqID_taxid.txt
# dir
echo "###########################################################################################"
echo "Running centrifuge..."
mkdir -p $wd/centrifuge/$profile_level && cd $wd/centrifuge/$profile_level
mkdir -p $wd/centrifuge/$profile_level/$dataset/$samplesID && cd $wd/centrifuge/$profile_level/$dataset/$samplesID

# long
if [ ! -f "centrifuge_query_reads" ] && [ ! -f strain_classification.csv ]; then
    if [[ $read == *.fa || $read == *.fasta ]]; then
        if [ $read_type == "long" ]; then
            /usr/bin/time -v -o query_time.log $centrifuge -k 1 -x $db -f $read -S centrifuge_query_reads --report-file centrifuge_query_report --threads 64
        fi
    elif [[ $read == *.fq || $read == *.fastq || $read == *.fq.gz || $read == *.fastq.gz ]]; then
        if [ $read_type == "long" ]; then
            /usr/bin/time -v -o query_time.log $centrifuge -k 1 -x $db -U $read -S centrifuge_query_reads --report-file centrifuge_query_report --threads 64
        fi
    fi
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
fi
if [ ! -f "evaluation_report.txt" ]; then
    if [ $profile_level == "strain_level" ]; then
        if [ ! -f strain_classification.csv ]; then
            python $scripts_dir/centrifuge_process.py centrifuge_query_reads $genome2seqid
        fi
        if [ $read_length == "None" ]; then
            python $scripts_dir/get_read_len.py -fq $read -s long
            read_length=long_read_length.txt
        fi
        python $scripts_dir/strain_abundance_estimate.py -rc strain_classification.csv -rl $read_length -gl $genomes_length_for_strains -s $samplesID -o . -f $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt centrifuge $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simlow-gtdb ontR10
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simlow-gtdb
data_type=30
read_type=long
samplesID=ontR10
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simlow/ontR104/simlow_ontR104/2025.01.20_21.47.25_sample_0/reads/anonymous_reads.fq.gz
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
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/centrifuge/gtdb100/centrifuge_db/centrifugeDB
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
genomes_length_for_strains=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genome_statics_gtdb.txt
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/gtdb100_fna_seqID_taxid.txt
# dir
echo "###########################################################################################"
echo "Running centrifuge..."
mkdir -p $wd/centrifuge/$profile_level && cd $wd/centrifuge/$profile_level
mkdir -p $wd/centrifuge/$profile_level/$dataset/$samplesID && cd $wd/centrifuge/$profile_level/$dataset/$samplesID

# long
if [ ! -f "centrifuge_query_reads" ] && [ ! -f strain_classification.csv ]; then
    if [[ $read == *.fa || $read == *.fasta ]]; then
        if [ $read_type == "long" ]; then
            /usr/bin/time -v -o query_time.log $centrifuge -k 1 -x $db -f $read -S centrifuge_query_reads --report-file centrifuge_query_report --threads 64
        fi
    elif [[ $read == *.fq || $read == *.fastq || $read == *.fq.gz || $read == *.fastq.gz ]]; then
        if [ $read_type == "long" ]; then
            /usr/bin/time -v -o query_time.log $centrifuge -k 1 -x $db -U $read -S centrifuge_query_reads --report-file centrifuge_query_report --threads 64
        fi
    fi
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
fi
if [ ! -f "evaluation_report.txt" ]; then
    if [ $profile_level == "strain_level" ]; then
        if [ ! -f strain_classification.csv ]; then
            python $scripts_dir/centrifuge_process.py centrifuge_query_reads $genome2seqid
        fi
        if [ $read_length == "None" ]; then
            python $scripts_dir/get_read_len.py -fq $read -s long
            read_length=long_read_length.txt
        fi
        python $scripts_dir/strain_abundance_estimate.py -rc strain_classification.csv -rl $read_length -gl $genomes_length_for_strains -s $samplesID -o . -f $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt centrifuge $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simlow-gtdb clr
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simlow-gtdb
data_type=30
read_type=long
samplesID=clr
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simlow/clr/simlow_clr/2025.01.20_18.51.40_sample_0/reads/anonymous_reads.fq.gz
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
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/centrifuge/gtdb100/centrifuge_db/centrifugeDB
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
genomes_length_for_strains=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genome_statics_gtdb.txt
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/gtdb100_fna_seqID_taxid.txt
# dir
echo "###########################################################################################"
echo "Running centrifuge..."
mkdir -p $wd/centrifuge/$profile_level && cd $wd/centrifuge/$profile_level
mkdir -p $wd/centrifuge/$profile_level/$dataset/$samplesID && cd $wd/centrifuge/$profile_level/$dataset/$samplesID

# long
if [ ! -f "centrifuge_query_reads" ] && [ ! -f strain_classification.csv ]; then
    if [[ $read == *.fa || $read == *.fasta ]]; then
        if [ $read_type == "long" ]; then
            /usr/bin/time -v -o query_time.log $centrifuge -k 1 -x $db -f $read -S centrifuge_query_reads --report-file centrifuge_query_report --threads 64
        fi
    elif [[ $read == *.fq || $read == *.fastq || $read == *.fq.gz || $read == *.fastq.gz ]]; then
        if [ $read_type == "long" ]; then
            /usr/bin/time -v -o query_time.log $centrifuge -k 1 -x $db -U $read -S centrifuge_query_reads --report-file centrifuge_query_report --threads 64
        fi
    fi
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
fi
if [ ! -f "evaluation_report.txt" ]; then
    if [ $profile_level == "strain_level" ]; then
        if [ ! -f strain_classification.csv ]; then
            python $scripts_dir/centrifuge_process.py centrifuge_query_reads $genome2seqid
        fi
        if [ $read_length == "None" ]; then
            python $scripts_dir/get_read_len.py -fq $read -s long
            read_length=long_read_length.txt
        fi
        python $scripts_dir/strain_abundance_estimate.py -rc strain_classification.csv -rl $read_length -gl $genomes_length_for_strains -s $samplesID -o . -f $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt centrifuge $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
