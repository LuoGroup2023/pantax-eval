##awk '{print $2"\t"$NF}' genome_info_13404.txt | tail -n +2 | awk '{printf "%.0f\t%s\n", $1, $2}' > new_info_13404.txt

##python prepare_input_list.py

#perl /home/enlian/software/MetaMaps-master/./combineAndAnnotateReferences.pl --inputFileList input_list.txt --outputFile download/reference.fa --taxonomyInDirectory download/taxonomy_202308/ --taxonomyOutDirectory download/new_taxonomy

perl /home/enlian/software/MetaMaps-master/./buildDB.pl --DB databases/strain_level_metamaps_db --FASTAs download/reference.fa --taxonomy download/new_taxonomy

