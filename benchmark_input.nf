include { GENERATE_FILES } from './modules/generate_files.nf'
include { COUNT_FILES as COUNT_FILES_STANDARD } from './modules/count_files.nf'
include { COUNT_FILES as COUNT_FILES_TAR } from './modules/count_files.nf'

workflow {
    main: 

        // generate output file
        GENERATE_FILES()      

        // benchmark files input
        // normal files
        if (params.benchmark_input){
            
            ch_files = COUNT_FILES_STANDARD(GENERATE_OUTPUT.out.data_files)
        }

        // tarball and untar
        if (params.benchmark_input_tar){
            ch_files = COUNT_FILES_TAR(GENERATE_OUTPUT.out.tarball)
        }
}
