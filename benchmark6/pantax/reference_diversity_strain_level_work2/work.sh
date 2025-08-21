

set -e 

# for ref_num in 1 2 3 4 5; do
#     bash reference_diversity_strain_level_refdiv_pantax$ref_num.sh
# done

for ref_num in 1 2 3; do
    bash reference_diversity_strain_level_zymo1_pantax$ref_num.sh
done
