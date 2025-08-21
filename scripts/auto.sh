# sylph
python auto_pipline.py dataset=simlow,simhigh tools=sylph strain_level=true -m
python auto_pipline.py tools=sylph dataset=simlow-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=sylph dataset=simlow-sub0.001 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=sylph dataset=simlow-low strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=sylph dataset=zymo1 strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=sylph dataset=zymo1-log strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true

# kraken2
python auto_pipline.py dataset=simlow,simhigh tools=kraken2 strain_level=true -m
python auto_pipline.py tools=kraken2 dataset=zymo1 strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=kraken2 dataset=zymo1-log strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=kraken2 dataset=simlow-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=kraken2 dataset=simlow-sub0.001 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=kraken2 dataset=simhigh-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=kraken2 dataset=simhigh-sub0.001 strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=kraken2 dataset=simlow-subsample0.1 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=kraken2 dataset=simlow-subsample0.2 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=kraken2 dataset=simlow-subsample0.5 strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=kraken2 dataset=simlow-low strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=kraken2 dataset=simlow-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=kraken2 dataset=simhigh-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=kraken2 dataset=simlow-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=kraken2 dataset=simhigh-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true

python auto_pipline.py tools=kraken2 dataset=spiked_in_single_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome 
python auto_pipline.py tools=kraken2 dataset=spiked_in_three_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome 
python auto_pipline.py tools=kraken2 dataset=spiked_in_five_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome 
python auto_pipline.py tools=kraken2 dataset=spiked_in_ten_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome 
python auto_pipline.py tools=kraken2 dataset=spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome

python auto_pipline.py tools=kraken2 dataset=low_spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/low_single_species_strain_level_666_large_pangenome

python auto_pipline.py tools=kraken2 dataset=spiked_in_single spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=kraken2 dataset=spiked_in_three spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=kraken2 dataset=spiked_in_five spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=kraken2 dataset=spiked_in_ten spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 


# bracken
python auto_pipline.py tools=bracken dataset=simlow,simhigh strain_level=true -m
python auto_pipline.py tools=bracken dataset=zymo1 strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=bracken dataset=zymo1-log strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=bracken dataset=simlow-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=bracken dataset=simlow-sub0.001 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=bracken dataset=simhigh-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=bracken dataset=simhigh-sub0.001 strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=bracken dataset=simlow-subsample0.1 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=bracken dataset=simlow-subsample0.2 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=bracken dataset=simlow-subsample0.5 strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=bracken dataset=simlow-low strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=bracken dataset=simlow-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=bracken dataset=simhigh-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=bracken dataset=simlow-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=bracken dataset=simhigh-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true

python auto_pipline.py tools=bracken dataset=spiked_in_single_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome 
python auto_pipline.py tools=bracken dataset=spiked_in_three_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome 
python auto_pipline.py tools=bracken dataset=spiked_in_five_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome 
python auto_pipline.py tools=bracken dataset=spiked_in_ten_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome 
python auto_pipline.py tools=bracken dataset=spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome

python auto_pipline.py tools=bracken dataset=low_spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/low_single_species_strain_level_666_large_pangenome

python auto_pipline.py tools=bracken dataset=spiked_in_single spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=bracken dataset=spiked_in_three spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=bracken dataset=spiked_in_five spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=bracken dataset=spiked_in_ten spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 


# centrifuge
python auto_pipline.py tools=centrifuge dataset=simlow,simhigh strain_level=true -m
python auto_pipline.py tools=centrifuge dataset=zymo1 isolate=true rebuild=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=centrifuge dataset=zymo1-log strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=centrifuge dataset=simlow-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=centrifuge dataset=simlow-sub0.001 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=centrifuge dataset=simhigh-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=centrifuge dataset=simhigh-sub0.001 strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=centrifuge dataset=simlow-subsample0.1 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=centrifuge dataset=simlow-subsample0.2 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=centrifuge dataset=simlow-subsample0.5 strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=centrifuge dataset=simlow-low strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=centrifuge dataset=simlow-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=centrifuge dataset=simhigh-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=centrifuge dataset=simlow-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=centrifuge dataset=simhigh-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true

python auto_pipline.py tools=centrifuge dataset=spiked_in_single_species666_large_pangenome,spiked_in_three_species666_large_pangenome,spiked_in_five_species666_large_pangenome,spiked_in_ten_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome -m
python auto_pipline.py tools=centrifuge dataset=spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome

python auto_pipline.py tools=centrifuge dataset=low_spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/low_single_species_strain_level_666_large_pangenome

# centrifuger
python auto_pipline.py tools=centrifuger dataset=simlow,simhigh strain_level=true -m
python auto_pipline.py tools=centrifuger dataset=zymo1 strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=centrifuger dataset=zymo1-log strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true

python auto_pipline.py tools=centrifuger dataset=simlow-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=centrifuger dataset=simlow-sub0.001 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=centrifuger dataset=simhigh-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=centrifuger dataset=simhigh-sub0.001 strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=centrifuger dataset=simlow-subsample0.1 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=centrifuger dataset=simlow-subsample0.2 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=centrifuger dataset=simlow-subsample0.5 strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=centrifuger dataset=simlow-low strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=centrifuger dataset=simlow-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=centrifuger dataset=simhigh-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=centrifuger dataset=simlow-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=centrifuger dataset=simhigh-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true

python auto_pipline.py tools=centrifuger dataset=spiked_in_single_species666_large_pangenome,spiked_in_three_species666_large_pangenome,spiked_in_five_species666_large_pangenome,spiked_in_ten_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome -m
python auto_pipline.py tools=centrifuger dataset=spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome

python auto_pipline.py tools=centrifuger dataset=low_spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/low_single_species_strain_level_666_large_pangenome

python auto_pipline.py tools=centrifuger dataset=spiked_in_single spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=centrifuger dataset=spiked_in_three spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=centrifuger dataset=spiked_in_five spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=centrifuger dataset=spiked_in_ten spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 


# metamaps
python auto_pipline.py tools=metamaps dataset=simlow,simhigh strain_level=true -m
python auto_pipline.py tools=metamaps dataset=zymo1 rebuild=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=metamaps dataset=zymo1-log strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true

python auto_pipline.py tools=metamaps dataset=simlow-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=metamaps dataset=simlow-sub0.001 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=metamaps dataset=simhigh-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=metamaps dataset=simhigh-sub0.001 strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=metamaps dataset=simlow-subsample0.1 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=metamaps dataset=simlow-subsample0.2 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=metamaps dataset=simlow-subsample0.5 strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=metamaps dataset=simlow-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=metamaps dataset=simhigh-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=metamaps dataset=simlow-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=metamaps dataset=simhigh-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true

python auto_pipline.py tools=metamaps dataset=spiked_in_single_species666_large_pangenome,spiked_in_three_species666_large_pangenome,spiked_in_five_species666_large_pangenome,spiked_in_ten_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome -m
python auto_pipline.py tools=metamaps dataset=spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome

python auto_pipline.py tools=metamaps dataset=low_spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/low_single_species_strain_level_666_large_pangenome

python auto_pipline.py tools=metamaps dataset=spiked_in_single spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=metamaps dataset=spiked_in_three spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=metamaps dataset=spiked_in_five spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=metamaps dataset=spiked_in_ten spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 


# pantax
python auto_pipline.py tools=pantax dataset=simlow,simhigh strain_level=true -m
python auto_pipline.py tools=pantax dataset=zymo1 zymo1_strain_level=true strain_level=false 

python auto_pipline.py tools=pantax dataset=simlow-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=pantax dataset=simhigh-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=pantax dataset=simlow-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=pantax dataset=simhigh-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true

# python auto_pipline.py tools=pantax dataset=simlow-low strain_level=true isolate=true rebuild=true

# python auto_pipline.py tools=pantax dataset=simlow-subsample0.1 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=pantax dataset=simlow-subsample0.2 strain_level=true isolate=true rebuild=true
# python auto_pipline.py tools=pantax dataset=simlow-subsample0.3 strain_level=true isolate=true rebuild=true tool.extra_strain_profiling_paras="-fr 0 -fc 1"
# python auto_pipline.py tools=pantax dataset=simlow-subsample0.4 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=pantax dataset=simlow-subsample0.5 strain_level=true isolate=true rebuild=true

# python auto_pipline.py tools=sylph-pantax-95-simlow dataset=simlow strain_level=true 
# python auto_pipline.py tools=sylph-pantax-95-simhigh dataset=simhigh strain_level=true 
# python auto_pipline.py tools=sylph-pantax-96-simlow dataset=simlow strain_level=true
# python auto_pipline.py tools=sylph-pantax-96-simhigh dataset=simhigh strain_level=true
# python auto_pipline.py tools=sylph-pantax-97-simlow dataset=simlow strain_level=true
# python auto_pipline.py tools=sylph-pantax-97-simhigh dataset=simhigh strain_level=true
# python auto_pipline.py tools=sylph-pantax-98-simlow dataset=simlow strain_level=true
# python auto_pipline.py tools=sylph-pantax-98-simhigh dataset=simhigh strain_level=true
# python auto_pipline.py tools=sylph-pantax-99-simlow dataset=simlow strain_level=true
# python auto_pipline.py tools=sylph-pantax-99-simhigh dataset=simhigh strain_level=true


python auto_pipline.py tools=pantax dataset=simlow-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=pantax dataset=simlow-sub0.001 strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=pantax dataset=simhigh-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=pantax dataset=simhigh-sub0.001 strain_level=true isolate=true rebuild=true

# python auto_pipline.py tools=pantax dataset=test_simlow_add_eq2 strain_level=true isolate=true rebuild=true

# python auto_pipline.py tools=pantax dataset=low_spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/low_single_species_strain_level_666_large_pangenome
python auto_pipline.py tools=pantax dataset=spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome

# python auto_pipline.py tools=pantax dataset=spiked_in_single_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome 
# python auto_pipline.py tools=pantax dataset=spiked_in_three_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome 
# python auto_pipline.py tools=pantax dataset=spiked_in_five_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome 
# python auto_pipline.py tools=pantax dataset=spiked_in_ten_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome 

# python auto_pipline.py tools=pantax dataset=spiked_in_single spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
# python auto_pipline.py tools=pantax dataset=spiked_in_three spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
# python auto_pipline.py tools=pantax dataset=spiked_in_five spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
# python auto_pipline.py tools=pantax dataset=spiked_in_ten spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 

#pantax version2
python auto_pipline.py tools=pantax dataset=simlow strain_level=true isolate=true rebuild=true tool.version=2 tool.graph_parsing_format=h5
python auto_pipline.py tools=pantax dataset=simhigh strain_level=true isolate=true rebuild=true tool.version=2 tool.graph_parsing_format=h5
python auto_pipline.py tools=pantax dataset=zymo1 zymo1_strain_level=true isolate=true strain_level=false tool.version=2 tool.graph_parsing_format=h5 tool.extra_strain_profiling_paras="-gt 64"
python auto_pipline.py tools=pantax dataset=zymo1-log zymo1_strain_level=true isolate=true rebuild=true strain_level=false tool.version=2 tool.extra_strain_profiling_paras="-fr 0 -fc 1 -a 0 -gt 64"
python auto_pipline.py tools=pantax dataset=zymo1-log zymo1_strain_level=true isolate=true rebuild=true strain_level=false tool.version=2 tool.extra_strain_profiling_paras="-a 0 -gt 64"
python auto_pipline.py tools=pantax dataset=zymo1-log-sub strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true tool.version=2
python auto_pipline.py tools=pantax dataset=zymo1-log-sub2 strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true tool.version=2
python auto_pipline.py tools=pantax dataset=zymo1-log-sub3 strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true tool.version=2

python auto_pipline.py tools=pantax dataset=simhigh1000 strain_level=true isolate=true rebuild=true tool.version=2
python auto_pipline.py tools=pantax dataset=simhigh2000 strain_level=true isolate=true rebuild=true tool.version=2
python auto_pipline.py tools=pantax dataset=simhigh3000 strain_level=true isolate=true rebuild=true tool.version=2
python auto_pipline.py tools=pantax dataset=simhigh4000 strain_level=true isolate=true rebuild=true tool.version=2

python auto_pipline.py tools=pantax dataset=simlow-sub0.01 strain_level=true isolate=true rebuild=true tool.version=2 tool.graph_parsing_format=h5
python auto_pipline.py tools=pantax dataset=simlow-sub0.001 strain_level=true isolate=true rebuild=true tool.version=2 tool.graph_parsing_format=h5
python auto_pipline.py tools=pantax dataset=simhigh-sub0.01 strain_level=true isolate=true rebuild=true tool.version=2 tool.graph_parsing_format=h5
python auto_pipline.py tools=pantax dataset=simhigh-sub0.001 strain_level=true isolate=true rebuild=true tool.version=2 tool.graph_parsing_format=h5

python auto_pipline.py tools=pantax dataset=simlow-subsample0.2 strain_level=true isolate=true rebuild=true tool.version=2 tool.graph_parsing_format=h5 tool.extra_strain_profiling_paras="-fr 0 -fc 1"
python auto_pipline.py tools=pantax dataset=simlow-subsample0.5 strain_level=true isolate=true rebuild=true tool.version=2 tool.graph_parsing_format=h5 tool.extra_strain_profiling_paras="-fr 0 -fc 1"

python auto_pipline.py tools=pantax dataset=spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome tool.version=2 tool.mode=0

python auto_pipline.py tools=pantax dataset=simlow-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true tool.version=2 tool.graph_parsing_format=h5 tool.mode=1
python auto_pipline.py tools=pantax dataset=simhigh-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true tool.version=2 tool.graph_parsing_format=h5 tool.mode=1
python auto_pipline.py tools=pantax dataset=simlow-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true tool.version=2 tool.graph_parsing_format=h5 tool.mode=1
python auto_pipline.py tools=pantax dataset=simhigh-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true tool.version=2 tool.graph_parsing_format=h5 tool.mode=1

python auto_pipline.py tools=pantax dataset=spiked_in_single spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 tool.version=2 tool.mode=0 tool.extra_strain_profiling_paras="-fr 0.3" tool.graph_parsing_format=lz
python auto_pipline.py tools=pantax dataset=spiked_in_three spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 tool.version=2 tool.mode=0 tool.extra_strain_profiling_paras="-fr 0.3" tool.graph_parsing_format=lz
python auto_pipline.py tools=pantax dataset=spiked_in_five spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 tool.version=2 tool.mode=0 tool.extra_strain_profiling_paras="-fr 0.3" tool.graph_parsing_format=lz
python auto_pipline.py tools=pantax dataset=spiked_in_ten spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 tool.version=2 tool.mode=0 tool.extra_strain_profiling_paras="-fr 0.3" tool.graph_parsing_format=lz


# sensitivity_analysis
for dst in simlow simhigh; do
    python auto_pipline.py tools=pantax dataset=$dst strain_level=true isolate=true rebuild=true tool.version=2 tool.read_type=[short] tool.mode=0 tool.sensitivity_analysis=true tool.sensitivity_analysis_low=true tool.sensitivity_analysis_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/sensitivity_analysis
    for long_read_type in hifi clr ontR9 ontR10; do
        python auto_pipline.py tools=pantax dataset=$dst strain_level=true isolate=true rebuild=true tool.version=2 tool.read_type=[long] dataset.samplesID.long=[$long_read_type] tool.mode=0 tool.sensitivity_analysis=true tool.sensitivity_analysis_low=true tool.sensitivity_analysis_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/sensitivity_analysis 
    done
done

for dst in zymo1; do
    python auto_pipline.py tools=pantax dataset=$dst zymo1_strain_level=true isolate=true strain_level=false rebuild=true tool.version=2 tool.read_type=[short] tool.mode=0 tool.sensitivity_analysis=true tool.sensitivity_analysis_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/sensitivity_analysis tool.extra_strain_profiling_paras="-gt 64"
    for long_read_type in ontR9 ontR10; do
        python auto_pipline.py tools=pantax dataset=$dst zymo1_strain_level=true isolate=true strain_level=false rebuild=true tool.version=2 tool.read_type=[long] dataset.samplesID.long=[$long_read_type] tool.mode=0 tool.sensitivity_analysis=true tool.sensitivity_analysis_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/sensitivity_analysis tool.extra_strain_profiling_paras="-gt 64"
    done
done

# rescue_sensitivity_analysis
for dst in simlow simhigh; do
    python auto_pipline.py tools=pantax dataset=$dst strain_level=true isolate=true rebuild=true tool.version=2 tool.read_type=[short] tool.mode=0 tool.rescue_sensitivity_analysis=true tool.sensitivity_analysis_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/sensitivity_analysis
    for long_read_type in hifi clr ontR9 ontR10; do
        python auto_pipline.py tools=pantax dataset=$dst strain_level=true isolate=true rebuild=true tool.version=2 tool.read_type=[long] dataset.samplesID.long=[$long_read_type] tool.mode=0 tool.rescue_sensitivity_analysis=true tool.sensitivity_analysis_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/sensitivity_analysis 
    done
done

# ref div
python auto_pipline.py tools=pantax dataset=refdiv reference_diversity_strain_level=true tool.reference_diversity_strain_level_ref_num=1 isolate=true rebuild=true strain_level=false tool.version=2 tool.mode=0 tool.graph_parsing_format=lz tool.graph_mapq=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity/eval
python auto_pipline.py tools=pantax dataset=refdiv reference_diversity_strain_level=true tool.reference_diversity_strain_level_ref_num=2 isolate=true rebuild=true strain_level=false tool.version=2 tool.mode=0 tool.graph_parsing_format=lz tool.graph_mapq=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity/eval
python auto_pipline.py tools=pantax dataset=refdiv reference_diversity_strain_level=true tool.reference_diversity_strain_level_ref_num=3 isolate=true rebuild=true strain_level=false tool.version=2 tool.mode=0 tool.graph_parsing_format=lz tool.graph_mapq=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity/eval
python auto_pipline.py tools=pantax dataset=refdiv reference_diversity_strain_level=true tool.reference_diversity_strain_level_ref_num=4 isolate=true rebuild=true strain_level=false tool.version=2 tool.mode=0 tool.graph_parsing_format=lz tool.graph_mapq=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity/eval
python auto_pipline.py tools=pantax dataset=refdiv reference_diversity_strain_level=true tool.reference_diversity_strain_level_ref_num=5 isolate=true rebuild=true strain_level=false tool.version=2 tool.mode=0 tool.graph_parsing_format=lz tool.graph_mapq=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity/eval

# zymo1 div
zymo1_ref1=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/zymo1_reference_diversity/reference/reference_db/ref1/zymo1_ref1_pantax_db
zymo1_ref2=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/zymo1_reference_diversity/reference/reference_db/ref2/zymo1_ref2_pantax_db
python auto_pipline.py tools=pantax dataset=zymo1 tool.read_type=[long] dataset.samplesID.long=[ontR9,ontR10] reference_diversity_strain_level=true tool.reference_diversity_strain_level_ref_num=1 \
    tool.reference_diversity_strain_level.db=[$zymo1_ref1,$zymo1_ref2] isolate=true rebuild=true strain_level=false tool.version=2 tool.mode=0 tool.graph_parsing_format=lz \
    tool.graph_parsing_format=lz tool.graph_mapq=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity/eval

python auto_pipline.py tools=pantax dataset=zymo1 tool.read_type=[long] dataset.samplesID.long=[ontR9,ontR10] reference_diversity_strain_level=true tool.reference_diversity_strain_level_ref_num=2 \
    tool.reference_diversity_strain_level.db=[$zymo1_ref1,$zymo1_ref2] isolate=true rebuild=true strain_level=false tool.version=2 tool.mode=0 tool.graph_parsing_format=lz \
    tool.graph_parsing_format=lz tool.graph_mapq=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity/eval

python auto_pipline.py tools=pantax dataset=zymo1 tool.read_type=[long] dataset.samplesID.long=[ontR9,ontR10] zymo1_strain_level=true isolate=true rebuild=true strain_level=false tool.version=2 tool.extra_strain_profiling_paras="-gt 64" \
    top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity/eval tool.graph_mapq=true
work_shell=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity/eval/pantax/zymo1_strain_level_work2/zymo1_strain_level_zymo1_pantax_mode0.sh
work_shell_modified=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity/eval/pantax/reference_diversity_strain_level_work2/reference_diversity_strain_level_zymo1_pantax3.sh
cp $work_shell $work_shell_modified
sed -i -e '15{h;d}' -e '134G' $work_shell_modified
sed -i '15i wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto' $work_shell_modified
sed -i '135i dataset=zymo1-ref3' $work_shell_modified
sed -i '135i origin_wd=$wd' $work_shell_modified
sed -i '135i origin_dataset=$dataset' $work_shell_modified
sed -i '140s|\$wd/\$tool_name/\$profile_level/\$dataset|\$origin_wd/\$tool_name/\$profile_level/\$origin_dataset|' $work_shell_modified
sed -i -e '144{h;d}' -e '263G' $work_shell_modified
sed -i '144i wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto' $work_shell_modified
sed -i '264i dataset=zymo1-ref3' $work_shell_modified
sed -i '264i origin_wd=$wd' $work_shell_modified
sed -i '264i origin_dataset=$dataset' $work_shell_modified
sed -i '269s|\$wd/\$tool_name/\$profile_level/\$dataset|\$origin_wd/\$tool_name/\$profile_level/\$origin_dataset|' $work_shell_modified

# low cov eval
python auto_pipline.py tools=pantax dataset=simlow strain_level=true isolate=true rebuild=true tool.version=2 tool.graph_parsing_format=h5 tool.low_cov_eval=true
python auto_pipline.py tools=pantax dataset=simhigh strain_level=true isolate=true rebuild=true tool.version=2 tool.graph_parsing_format=h5 tool.low_cov_eval=true


# ganon
python auto_pipline.py tools=ganon dataset=simlow,simhigh strain_level=true -m
python auto_pipline.py tools=ganon dataset=zymo1 strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=ganon dataset=zymo1-log strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true

python auto_pipline.py tools=ganon dataset=simlow-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=ganon dataset=simlow-sub0.001 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=ganon dataset=simhigh-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=ganon dataset=simhigh-sub0.001 strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=ganon dataset=simlow-low strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=ganon dataset=simlow-subsample0.1 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=ganon dataset=simlow-subsample0.2 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=ganon dataset=simlow-subsample0.5 strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=ganon dataset=simlow-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=ganon dataset=simhigh-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=ganon dataset=simlow-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=ganon dataset=simhigh-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true

python auto_pipline.py tools=ganon dataset=spiked_in_single_species666_large_pangenome,spiked_in_three_species666_large_pangenome,spiked_in_five_species666_large_pangenome,spiked_in_ten_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome -m
python auto_pipline.py tools=ganon dataset=spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome
python auto_pipline.py tools=ganon dataset=low_spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/low_single_species_strain_level_666_large_pangenome

python auto_pipline.py tools=ganon dataset=spiked_in_single spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=ganon dataset=spiked_in_three spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=ganon dataset=spiked_in_five spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=ganon dataset=spiked_in_ten spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 


# kmcp
python auto_pipline.py tools=kmcp dataset=simlow,simhigh strain_level=true -m
python auto_pipline.py tools=kmcp dataset=zymo1 strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=kmcp dataset=zymo1-log strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=kmcp dataset=zymo1-log-sub strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=kmcp dataset=zymo1-log-sub2 strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=kmcp dataset=zymo1-log-sub3 strain_level=true zymo1_strain_level=true strain_level=false isolate=true rebuild=true

python auto_pipline.py tools=kmcp dataset=simlow-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=kmcp dataset=simlow-sub0.001 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=kmcp dataset=simhigh-sub0.01 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=kmcp dataset=simhigh-sub0.001 strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=kmcp dataset=simlow-low strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=kmcp dataset=simlow-subsample0.1 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=kmcp dataset=simlow-subsample0.2 strain_level=true isolate=true rebuild=true
python auto_pipline.py tools=kmcp dataset=simlow-subsample0.5 strain_level=true isolate=true rebuild=true

python auto_pipline.py tools=kmcp dataset=low_spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/low_single_species_strain_level_666_large_pangenome

python auto_pipline.py tools=kmcp dataset=simlow-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=kmcp dataset=simhigh-gtdb gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=kmcp dataset=simlow-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true
python auto_pipline.py tools=kmcp dataset=simhigh-gtdb-mut0.01 gtdb_strain_level=true strain_level=false isolate=true rebuild=true

python auto_pipline.py tools=kmcp dataset=spiked_in_single_species666_large_pangenome,spiked_in_three_species666_large_pangenome,spiked_in_five_species666_large_pangenome,spiked_in_ten_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome -m
python auto_pipline.py tools=kmcp dataset=spiked_in_eight_species666_large_pangenome spiked_in_strain_level_species666_large_pangenome=true strain_level=false top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome

python auto_pipline.py tools=kmcp dataset=spiked_in_single spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=kmcp dataset=spiked_in_three spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=kmcp dataset=spiked_in_five spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=kmcp dataset=spiked_in_ten spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 

# asm
python auto_pipline.py tools=metamdbg dataset=simlow strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_pipline.py tools=hifiasm dataset=simlow strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_pipline.py tools=flye dataset=simlow strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_pipline.py tools=myloasm dataset=simlow-myloasm strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof

python auto_pipline.py tools=metamdbg dataset=simhigh strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_pipline.py tools=hifiasm dataset=simhigh strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_pipline.py tools=flye dataset=simhigh strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_pipline.py tools=myloasm dataset=simhigh-myloasm strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof

python auto_pipline.py tools=metamdbg dataset=simlow-sub0.01 strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_pipline.py tools=hifiasm dataset=simlow-sub0.01 strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_pipline.py tools=metamdbg dataset=simlow-sub0.001 strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_pipline.py tools=hifiasm dataset=simlow-sub0.001 strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof

python auto_pipline.py tools=metamdbg dataset=simhigh-sub0.01 strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_pipline.py tools=hifiasm dataset=simhigh-sub0.01 strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_pipline.py tools=flye dataset=simhigh-sub0.01 strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_pipline.py tools=myloasm dataset=simhigh-sub0.01-myloasm strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof

python auto_pipline.py tools=metamdbg dataset=simhigh-sub0.001 strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_pipline.py tools=hifiasm dataset=simhigh-sub0.001 strain_level=true isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof


python auto_pipline.py tools=metamdbg dataset=zymo1 zymo1_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_pipline.py tools=hifiasm dataset=zymo1 zymo1_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_pipline.py tools=flye dataset=zymo1 zymo1_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_pipline.py tools=myloasm dataset=zymo1 zymo1_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof


# instrain
python auto_pipline.py tools=instrain dataset=simlow strain_level=true -m

# strainscan
python auto_pipline.py tools=strainscan dataset=spiked_in_single spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=strainscan dataset=spiked_in_three spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=strainscan dataset=spiked_in_five spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 
python auto_pipline.py tools=strainscan dataset=spiked_in_ten spiked_in_strain_level=true strain_level=false isolate=true rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666 

# uniqsketch
python auto_pipline.py tools=uniqsketch dataset=simlow,simhigh strain_level=true -m

# report
python auto_report.py experiment=profiling_latex_report rebuild=true
# gtdb
python auto_report.py experiment=profiling_latex_report rebuild=true mode=gtdb

python auto_report.py experiment=profiling_latex_report rebuild=true mode=subsample
python auto_report.py experiment=profiling_latex_report report=general_report report_mode=general rebuild=true 
python auto_report.py experiment=profiling_latex_report rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome
# python auto_report.py experiment=profiling_latex_report rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666
# python auto_report.py experiment=profiling_latex_report rebuild=true top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/low_single_species_strain_level_666_large_pangenome

# python auto_report.py experiment=profiling_latex_report rebuild=true report_output_name=filter09 report_name=filter0.9_evaluation_report.txt

python auto_report.py experiment=profiling_latex_report rebuild=true report=single_species_strain_latex_report top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3
python auto_report.py experiment=profiling_latex_report rebuild=true report=single_species_strain_latex_report report.model_tex=configs/report/report_model/single_dataset_strain_report_model.tex report.model_tex_split=[] top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3

# report v2
python auto_report.py experiment=profiling_latex_report rebuild=true version=2
python auto_report.py experiment=profiling_latex_report rebuild=true version=2 is_merge=true mode=zymo1
python auto_report.py experiment=profiling_latex_report rebuild=true version=2 mode=subsample
python auto_report.py experiment=profiling_latex_report rebuild=true version=2 top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_666_large_pangenome
python auto_report.py experiment=profiling_latex_report rebuild=true version=2 report=single_species_strain_latex_report report.model_tex=configs/report/report_model/single_dataset_strain_report_model.tex report.model_tex_split=[] top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3
python auto_report.py experiment=profiling_latex_report rebuild=true version=2 top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity/eval
python auto_report.py experiment=profiling_latex_report rebuild=true version=2 is_merge=true samplesID=[hifi,ontR10] asm2prof_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
python auto_report.py experiment=profiling_latex_report rebuild=true version=2 mode=gtdb
python auto_report.py experiment=profiling_latex_report rebuild=true report=single_species_strain_latex_report report.model_tex=configs/report/report_model/single_dataset_strain_report_model.tex report.model_tex_split=[] top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3

# time report
## simlow and simhigh NGS and TGS
python auto_time_report.py experiment=time_report version=2
python auto_time_report.py experiment=time_report time_report=general_ngs_time time_report_df_output=True version=2
python auto_time_report.py experiment=time_report time_report=general_tgs_time time_report_df_output=True version=2

python auto_time_report.py experiment=time_report time_report=gtdb100_simhigh_all_time time_report_df_output=True version=2

python auto_time_report.py experiment=time_report time_report=real_ngs_time time_report_df_output=True version=2
python auto_time_report.py experiment=time_report time_report=real_tgs_time time_report_df_output=True version=2
python /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/merge_sim_real_report.py /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto/report_v2/simulated_dataset_ngs_time.tex /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto/report_v2/real_ngs_time.tex /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto/report_v2/merged_ngs_time.tex
python /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/merge_sim_real_report.py /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto/report_v2/simulated_dataset_tgs_time.tex /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto/report_v2/real_tgs_time.tex /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto/report_v2/merged_tgs_time.tex
## zymo1 NGS and TGS
python auto_time_report.py experiment=time_report report.query_dataset=["zymo1"] report.report_name=zymo_ngs_time time_report/database_build_time=zymo 
python auto_time_report.py experiment=time_report report.query_dataset=["zymo1"] report.report_name=zymo_tgs_time report.samplesID=["ontR9","ontR10"] time_report/database_build_time=zymo time_report=general_tgs_time 
## single species 3, 5, 10 strains
python auto_time_report.py experiment=time_report time_report=single_species_ngs_time top_wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3
# test
python auto_time_report.py experiment=time_report time_report=general_ngs_time report.query_dataset=["test_simlow_add_eq2"] report.report_name=test_simlow_add_eq2_ngs_time

# zcat simlow-ngs-mut_rate0.01.fq.gz | paste - - - - - - - - | tee >(cut -f 1-4 | tr "\t" "\n" > read1.fq) | cut -f 5-8 | tr "\t" "\n" > read2.fq