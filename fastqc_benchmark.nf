include { FASTQC as FASTQC_1 } from './modules/fastqc.nf'
include { FASTQC as FASTQC_2 } from './modules/fastqc.nf'
include { FASTQC as FASTQC_3 } from './modules/fastqc.nf'
include { FASTQC as FASTQC_4 } from './modules/fastqc.nf'

// Set input CSV file in params.input
params.input = "samples.csv"

// Parse CSV; skip header, split by comma, expand to tuple for process
Channel
    .fromPath(params.input)
    .splitCsv(header:true)
    .map { row ->
        // Compose the meta map and reads list
        def meta = [ id: row.sample, strandedness: row.strandedness ]
        def reads = [ row.fastq_1, row.fastq_2 ]
        tuple(meta, reads)
    }
    .set { sample_ch }

workflow {
    FASTQC_1(sample_ch)
}