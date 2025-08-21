
set -e
ganon="ganon"
tool_name="ganon"
threads=64

###### simhigh-gtdb-mut0.01 ngs
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-gtdb-mut0.01
data_type=1000
read_type=short
samplesID=ngs
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simhigh_mut0.01/ngs/simhigh_mut0.01_ngs/2025.02.28_23.39.33_sample_0/reads/anonymous_reads.fq.gz
read1=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simhigh_mut0.01/ngs/simhigh_mut0.01_ngs/2025.02.28_23.39.33_sample_0/reads/read1.fq
read2=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simhigh_mut0.01/ngs/simhigh_mut0.01_ngs/2025.02.28_23.39.33_sample_0/reads/read2.fq
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/prepare/simhigh/distribution.txt
read_length=150
genome_length=-
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/ganon/gtdb100/ganon_db
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# short
if [ ! -f results.rep ]; then
    /usr/bin/time -v -o query_time.log $ganon classify --db-prefix $db --paired-reads $read1 $read2 --output-prefix results --report-type abundance -t $threads || true
fi
if [ -f results.all ] && [ ! -s results.all ]; then
    echo "all reads unclassified"
elif [ ! -f "evaluation_report.txt" ]; then
    $ganon report -i results.rep --db-prefix $db --output-prefix tax_profile --report-type abundance -r all
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/ganon_strain_process.py tax_profile.tre $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simhigh-gtdb-mut0.01 hifi
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-gtdb-mut0.01
data_type=1000
read_type=long
samplesID=hifi
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simhigh_mut0.01/hifi/simhigh_mut0.01_hifi/2025.02.28_23.36.57_sample_0/reads/anonymous_reads.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/prepare/simhigh/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/ganon/gtdb100/ganon_db
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f results.rep ]; then
    /usr/bin/time -v -o query_time.log $ganon classify --db-prefix $db -s $read --output-prefix results --report-type abundance -t $threads || true
fi
if [ -f results.all ] && [ ! -s results.all ]; then
    echo "all reads unclassified"
elif [ ! -f "evaluation_report.txt" ]; then
    $ganon report -i results.rep --db-prefix $db --output-prefix tax_profile --report-type abundance -r all
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    if [ $profile_level == "strain_level" ]; then
        if [ $read_length == "None" ]; then
            python $scripts_dir/get_read_len.py -fq $read -s long
            read_length=long_read_length.txt
        fi
        python $scripts_dir/ganon_strain_process.py tax_profile.tre $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simhigh-gtdb-mut0.01 ontR9
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-gtdb-mut0.01
data_type=1000
read_type=long
samplesID=ontR9
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simhigh_mut0.01/ontR941/simhigh_mut0.01_ontR941/2025.02.28_23.40.16_sample_0/reads/anonymous_reads.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/prepare/simhigh/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/ganon/gtdb100/ganon_db
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f results.rep ]; then
    /usr/bin/time -v -o query_time.log $ganon classify --db-prefix $db -s $read --output-prefix results --report-type abundance -t $threads || true
fi
if [ -f results.all ] && [ ! -s results.all ]; then
    echo "all reads unclassified"
elif [ ! -f "evaluation_report.txt" ]; then
    $ganon report -i results.rep --db-prefix $db --output-prefix tax_profile --report-type abundance -r all
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    if [ $profile_level == "strain_level" ]; then
        if [ $read_length == "None" ]; then
            python $scripts_dir/get_read_len.py -fq $read -s long
            read_length=long_read_length.txt
        fi
        python $scripts_dir/ganon_strain_process.py tax_profile.tre $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simhigh-gtdb-mut0.01 ontR10
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-gtdb-mut0.01
data_type=1000
read_type=long
samplesID=ontR10
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simhigh_mut0.01/ontR104/simhigh_mut0.01_ontR104/2025.03.03_01.49.48_sample_0/reads/anonymous_reads.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/prepare/simhigh/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/ganon/gtdb100/ganon_db
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f results.rep ]; then
    /usr/bin/time -v -o query_time.log $ganon classify --db-prefix $db -s $read --output-prefix results --report-type abundance -t $threads || true
fi
if [ -f results.all ] && [ ! -s results.all ]; then
    echo "all reads unclassified"
elif [ ! -f "evaluation_report.txt" ]; then
    $ganon report -i results.rep --db-prefix $db --output-prefix tax_profile --report-type abundance -r all
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    if [ $profile_level == "strain_level" ]; then
        if [ $read_length == "None" ]; then
            python $scripts_dir/get_read_len.py -fq $read -s long
            read_length=long_read_length.txt
        fi
        python $scripts_dir/ganon_strain_process.py tax_profile.tre $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simhigh-gtdb-mut0.01 clr
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-gtdb-mut0.01
data_type=1000
read_type=long
samplesID=clr
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/simhigh_mut0.01/clr/simhigh_mut0.01_clr/2025.02.28_23.39.14_sample_0/reads/anonymous_reads.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax_GTDB_1w/prepare/simhigh/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/ganon/gtdb100/ganon_db
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f results.rep ]; then
    /usr/bin/time -v -o query_time.log $ganon classify --db-prefix $db -s $read --output-prefix results --report-type abundance -t $threads || true
fi
if [ -f results.all ] && [ ! -s results.all ]; then
    echo "all reads unclassified"
elif [ ! -f "evaluation_report.txt" ]; then
    $ganon report -i results.rep --db-prefix $db --output-prefix tax_profile --report-type abundance -r all
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    if [ $profile_level == "strain_level" ]; then
        if [ $read_length == "None" ]; then
            python $scripts_dir/get_read_len.py -fq $read -s long
            read_length=long_read_length.txt
        fi
        python $scripts_dir/ganon_strain_process.py tax_profile.tre $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
