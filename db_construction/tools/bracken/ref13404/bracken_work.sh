
KrakenDB="/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/kraken2_db"
threads=64


for read_len in 125 150 151; do 
    echo $read_len
    if [ ! -f $KrakenDB/database${read_len}mers.kraken ]; then
        bracken-build -d $KrakenDB -t $threads -l $read_len
    fi
done 



