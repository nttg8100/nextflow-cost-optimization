.PHONY: test-e2e clean
${HOME}/.pixi/bin/pixi:
	curl -sSL https://pixi.sh/install.sh | sh

.PHONY: test-fastqc test-fastp clean
test-fastqc-singularity: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark.nf -profile singularity \
		--run_fastqc --outdir results/test_fastqc \
		-resume -with-report report_test_fastqc.html

test-fastp-singularity: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark.nf -profile singularity \
		--run_fastp --outdir results/test_fastp \
		--outdir results/test_fastp \
		-resume -with-report report_test_fastp.html

test-fastqc-docker-amd64: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark.nf -profile docker \
		--run_fastqc --outdir results/test_fastqc \
		-resume -with-report report_test_fastqc.html

test-fastp-docker-amd64: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark.nf -profile docker \
		--run_fastp --outdir results/test_fastp \
		--outdir results/test_fastp \
		-resume -with-report report_test_fastp.html

test-fastqc-docker-arm64: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark.nf -profile docker,emulate_amd64 \
		--run_fastqc --outdir results/test_fastqc \
		-resume -with-report report_test_fastqc.html

test-fastp-docker-arm64: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark.nf -profile docker,emulate_amd64 \
		--run_fastp --outdir results/test_fastp \
		--outdir results/test_fastp \
		-resume -with-report report_test_fastp.html
clean:
	rm -rf *.html
	rm -rf results
	rm -rf .nextflow*
	rm -rf work
	rm -rf .pixi