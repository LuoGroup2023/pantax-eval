
KrakenDB="/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/gtdb100/kraken2_db"
threads=64


for read_len in 150; do 
    echo $read_len
    if [ ! -f $KrakenDB/database${read_len}mers.kraken ]; then
        /usr/bin/time -v -o build_time.log bracken-build -d $KrakenDB -t $threads -l $read_len
    fi
done 



