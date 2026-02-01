process GENERATE_FILES{
    cpus 2

    output:
    path("results/tarball.tar"), emit: tarball
    path("results/tarball/**.data"), emit: data_files

    script:
    """
    mkdir -p results/tarball
	count=20; size=100K; index=1; \
	for k in \$(seq \$count); do \
		dd if=/dev/zero of=results/tarball/\${size}-\${index}-\$k.data bs=1 count=0 seek=\$size; \
	done
	tar -cvf results/tarball.tar -C results/tarball .
    """
}