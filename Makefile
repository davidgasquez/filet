.DEFAULT_GOAL := run

VERSION=v0.6.9.lily
IMAGE=europe-west1-docker.pkg.dev/protocol-labs-data/pl-data/filet

build:
	docker build --no-cache -t $(IMAGE):$(VERSION) -t $(IMAGE):latest .

run:
	docker run -it -v ${PWD}/.lily:/var/lib/lily -v ${PWD}:/tmp/data $(IMAGE):$(VERSION)

dev:
	docker run -it --entrypoint /bin/bash -v ${PWD}/.lily:/var/lib/lily -v ${PWD}:/tmp/data $(IMAGE):$(VERSION)

push: build
	docker push $(IMAGE):$(VERSION)
	docker push $(IMAGE):latest

clean:
	sudo rm -rf .lily lily.log mainnet/
	rm -rf *.car *.aria2

send: push
	gcloud --billing-project protocol-labs-data beta batch jobs submit lily-job-gcs-backfill-snapshot-$(shell date +%s) --config gce_batch_job.json --location us-central1
