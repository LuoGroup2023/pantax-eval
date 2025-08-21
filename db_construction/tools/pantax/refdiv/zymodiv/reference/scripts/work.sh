
zymo1_all_genomes_info=/home/work/wenhai/PanTax/genomes_info/multi_species_for_zymo1_genomes_info_sample.txt
zymo1_strain_abund=/home/work/wenhai/dataset/zymo/strain_abundance.txt

wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/zymo1_reference_diversity

mkdir -p $wd/reference/metadata && cd $wd/reference/metadata
python $wd/reference/scripts/zymo1_ref.py $zymo1_all_genomes_info $zymo1_strain_abund

