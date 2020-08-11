SEVERITIES = HIGH,CRITICAL

.PHONY: all
all:
	docker build --build-arg TAG=$(TAG) -t rancher/kube-proxy:$(TAG) .

.PHONY: image-push
image-push:
	docker push rancher/kube-proxy:$(TAG) >> /dev/null

.PHONY: scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --skip-update --ignore-unfixed rancher/kube-proxy:$(TAG)

.PHONY: image-manifest
image-manifest:
	docker image inspect rancher/kube-proxy:$(TAG)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create rancher/kube-proxy:$(TAG) \
		$(shell docker image inspect rancher/kube-proxy:$(TAG) | jq -r '.[] | .RepoDigests[0]')
