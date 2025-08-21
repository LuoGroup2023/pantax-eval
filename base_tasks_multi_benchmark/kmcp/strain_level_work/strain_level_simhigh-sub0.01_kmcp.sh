
set -e
kmcp="kmcp"
tool_name="kmcp"
threads=64

###### simhigh-sub0.01 ngs
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-sub0.01
data_type=1000
read_type=short
samplesID=ngs
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_mutation/simhigh/ngs/mut_rate0.01/simhigh-ngs-mut_rate0.01.fq.gz
read1=/home/work/wenhai/simulate_genome_data/PanTax_mutation/simhigh/ngs/mut_rate0.01/read1.fq
read2=/home/work/wenhai/simulate_genome_data/PanTax_mutation/simhigh/ngs/mut_rate0.01/read2.fq
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax/prepare/1000strains/distribution.txt
read_length=150
genome_length=-
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kmcp/kmcpDB/kmcp_refs_k21.kmcp
tax2genome=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/kraken2_strain_taxid.tsv
strain_taxonomy=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/kraken2_db/taxonomy
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# short
if [ ! -f result.kmcp.gz ]; then
    /usr/bin/time -v -o query_time.log $kmcp search --db-dir $db -1 $read1 -2 $read2 --out-file result.kmcp.gz --log result.kmcp.gz.log -j $threads
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
fi
if [ ! -f result.kmcp.profile ] && [ ! -f result.kmcp.profile.log ]; then
    awk -F'\t' 'NR>1 {print $3,$1}' OFS='\t' $tax2genome > taxid.map
    $kmcp profile --taxid-map taxid.map --taxdump $strain_taxonomy result.kmcp.gz --out-file result.kmcp.profile --metaphlan-report result.metaphlan.profile --sample-id 0 --cami-report result.cami.profile --binning-result result.binning.gz --log result.kmcp.profile.log --level strain
fi
if [ ! -f "evaluation_report.txt" ] && [ -f result.kmcp.profile ]; then
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/kmcp_strain_process.py result.kmcp.profile $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
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
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kmcp/kmcpDB/kmcp_refs_k21.kmcp
tax2genome=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/kraken2_strain_taxid.tsv
strain_taxonomy=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/kraken2_db/taxonomy
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f result.kmcp.gz ]; then
    /usr/bin/time -v -o query_time.log $kmcp search --db-dir $db $read --out-file result.kmcp.gz --log result.kmcp.gz.log -j $threads
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
fi
if [ ! -f result.kmcp.profile ] && [ ! -f result.kmcp.profile.log ]; then
    awk -F'\t' 'NR>1 {print $3,$1}' OFS='\t' $tax2genome > taxid.map
    $kmcp profile --taxid-map taxid.map --taxdump $strain_taxonomy result.kmcp.gz --out-file result.kmcp.profile --metaphlan-report result.metaphlan.profile --sample-id 0 --cami-report result.cami.profile --binning-result result.binning.gz --log result.kmcp.profile.log --level strain
fi
if [ ! -f "evaluation_report.txt" ] && [ -f result.kmcp.profile ] && [ $(wc -l < result.kmcp.profile) -gt 1 ]; then
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/kmcp_strain_process.py result.kmcp.profile $designated_genomes_info
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
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kmcp/kmcpDB/kmcp_refs_k21.kmcp
tax2genome=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/kraken2_strain_taxid.tsv
strain_taxonomy=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/kraken2_db/taxonomy
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f result.kmcp.gz ]; then
    /usr/bin/time -v -o query_time.log $kmcp search --db-dir $db $read --out-file result.kmcp.gz --log result.kmcp.gz.log -j $threads
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
fi
if [ ! -f result.kmcp.profile ] && [ ! -f result.kmcp.profile.log ]; then
    awk -F'\t' 'NR>1 {print $3,$1}' OFS='\t' $tax2genome > taxid.map
    $kmcp profile --taxid-map taxid.map --taxdump $strain_taxonomy result.kmcp.gz --out-file result.kmcp.profile --metaphlan-report result.metaphlan.profile --sample-id 0 --cami-report result.cami.profile --binning-result result.binning.gz --log result.kmcp.profile.log --level strain
fi
if [ ! -f "evaluation_report.txt" ] && [ -f result.kmcp.profile ] && [ $(wc -l < result.kmcp.profile) -gt 1 ]; then
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/kmcp_strain_process.py result.kmcp.profile $designated_genomes_info
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
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kmcp/kmcpDB/kmcp_refs_k21.kmcp
tax2genome=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/kraken2_strain_taxid.tsv
strain_taxonomy=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/kraken2_db/taxonomy
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f result.kmcp.gz ]; then
    /usr/bin/time -v -o query_time.log $kmcp search --db-dir $db $read --out-file result.kmcp.gz --log result.kmcp.gz.log -j $threads
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
fi
if [ ! -f result.kmcp.profile ] && [ ! -f result.kmcp.profile.log ]; then
    awk -F'\t' 'NR>1 {print $3,$1}' OFS='\t' $tax2genome > taxid.map
    $kmcp profile --taxid-map taxid.map --taxdump $strain_taxonomy result.kmcp.gz --out-file result.kmcp.profile --metaphlan-report result.metaphlan.profile --sample-id 0 --cami-report result.cami.profile --binning-result result.binning.gz --log result.kmcp.profile.log --level strain
fi
if [ ! -f "evaluation_report.txt" ] && [ -f result.kmcp.profile ] && [ $(wc -l < result.kmcp.profile) -gt 1 ]; then
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/kmcp_strain_process.py result.kmcp.profile $designated_genomes_info
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
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kmcp/kmcpDB/kmcp_refs_k21.kmcp
tax2genome=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/kraken2_strain_taxid.tsv
strain_taxonomy=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/kraken2_db/taxonomy
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f result.kmcp.gz ]; then
    /usr/bin/time -v -o query_time.log $kmcp search --db-dir $db $read --out-file result.kmcp.gz --log result.kmcp.gz.log -j $threads
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
fi
if [ ! -f result.kmcp.profile ] && [ ! -f result.kmcp.profile.log ]; then
    awk -F'\t' 'NR>1 {print $3,$1}' OFS='\t' $tax2genome > taxid.map
    $kmcp profile --taxid-map taxid.map --taxdump $strain_taxonomy result.kmcp.gz --out-file result.kmcp.profile --metaphlan-report result.metaphlan.profile --sample-id 0 --cami-report result.cami.profile --binning-result result.binning.gz --log result.kmcp.profile.log --level strain
fi
if [ ! -f "evaluation_report.txt" ] && [ -f result.kmcp.profile ] && [ $(wc -l < result.kmcp.profile) -gt 1 ]; then
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/kmcp_strain_process.py result.kmcp.profile $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
