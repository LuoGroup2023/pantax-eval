
KrakenDB="/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/kraken2_db_rebuild"
threads=64


read_len=150
if [ ! -f $KrakenDB/database${read_len}mers.kraken ]; then
    /usr/bin/time -v -o build_time.log bracken-build -d $KrakenDB -t $threads -l $read_len
fi



