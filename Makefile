UNAME_M = $(shell uname -m)
ARCH=
ifeq ($(UNAME_M), x86_64)
	ARCH=amd64
else
	ARCH=$(UNAME_M)
endif

SEVERITIES = HIGH,CRITICAL

.PHONY: all
all:
	docker build --build-arg TAG=$(TAG) -t rancher/kube-proxy:$(TAG)-$(ARCH) .

.PHONY: image-push
image-push:
	docker push rancher/kube-proxy:$(TAG)-$(ARCH) >> /dev/null

.PHONY: scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --skip-update --ignore-unfixed rancher/kube-proxy:$(TAG)-$(ARCH)

.PHONY: image-manifest
image-manifest:
	docker image inspect rancher/kube-proxy:$(TAG)-$(ARCH)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create rancher/kube-proxy:$(TAG)-$(ARCH) \
		$(shell docker image inspect rancher/kube-proxy:$(TAG)-$(ARCH) | jq -r '.[] | .RepoDigests[0]')
