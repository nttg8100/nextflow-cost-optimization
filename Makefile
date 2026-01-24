.PHONY: test-e2e clean
${HOME}/.pixi/bin/pixi:
	curl -sSL https://pixi.sh/install.sh | sh

.PHONY: test
test: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run fastqc_benchmark.nf -profile test --outdir results/test -resume
