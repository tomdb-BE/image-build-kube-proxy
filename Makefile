SEVERITIES = HIGH,CRITICAL

ifeq ($(ARCH),)
ARCH=$(shell go env GOARCH)
endif

BUILD_META ?= -build$(shell date +%Y%m%d)
ORG ?= rancher
PKG ?= github.com/kubernetes/kubernetes
SRC ?= github.com/kubernetes/kubernetes
TAG ?= v1.21.4$(BUILD_META)

.PHONY: image-build
image-build:
	docker build \
		--build-arg ARCH=$(ARCH) \
		--build-arg PKG=$(PKG) \
		--build-arg SRC=$(SRC) \
		--build-arg ARCH=$(ARCH) \
		--build-arg TAG=$(TAG:$(BUILD_META)=) \
		--build-arg MAJOR=$(shell ./scripts/semver-parse.sh ${TAG} major) \
		--build-arg MINOR=$(shell ./scripts/semver-parse.sh ${TAG} minor) \
		--tag $(ORG)/hardened-kube-proxy:$(TAG) \
		--tag $(ORG)/hardened-kube-proxy:$(TAG)-$(ARCH) \
	.

.PHONY: image-push
image-push:
	docker push $(ORG)/hardened-kube-proxy:$(TAG)-$(ARCH)

.PHONY: image-manifest
image-manifest:
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend \
		$(ORG)/hardened-kube-proxy:$(TAG) \
		$(ORG)/hardened-kube-proxy:$(TAG)-$(ARCH)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push \
		$(ORG)/hardened-kube-proxy:$(TAG)

.PHONY: image-scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --ignore-unfixed $(ORG)/hardened-kube-proxy:$(TAG)
