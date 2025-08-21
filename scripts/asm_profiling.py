
import sys, gzip

asm_contigs_file = sys.argv[1]
asm_paf_file = sys.argv[2]
ref = sys.argv[3]
tool = sys.argv[4]

ctg2tax = {}
with open(asm_paf_file, "r") as f:
    for line in f:
        tokens = line.strip().split("\t")
        is_primary_aln = tokens[12]
        if is_primary_aln != "tp:A:P": continue
        ctg_name = tokens[0]
        tax = tokens[5].split("|")[2].split("#")[0]
        ident = int(tokens[9]) / int(tokens[1])
        mapq = int(tokens[11])
        assert "dv" in tokens[16]
        dv = float(tokens[16].split(":")[2])
        if ctg_name not in ctg2tax:
            ctg2tax[ctg_name] = [tax, ident, mapq, dv]
        else:
            if ident > ctg2tax[ctg_name][1]:
                ctg2tax[ctg_name] = [tax, ident, mapq, dv]
            elif ident == ctg2tax[ctg_name][1]:
                if mapq > ctg2tax[ctg_name][2]:
                    ctg2tax[ctg_name] = [tax, ident, mapq, dv]
                elif mapq == ctg2tax[ctg_name][2]:
                    if dv < ctg2tax[ctg_name][3]:
                        ctg2tax[ctg_name] = [tax, ident, mapq, dv]
                    else:
                        print(ctg_name, tax, ident, mapq, dv)
tax2ctg = {}
for ctg, tax_info in ctg2tax.items():
    tax = tax_info[0]
    if tax not in tax2ctg:
        tax2ctg[tax] = [ctg]
    else:
        tax2ctg[tax].append(ctg)

def custom_open(file_name):
    if file_name.endswith(".gz"):
        return gzip.open(file_name, "rt")
    else:
        return open(file_name, "r")

ctg2cov = {}
ctg2len = {}

if tool.lower() == "metamdbg":
    with custom_open(asm_contigs_file) as f:
        # ctg_len = 0
        for line in f:
            if line.startswith(">"):
                tokens = line[1:].strip().split(" ")
                coverage = tokens[2].split("=")[1]
                ctg_name = tokens[0]
                ctg2cov[ctg_name] = coverage
                ctg_len = tokens[1].split("=")[1]
                ctg2len[ctg_name] = ctg_len

            #     ctg_len = 0
            # else:
            #     ctg_len += len(line.strip())
            #     ctg2len[ctg_name] = ctg_len
elif tool.lower() == "hifiasm":
    # hifiasm_hifi.p_ctg.noseq.gfa
    with custom_open(asm_contigs_file) as f:
        # ctg_len = 0
        for line in f:
            if line.startswith("S"):
                tokens = line.strip().split("\t")
                ctg_name = tokens[1]
                ctg_len = tokens[3].split(":")[2]
                ctg2len[ctg_name] = ctg_len
                dp = tokens[4].split(":")[2]
                ctg2cov[ctg_name] = dp
elif tool.lower() == "myloasm":
    with custom_open(asm_contigs_file) as f:
        for line in f:
            if line.startswith(">"):
                ctg_name = line.strip()[1:]
                tokens = ctg_name.split("_")
                ctg_len = tokens[1].split("-")[1]
                ctg2len[ctg_name] = ctg_len
                # the depth for 100% similarity
                dp = tokens[3].split("-")[-1]
                ctg2cov[ctg_name] = dp
elif tool.lower() == "flye":
    with custom_open(asm_contigs_file) as f:
        for line in f:
            if line.startswith("#"): continue
            tokens = line.strip().split("\t")
            ctg_name = tokens[0]
            ctg_len = tokens[1]
            dp = tokens[2]
            ctg2len[ctg_name] = ctg_len
            ctg2cov[ctg_name] = dp
            

# contig mean dp
tax2cov = {}
for tax, ctgs in tax2ctg.items():
    tax_cov_total = 0
    for ctg in ctgs:
        tax_cov_total += float(ctg2cov[ctg])
    tax_cov = tax_cov_total / len(ctgs)
    tax2cov[tax] = tax_cov

sorted_tax2cov = dict(sorted(tax2cov.items(), key=lambda x: x[1], reverse=True))

total_cov = sum(sorted_tax2cov.values())

ref_lens = {}
with open(ref, "r") as f:
    for line in f:
        tokens = line.strip().split("\t")
        ref_lens[tokens[0]] = tokens[1]

# contigs dp sum and normalize by strain length 
i = 0
tax2cov2 = {}
for tax, ctgs in tax2ctg.items():
    tax_cov_total = 0
    for ctg in ctgs:
        tax_cov_total += float(ctg2cov[ctg]) * int(ctg2len[ctg])
        # if i == 0 and tax == "GCF_016839145.1_ASM1683914v1":
        #     print(len(ctgs))
        #     print(f"{tax}\t{ctg}\t{ctg2cov[ctg]}\t{ctg2len[ctg]}\t{tax_cov_total}\n")
    
    tax_cov = tax_cov_total / int(ref_lens[tax])
    tax2cov2[tax] = tax_cov

sorted_tax2cov2 = dict(sorted(tax2cov2.items(), key=lambda x: x[1], reverse=True))

total_cov2 = sum(sorted_tax2cov2.values())

with open("strain_abundance.txt", "w") as f:
    for tax in sorted_tax2cov2:
        cov1 = sorted_tax2cov[tax]
        abund1 = cov1 / total_cov
        cov2 = sorted_tax2cov2[tax]
        abund2 = cov2 / total_cov2
        f.write(f"{tax}\t{abund2}\t{cov2}\t{abund1}\t{cov1}\n")
        
    






