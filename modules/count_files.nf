process COUNT_FILES {
    cpus 2

    input:
    path(file_path)

    script:
    """
    ls -lah tarball/**.data|wc -l > num_files.txt
    """
}