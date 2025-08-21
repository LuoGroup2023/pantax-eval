
set -e
pantax_run_shell_file=$1
mode=${2:-all}

script_dirpath=$(dirname $pantax_run_shell_file)
if [ $mode == "all" ] || [ $mode == "0" ]; then
    filename=$(basename $pantax_run_shell_file .sh)
    cp $pantax_run_shell_file $script_dirpath/${filename}_mode0.sh
    sed -i 's/^dataset=\(.*\)/dataset=\1_mode0/' $script_dirpath/${filename}_mode0.sh
    echo "Generate PanTax default mode work shell...done"
    echo $script_dirpath/${filename}_mode0.sh
fi

if [ $mode == "all" ] || [ $mode == "1" ]; then
    filename=$(basename $pantax_run_shell_file .sh)
    cp $pantax_run_shell_file $script_dirpath/${filename}_mode1.sh
    sed -i 's/mode="0"/mode="1"/g' $script_dirpath/${filename}_mode1.sh
    sed -i 's/^dataset=\(.*\)/dataset=\1_mode1/' $script_dirpath/${filename}_mode1.sh
    echo "Generate PanTax fast mode work shell...done"
    echo $script_dirpath/${filename}_mode1.sh
fi
