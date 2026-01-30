include { ENSEMBLVEP_VEP } from './modules/vep.nf'

workflow {
    main:
        ENSEMBLVEP_VEP(
            Channel.of(tuple([id: 'HCC1395N'], file("inputs/10k_variants.vcf.gz"), file("inputs/10k_variants.vcf.gz.tbi"))), // tuple val(meta), path(vcf), path(custom_extra_files)
            Channel.value("GRCh38"), // val genome
            Channel.value("homo_sapiens"), // val species
            Channel.value(114), // val cache_version
            Channel.fromPath(params.vep_cache), // path cache
            Channel.of(tuple([:], [])), // tuple val(meta2), path(fasta)
            Channel.of([]) // path extra_files
        )
}