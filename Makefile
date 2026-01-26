.PHONY: test-e2e clean
${HOME}/.pixi/bin/pixi:
	curl -sSL https://pixi.sh/install.sh | sh

##### Computing resource benchmark tests #####
.PHONY: test-fastqc-singularity test-fastp-singularity test-fastqc-docker-amd64 test-fastp-docker-amd64 test-fastqc-docker-arm64 test-fastp-docker-arm64
test-fastqc-singularity: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark_computing_resource.nf -profile singularity \
		--run_fastqc --outdir results/test_fastqc \
		-resume -with-report report_test_fastqc.html

test-fastp-singularity: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark_computing_resource.nf -profile singularity \
		--run_fastp --outdir results/test_fastp \
		--outdir results/test_fastp \
		-resume -with-report report_test_fastp.html

test-fastqc-docker-amd64: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark_computing_resource.nf -profile docker \
		--run_fastqc --outdir results/test_fastqc \
		-resume -with-report report_test_fastqc.html

test-fastp-docker-amd64: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark_computing_resource.nf -profile docker \
		--run_fastp --outdir results/test_fastp \
		--outdir results/test_fastp \
		-resume -with-report report_test_fastp.html

test-fastqc-docker-arm64: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark_computing_resource.nf -profile docker,emulate_amd64 \
		--run_fastqc --outdir results/test_fastqc \
		-resume -with-report report_test_fastqc.html

test-fastp-docker-arm64: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark_computing_resource.nf -profile docker,emulate_amd64 \
		--run_fastp --outdir results/test_fastp \
		--outdir results/test_fastp \
		-resume -with-report report_test_fastp.html

##### I/O benchmark tests ##### 
.PHONY: start-localstack test-input
start-localstack:
	docker run --rm -d -p 4566:4566 -p 4571:4571 --name localstack localstack/localstack

aws-config: start-localstack
	export AWS_ACCESS_KEY_ID="test"
	export AWS_SECRET_ACCESS_KEY="test"
	export AWS_REGION_NAME="us-east-1"
	export AWS_ENDPOINT_URL="http://localhost:4566"
	sleep 10 && aws s3 mb s3://io-benchmark --endpoint-url http://localhost:4566

results/tarball.tar: aws-config
	@mkdir -p results/tarball
	@count=20000; size=100K; index=1; \
	for k in $$(seq $$count); do \
		dd if=/dev/zero of=results/tarball/$${size}-$${index}-$$k.data bs=1 count=0 seek=$$size; \
	done
	tar -cvf results/tarball.tar -C results/tarball .
	aws s3 cp results  s3://io-benchmark --endpoint-url http://localhost:4566 --recursive
	
test-input-standard: ${HOME}/.pixi/bin/pixi
	time ${HOME}/.pixi/bin/pixi run nextflow run benchmark_input.nf \
		-c nextflow_s3.config \
		--benchmark_input \
		--inputs="s3://io-benchmark/tarball"

test-input-tar: ${HOME}/.pixi/bin/pixi
	time ${HOME}/.pixi/bin/pixi run nextflow run benchmark_input.nf \
		-c nextflow_s3.config \
		--benchmark_input_tar \
		--inputs="s3://io-benchmark/tmp.txt"

##### Clean up #####
.PHONY: clean
clean:
	docker rm -f localstack || true
	rm -rf *.html
	rm -rf .nextflow*