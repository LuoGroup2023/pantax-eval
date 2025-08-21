import csv

# 读取文件A的数据
with open('/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/metamaps/spiked_in_666/scripts/new_info.txt', 'r', newline='') as file_a:
    reader_a = csv.reader(file_a, delimiter='\t')
    data_a = list(reader_a)

# 读取文件B的数据
with open('/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/metamaps/spiked_in_666/scripts/cant_find_in_taxonomy.txt', 'r', newline='') as file_b:
    reader_b = csv.reader(file_b, delimiter='\t')
    data_b = list(reader_b)

# 打开输出文件C
with open('/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/metamaps/spiked_in_666/scripts/input_list.txt', 'w', newline='') as file_c:
    writer_c = csv.writer(file_c, delimiter='\t')

    # 遍历文件A的每一行
    for row_a in data_a:
        # 获取A中的数字
        number_a = row_a[0]

        # 在文件B中查找是否有相同的数字
        found = False
        for row_b in data_b:
            number_b = row_b[0]
            if number_a == number_b:
                found = True
                break

        # 如果在B中找不到相同的数字，将原始行写入文件C
        if not found:
            writer_c.writerow(row_a)
