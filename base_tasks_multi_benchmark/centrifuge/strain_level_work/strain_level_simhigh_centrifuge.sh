
set -e
centrifuge="centrifuge"
tool_name="centrifuge"
threads=64

###### simhigh ngs
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh
data_type=1000
read_type=short
samplesID=ngs
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax/short_read/1000strains/1000_strains_ge1_ngs/2024.02.03_21.19.31_sample_0/reads/anonymous_reads.fq.gz
read1=/home/work/wenhai/simulate_genome_data/PanTax/short_read/1000strains/1000_strains_ge1_ngs/2024.02.03_21.19.31_sample_0/reads/read1.fq
read2=/home/work/wenhai/simulate_genome_data/PanTax/short_read/1000strains/1000_strains_ge1_ngs/2024.02.03_21.19.31_sample_0/reads/read2.fq
camisim_reads_mapping_path=/home/work/wenhai/simulate_genome_data/PanTax/short_read/1000strains/1000_strains_ge1_ngs/2024.02.03_21.19.31_sample_0/reads/reads_mapping.tsv
true_abund=/home/work/wenhai/simulate_genome_data/PanTax/prepare/1000strains/distribution.txt
read_length=150
genome_length=-
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
# dir
echo "###########################################################################################"
echo "Running centrifuge..."
mkdir -p $wd/centrifuge/$profile_level && cd $wd/centrifuge/$profile_level
mkdir -p $wd/centrifuge/$profile_level/$dataset/$samplesID && cd $wd/centrifuge/$profile_level/$dataset/$samplesID

# short
if [ ! -f "centrifuge_query_reads" ] && [ ! -f strain_classification.csv ]; then
    if [[ $read == *.fq || $read == *.fastq || $read == *.fq.gz || $read == *.fastq.gz ]]; then
        if [ $read_type == "long" ]; then
            /usr/bin/time -v -o query_time.log $centrifuge -k 1 -x $db -U $read -S centrifuge_query_reads --report-file centrifuge_query_report --threads $threads
        elif [ $read_type == "short" ]; then
            /usr/bin/time -v -o query_time.log $centrifuge -k 1 -x $db -1 $read1 -2 $read2 -S centrifuge_query_reads --report-file centrifuge_query_report --threads $threads
        fi
    fi
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
fi
if [ ! -f "evaluation_report.txt" ]; then
    if [ $profile_level == "strain_level" ]; then
        if [ ! -f strain_classification.csv ]; then
            python $scripts_dir/centrifuge_process.py centrifuge_query_reads $genome2seqid
        fi
        python $scripts_dir/strain_abundance_estimate.py -rc strain_classification.csv -rl $read_length -gl $genomes_length_for_strains -s $samplesID -o .
        python $scripts_dir/strain_evaluation.py strain_abundance.txt centrifuge $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simhigh hifi
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh
data_type=1000
read_type=long
samplesID=hifi
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax/long_read/new_1000strains/sim-1000strains-ge1-hifi/2024.02.04_21.23.26_sample_0/reads/anonymous_reads.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=/home/work/wenhai/simulate_genome_data/PanTax/long_read/new_1000strains/sim-1000strains-ge1-hifi/2024.02.04_21.23.26_sample_0/reads/reads_mapping.tsv.gz
true_abund=/home/work/wenhai/simulate_genome_data/PanTax/prepare/1000strains/distribution.txt
read_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/read_length/1000strains_hifi_read_length.txt
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
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
        python $scripts_dir/strain_abundance_estimate.py -rc strain_classification.csv -rl $read_length -gl $genomes_length_for_strains -s $samplesID -o .
        python $scripts_dir/strain_evaluation.py strain_abundance.txt centrifuge $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simhigh ontR9
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh
data_type=1000
read_type=long
samplesID=ontR9
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax/long_read/new_1000strains/sim-1000strains-ge1-ontR941raw/2024.06.08_23.57.40_sample_0/reads/anonymous_reads.fq
read1=-
read2=-
camisim_reads_mapping_path=/home/work/wenhai/simulate_genome_data/PanTax/long_read/new_1000strains/sim-1000strains-ge1-ontR941raw/2024.06.08_23.57.40_sample_0/reads/reads_mapping.tsv.gz
true_abund=/home/work/wenhai/simulate_genome_data/PanTax/prepare/1000strains/distribution.txt
read_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/read_length/1000strains_ontR941_read_length.txt
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
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
        python $scripts_dir/strain_abundance_estimate.py -rc strain_classification.csv -rl $read_length -gl $genomes_length_for_strains -s $samplesID -o .
        python $scripts_dir/strain_evaluation.py strain_abundance.txt centrifuge $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simhigh ontR10
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh
data_type=1000
read_type=long
samplesID=ontR10
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax/long_read/new_1000strains/sim-1000strains-ge1-ontR104raw/2024.02.04_16.11.39_sample_0/reads/anonymous_reads.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=/home/work/wenhai/simulate_genome_data/PanTax/long_read/new_1000strains/sim-1000strains-ge1-ontR104raw/2024.02.04_16.11.39_sample_0/reads/reads_mapping.tsv.gz
true_abund=/home/work/wenhai/simulate_genome_data/PanTax/prepare/1000strains/distribution.txt
read_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/read_length/1000strains_ontR104_read_length.txt
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
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
        python $scripts_dir/strain_abundance_estimate.py -rc strain_classification.csv -rl $read_length -gl $genomes_length_for_strains -s $samplesID -o .
        python $scripts_dir/strain_evaluation.py strain_abundance.txt centrifuge $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simhigh clr
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh
data_type=1000
read_type=long
samplesID=clr
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax/long_read/new_1000strains/sim-1000strains-ge1-CLR/2024.02.03_21.18.55_sample_0/reads/anonymous_reads.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=/home/work/wenhai/simulate_genome_data/PanTax/long_read/new_1000strains/sim-1000strains-ge1-CLR/2024.02.03_21.18.55_sample_0/reads/reads_mapping.tsv.gz
true_abund=/home/work/wenhai/simulate_genome_data/PanTax/prepare/1000strains/distribution.txt
read_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/read_length/1000strains_CLR_read_length.txt
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
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
        python $scripts_dir/strain_abundance_estimate.py -rc strain_classification.csv -rl $read_length -gl $genomes_length_for_strains -s $samplesID -o .
        python $scripts_dir/strain_evaluation.py strain_abundance.txt centrifuge $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
