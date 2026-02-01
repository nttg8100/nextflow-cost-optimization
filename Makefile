.PHONY: test-e2e clean
${HOME}/.pixi/bin/pixi:
	curl -sSL https://pixi.sh/install.sh | sh

##### Computing resource benchmark tests #####
.PHONY: test-fastqc-singularity test-fastp-singularity test-fastqc-docker-amd64 test-fastp-docker-amd64 test-fastqc-docker-arm64 test-fastp-docker-arm64
test-fastqc-singularity: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark_computing_r-e core esource.nf -profile singularity \
		--run_fastqc --outdir results/test_fastqc \
		-resume -with-report report_test_fastqc.html

test-fastp-singularity: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark_computing_r-e core esource.nf -profile singularity \
		--run_fastp --outdir results/test_fastp \
		--outdir results/test_fastp \
		-resume -with-report report_test_fastp.html

test-fastqc-docker-amd64: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark_comput-e core ing_resource.nf -profile docker \
		--run_fastqc --outdir results/test_fastqc \
		-resume -with-report report_test_fastqc.html

test-fastp-docker-amd64: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark_comput-e core ing_resource.nf -profile docker \
		--run_fastp --outdir results/test_fastp \
		--outdir results/test_fastp \
		-resume -with-report report_test_fastp.html

test-fastqc-docker-arm64: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark_computing_resource.n-e core f -profile docker,emulate_amd64 \
		--run_fastqc --outdir results/test_fastqc \
		-resume -with-report report_test_fastqc.html

test-fastp-docker-arm64: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run nextflow run benchmark_computing_resource.n-e core f -profile docker,emulate_amd64 \
		--run_fastp --outdir results/test_fastp \
		--outdir results/test_fastp \
		-resume -with-report report_test_fastp.html

##### I/O benchmark tests ##### 
.PHONY: start-minio test-input
start-minio:
	docker run -d  -v ./minio_data:/data --rm -p 9000:9000 -p 9001:9001 --name minio minio/minio server /data --console-address ":9001"

aws-config: start-minio
	export AWS_ACCESS_KEY_ID="minioadmin"; \
	export AWS_SECRET_ACCESS_KEY="minioadmin"; \
	export AWS_DEFAULT_REGION="us-east-1"; \
	export AWS_ENDPOINT_URL="http://localhost:9000" ; \
	sleep 10 && aws s3 mb s3://io-benchmark --endpoint-url http://localhost:9000

results/tarball.tar:
	@mkdir -p results/tarball
	@count=10000; size=1M; index=1; \
	for k in $$(seq $$count); do \
		dd if=/dev/zero of=results/tarball/$${size}-$${index}-$$k.data bs=1 count=0 seek=$$size; \
	done
	tar -cvf results/tarball.tar -C results/tarball .

upload-tar:
	aws s3 cp results/tarball.tar s3://io-benchmark/ --endpoint-url http://localhost:9000

upload-10k-files:
	aws s3 cp results/tarball  s3://io-benchmark/tarball --endpoint-url http://localhost:9000 --recursive

test-input-core: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run -e core nextflow run benchmark_input.nf \
		-c nextflow_s3.config \
		--benchmark_input \
		--inputs="s3://io-benchmark/tarball"

test-input-tar: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run -e core nextflow run benchmark_input.nf \
		-c nextflow_s3.config \
		--benchmark_input_tar \
		--inputs="s3://io-benchmark/tarball.tar"

test-input-tar-pipe: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run -e core nextflow run benchmark_input.nf \
		-c nextflow_s3.config -c nextflow_tar.config \
		--benchmark_input \
		--inputs="s3://io-benchmark/tmp.txt"

vep/114_GRCh38: ${HOME}/.pixi/bin/pixi
	mkdir -p vep
	touch vep/vep_cache
	cd vep && ${HOME}/.pixi/bin/pixi run -e core aws s3 --no-sign-request cp s3://annotation-cache/vep_cache/114_GRCh38 114_GRCh38 --recursive

vep/vep_cache.tar: vep/114_GRCh38
	tar -cvf vep/vep_cache.tar -C vep/114_GRCh38 .

upload-vep-cache: vep/vep_cache.tar
	${HOME}/.pixi/bin/pixi run -e core aws s3 cp vep/114_GRCh38 s3://io-benchmark/ --endpoint-url http://localhost:9000 --recursive
	${HOME}/.pixi/bin/pixi run -e core aws s3 cp vep/vep_cache.tar s3://io-benchmark/ --endpoint-url http://localhost:9000
	
mount-s3-vep-cache: ${HOME}/.pixi/bin/pixi
	mkdir -p ./mnt/vep_cache
	mkdir -p ./mnt/tmp
	${HOME}/.pixi/bin/pixi run -e mount mount-s3 --endpoint-url http://localhost:9000 --region us-east-1 --force-path-style io-benchmark ./mnt/vep_cache --read-only --cache ./mnt/tmp --max-threads 8

##### VEP benchmark tests #####
.PHONY: test-vep-local test-vep-mount-cache test-vep-direct-s3 test-vep-tar-cache test-vep-mount-tar
test-vep-local: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run -e core nextflow run benchmark_vep.nf -profile docker --vep_cache "./vep/114_GRCh38"

test-vep-mount-cache: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run -e core nextflow run benchmark_vep.nf \
		-c nextflow_s3.config -c nextflow_vep_mount.config --vep_cache "./mnt/vep_cache/114_GRCh38" -profile docker

test-vep-direct-s3: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run -e core  nextflow run benchmark_vep.nf \
		-c nextflow_s3.config --vep_cache "s3://io-benchmark/114_GRCh38" -profile docker

test-vep-tar-cache: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run -e core nextflow run benchmark_vep.nf \
		-c nextflow_s3.config -c nextflow_vep_tar.config --vep_cache "s3://io-benchmark/vep_cache" -profile docker

test-vep-mount-tar: ${HOME}/.pixi/bin/pixi
	${HOME}/.pixi/bin/pixi run -e core nextflow run benchmark_vep.nf \
		-c nextflow_s3.config -c nextflow_vep_mount_tar.config --vep_cache "s3://io-benchmark/vep_cache" -profile docker

##### Clean up #####
.PHONY: clean
clean:
	docker rm -f minio || true
	rm -rf *.html
	rm -rf .nextflow*	