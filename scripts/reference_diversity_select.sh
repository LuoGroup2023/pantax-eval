

#!/bin/bash

target_genus="Lactobacillus"
genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt

awk -F'\t' 'NR > 1 {print $3}' $genomes_info | sort | uniq > species_taxid.txt
taxonkit lineage -c species_taxid.txt > species_taxid2name.tsv

truncate -s 0 reference_diversity_species.tsv
while IFS=$'\t' read -r species_taxid new_species_taxid taxa; do
  if [[ "$species_taxid" == "$new_species_taxid" ]]; then
    IFS=';' read -ra parts <<< "$taxa"
    len=${#parts[@]}
    genus1="${parts[len-2]}"
    # maybe has group taxa
    genus2="${parts[len-3]}"
    # if [[ $genus1 == "Lactobacillus" ]] || [[ $genus2 == "Lactobacillus" ]]; then
    # if [[ $genus1 == "Escherichia" ]] || [[ $genus2 == "Escherichia" ]]; then
    # if [[ $genus1 == "Pseudomonas" ]] || [[ $genus2 == "Pseudomonas" ]]; then
    if [[ $genus1 == "Streptococcus" ]] || [[ $genus2 == "Streptococcus" ]]; then
    # if [[ $genus1 == "Bacillus" ]] || [[ $genus2 == "Bacillus" ]]; then
        echo $species_taxid >> reference_diversity_species.tsv
    fi
  fi
done < species_taxid2name.tsv



