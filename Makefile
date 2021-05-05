SEVERITIES = HIGH,CRITICAL

ifeq ($(ARCH),)
ARCH=$(shell go env GOARCH)
endif

BUILD_META=-build$(shell date +%Y%m%d)
BUILD_META=-build20210413
ORG ?= rancher
PKG ?= github.com/kubernetes/kubernetes
SRC ?= github.com/kubernetes/kubernetes
TAG ?= v1.18.8$(BUILD_META)

ifneq ($(DRONE_TAG),)
TAG := $(DRONE_TAG)
endif

ifeq (,$(filter %$(BUILD_META),$(TAG)))
$(error TAG needs to end with build metadata: $(BUILD_META))
endif

.PHONY: image-build
image-build:
	docker build \
		--build-arg ARCH=$(ARCH) \
		--build-arg PKG=$(PKG) \
		--build-arg SRC=$(SRC) \
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
