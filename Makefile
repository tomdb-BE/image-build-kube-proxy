SEVERITIES = HIGH,CRITICAL

.PHONY: all
all:
	docker build --build-arg TAG=$(TAG) -t rancher/hardened-kube-proxy:$(TAG) .

.PHONY: image-push
image-push:
	docker push rancher/hardened-kube-proxy:$(TAG) >> /dev/null

.PHONY: scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --skip-update --ignore-unfixed rancher/hardened-kube-proxy:$(TAG)

.PHONY: image-manifest
image-manifest:
	docker image inspect rancher/hardened-kube-proxy:$(TAG)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create rancher/hardened-kube-proxy:$(TAG) \
		$(shell docker image inspect rancher/hardened-kube-proxy:$(TAG) | jq -r '.[] | .RepoDigests[0]')
