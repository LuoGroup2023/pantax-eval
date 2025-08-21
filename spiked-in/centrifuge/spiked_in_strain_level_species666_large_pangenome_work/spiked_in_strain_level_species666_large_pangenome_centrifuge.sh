
set -e
centrifuge="centrifuge"
tool_name="centrifuge"
threads=64

###### spiked_in_single_species666_large_pangenome ngs
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=spiked_in_single_species666_large_pangenome
data_type=-1
read_type=short
samplesID=ngs
profile_level=strain_level
read=None
read1=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/single/sim_species666_single_ngs/2024.12.20_10.36.02_sample_0/reads/shuffle_spiked_in_ngs_1.fq
read2=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/single/sim_species666_single_ngs/2024.12.20_10.36.02_sample_0/reads/shuffle_spiked_in_ngs_2.fq
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/single/sim_species666_single_ngs/distributions/distribution_0.txt
read_length=150
genome_length=-
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
designated_genomes_info=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/scripts/genomes_info.txt
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
###### spiked_in_single_species666_large_pangenome hifi
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=spiked_in_single_species666_large_pangenome
data_type=-1
read_type=long
samplesID=hifi
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/single/sim_species666_single_hifi/2024.12.20_11.58.09_sample_0/reads/shuffle_spiked_in_hifi.fq
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/single/sim_species666_single_ngs/distributions/distribution_0.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
designated_genomes_info=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/scripts/genomes_info.txt
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
###### spiked_in_three_species666_large_pangenome ngs
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=spiked_in_three_species666_large_pangenome
data_type=-1
read_type=short
samplesID=ngs
profile_level=strain_level
read=None
read1=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/three/sim_species666_three_ngs/2024.12.20_10.52.07_sample_0/reads/shuffle_spiked_in_ngs_1.fq
read2=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/three/sim_species666_three_ngs/2024.12.20_10.52.07_sample_0/reads/shuffle_spiked_in_ngs_2.fq
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/three/metadata/distribution.txt
read_length=150
genome_length=-
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
designated_genomes_info=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/scripts/genomes_info.txt
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
###### spiked_in_three_species666_large_pangenome hifi
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=spiked_in_three_species666_large_pangenome
data_type=-1
read_type=long
samplesID=hifi
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/three/sim_species666_three_hifi/2024.12.20_11.58.51_sample_0/reads/shuffle_spiked_in_hifi.fq
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/three/metadata/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
designated_genomes_info=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/scripts/genomes_info.txt
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
###### spiked_in_five_species666_large_pangenome ngs
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=spiked_in_five_species666_large_pangenome
data_type=-1
read_type=short
samplesID=ngs
profile_level=strain_level
read=None
read1=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/five/sim_species666_five_ngs/2024.12.20_11.05.25_sample_0/reads/shuffle_spiked_in_ngs_1.fq
read2=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/five/sim_species666_five_ngs/2024.12.20_11.05.25_sample_0/reads/shuffle_spiked_in_ngs_2.fq
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/five/metadata/distribution.txt
read_length=150
genome_length=-
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
designated_genomes_info=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/scripts/genomes_info.txt
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
###### spiked_in_five_species666_large_pangenome hifi
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=spiked_in_five_species666_large_pangenome
data_type=-1
read_type=long
samplesID=hifi
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/five/sim_species666_five_hifi/2024.12.20_11.59.28_sample_0/reads/shuffle_spiked_in_hifi.fq
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/five/metadata/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
designated_genomes_info=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/scripts/genomes_info.txt
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
###### spiked_in_ten_species666_large_pangenome ngs
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=spiked_in_ten_species666_large_pangenome
data_type=-1
read_type=short
samplesID=ngs
profile_level=strain_level
read=None
read1=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/ten/sim_species666_ten_ngs/2024.12.20_11.11.20_sample_0/reads/shuffle_spiked_in_ngs_1.fq
read2=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/ten/sim_species666_ten_ngs/2024.12.20_11.11.20_sample_0/reads/shuffle_spiked_in_ngs_2.fq
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/ten/metadata/distribution.txt
read_length=150
genome_length=-
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
designated_genomes_info=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/scripts/genomes_info.txt
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
###### spiked_in_ten_species666_large_pangenome hifi
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=spiked_in_ten_species666_large_pangenome
data_type=-1
read_type=long
samplesID=hifi
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/ten/sim_species666_ten_hifi/2024.12.20_12.00.01_sample_0/reads/shuffle_spiked_in_hifi.fq
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/ten/metadata/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
designated_genomes_info=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/scripts/genomes_info.txt
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
###### spiked_in_eight_species666_large_pangenome ngs
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=spiked_in_eight_species666_large_pangenome
data_type=-1
read_type=short
samplesID=ngs
profile_level=strain_level
read=None
read1=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/eight/sim_species666_eight_ngs/2024.12.26_16.58.02_sample_0/reads/shuffle_spiked_in_ngs_1.fq
read2=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/eight/sim_species666_eight_ngs/2024.12.26_16.58.02_sample_0/reads/shuffle_spiked_in_ngs_2.fq
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/eight/metadata/distribution.txt
read_length=150
genome_length=-
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
designated_genomes_info=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/scripts/genomes_info.txt
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
###### spiked_in_eight_species666_large_pangenome hifi
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=spiked_in_eight_species666_large_pangenome
data_type=-1
read_type=long
samplesID=hifi
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/eight/sim_species666_eight_hifi/2024.12.26_17.45.32_sample_0/reads/shuffle_spiked_in_hifi.fq
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/eight/metadata/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
designated_genomes_info=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/scripts/genomes_info.txt
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
###### spiked_in_eight_species666_large_pangenome ontR9
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=spiked_in_eight_species666_large_pangenome
data_type=-1
read_type=long
samplesID=ontR9
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/eight/sim_species666_eight_ontr9/2024.12.26_18.34.32_sample_0/reads/shuffle_spiked_in_ontr9.fq
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/eight/metadata/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
designated_genomes_info=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/scripts/genomes_info.txt
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
###### spiked_in_eight_species666_large_pangenome ontR10
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=spiked_in_eight_species666_large_pangenome
data_type=-1
read_type=long
samplesID=ontR10
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/eight/sim_species666_eight_ontr10/2024.12.26_18.40.36_sample_0/reads/shuffle_spiked_in_ontr10.fq
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/eight/metadata/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
designated_genomes_info=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/scripts/genomes_info.txt
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
###### spiked_in_eight_species666_large_pangenome clr
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=spiked_in_eight_species666_large_pangenome
data_type=-1
read_type=long
samplesID=clr
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/eight/sim_species666_eight_clr/2024.12.26_18.11.55_sample_0/reads/shuffle_spiked_in_clr.fq
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/eight/metadata/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/centrifuge_2/Centrifuge_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
designated_genomes_info=/home/work/wenhai/simulate_genome_data/PanTax_species_666_for_large_pangenome/scripts/genomes_info.txt
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
