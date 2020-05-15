SEVERITIES = HIGH,CRITICAL

.PHONY: all
all:
	docker build --build-arg TAG=$(TAG) -t ranchertest/kube-proxy:$(TAG) .

.PHONY: image-push
image-push:
	docker push ranchertest/kube-proxy:$(TAG) >> /dev/null

.PHONY: scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --skip-update --ignore-unfixed ranchertest/kube-proxy:$(TAG)

.PHONY: image-manifest
image-manifest:
	docker image inspect ranchertest/kube-proxy:$(TAG)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create ranchertest/kube-proxy:$(TAG) \
		$(shell docker image inspect ranchertest/kube-proxy:$(TAG) | jq -r '.[] | .RepoDigests[0]')
