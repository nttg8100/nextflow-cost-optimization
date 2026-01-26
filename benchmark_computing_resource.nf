include { FASTQC as FASTQC_1 } from './modules/fastqc.nf'
include { FASTQC as FASTQC_2 } from './modules/fastqc.nf'
include { FASTQC as FASTQC_3 } from './modules/fastqc.nf'
include { FASTP as FASTP_1 } from './modules/fastp.nf'
include { FASTP as FASTP_2 } from './modules/fastp.nf'
include { FASTP as FASTP_3 } from './modules/fastp.nf'

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
    if (params.run_fastqc) {
        // fastqc benchmarks
        FASTQC_1(sample_ch)
        FASTQC_2(sample_ch)
        FASTQC_3(sample_ch)
    }
    
    if (params.run_fastp) {
        // fastp benchmarks
        FASTP_1(sample_ch,[], false, false, false)
        FASTP_2(sample_ch,[], false, false, false)
        FASTP_3(sample_ch,[], false, false, false)
    }
}