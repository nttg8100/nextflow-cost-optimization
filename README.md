# Nextflow-cost-optimization
This one shows proof of concept on how to optimize cost on nextflow

# VEP analysis
make test-vep-local 2:26.20
make test-vep-mount-cache 2:31.08
make test-vep-direct-s3 6:32.63
make test-vep-tar-cache 6:02.52 total
make test-vep-mount-tar 5:57.18 total

# Replacing VEP command with copy command
make test-vep-mount-cache for coyping all contents on vep database 4:16.09 total