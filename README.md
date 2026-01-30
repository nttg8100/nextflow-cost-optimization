# nextflow-cost-optimization
This one shows proof of concept on how to optimize cost on nextflow


vep \
    -i inputs/0000.vcf.gz \
    -o HCC1395N.consensus_VEP.ann.vcf.gz \
    --stats_file  HCC1395N.consensus_VEP.ann.summary.html      --vcf --everything --filter_common --per_gene --total_length --offline --format vcf \
    --compress_output bgzip \
     \
    --assembly GRCh38 \
    --species homo_sapiens \
    --cache \
    --cache_version 114 \
    --dir_cache ./local_vep_cache \
    --fork 6