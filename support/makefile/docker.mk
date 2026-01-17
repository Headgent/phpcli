# ---------------------------------------------------------------------------
# docker.mk – unified Docker/Buildx targets without redundancy
# ---------------------------------------------------------------------------
##@ Docker

# ---------------------------------------------------------------------------
# Examples for invocations
# ---------------------------------------------------------------------------
#
# ▶ Local builds
#   make build                        # builds image for PHP_VERSION from .env (local platform)
#   PHP_VERSION=8.3 make build        # builds specifically version 8.3
#   make build-all                    # builds all versions locally (8.2–8.4)
#
# ▶ Multi-arch test builds (local, with :amd64-test and :arm64-test tags)
#   make build-test-images
#
# ▶ Multi-arch push (CI/CD)
#   make build-remote-all             # builds & pushes all versions (8.2–8.4) + latest tag
#   make build-remote-latest          # builds & pushes only the "latest" version (8.4)
#
# ▶ Control cache
#   make build-remote-all CACHE_BACKEND=gha
#   make build-remote-all CACHE_BACKEND=registry CACHE_REF=docker.io/ORG/phpcli:buildcache
#   make build-remote-all NO_CACHE=true
# ---------------------------------------------------------------------------

PLATFORMS       ?= linux/amd64 linux/arm64
PHP_VERSIONS    := 8.2 8.3 8.4
LATEST_VERSION  := $(word $(words $(PHP_VERSIONS)),$(PHP_VERSIONS))

CACHE_BACKEND   ?= auto          #  auto|none|local|registry|gha
CACHE_REF       ?=               # e.g. docker.io/yourorg/phpcli:buildcache (only for registry)
CACHE_DIR       ?= .buildx-cache # only for local

# Build-time only args (sourced from .env)
# Runtime config has fixed defaults in Dockerfile, override with: docker run -e VAR=value
BUILD_ARGS = \
  --build-arg ALPINE_VERSION="$(ALPINE_VERSION)" \
  --build-arg PUID="$(PUID)" \
  --build-arg PGID="$(PGID)" \
  --build-arg INSTALL_DB_CLIENTS="$(INSTALL_DB_CLIENTS)" \
  --build-arg COMPOSER_VERSION="$(COMPOSER_VERSION)" \
  --build-arg APCU_VERSION="$(APCU_VERSION)" \
  --build-arg REDIS_VERSION="$(REDIS_VERSION)" \
  --build-arg XDEBUG_VERSION="$(XDEBUG_VERSION)" \
  --build-arg PCOV_VERSION="$(PCOV_VERSION)" \
  --build-arg AMQP_VERSION="$(AMQP_VERSION)" \
  --build-arg RDKAFKA_VERSION="$(RDKAFKA_VERSION)"

build: ## Build local native platform php image for .env PHP_VERSION
	$(DOCKER_COMPOSE) build $$( [ "$(NO_CACHE)" = "true" ] && echo "--no-cache" ) $(PHP_IMAGE_NAME)
	docker images --filter dangling=true -q | xargs -r docker rmi
.PHONY: build

build-all: ## Build local native platform php image for all defined PHP_VERSIONS + latest tag
	@for version in $(PHP_VERSIONS); do \
		echo ">>> Building $(PHP_IMAGE_NAME) for PHP $$version ..."; \
		PHP_VERSION=$$version $(DOCKER_COMPOSE) build $$( [ "$(NO_CACHE)" = "true" ] && echo "--no-cache" ) $(PHP_IMAGE_NAME); \
		echo ">>> Created: $(PHP_IMAGE_NAME) (PHP $$version)"; \
	done
	@echo ">>> Tagging $(DOCKER_HUB)/$(PHP_IMAGE_NAME):$(LATEST_VERSION) as latest ..."
	@docker tag $(DOCKER_HUB)/$(PHP_IMAGE_NAME):$(LATEST_VERSION) $(DOCKER_HUB)/$(PHP_IMAGE_NAME):latest
	@echo ">>> Created: $(DOCKER_HUB)/$(PHP_IMAGE_NAME):latest"
	docker images --filter dangling=true -q | xargs -r docker rmi
.PHONY: build-all

build-remote-all: .buildx-create ## Build all remote php image for all defined PHP_VERSIONS
	@set -e; \
	$(call cache_flags) ; \
	PLATFORM_CSV="$$(printf '%s' "$(PLATFORMS)" | tr ' ' ',')"; \
	for version in $(PHP_VERSIONS); do \
	  echo ">>> Building $(DOCKER_HUB)/$(PHP_IMAGE_NAME):$$version (multi-arch: $$PLATFORM_CSV) ..."; \
	  tags="-t $(DOCKER_HUB)/$(PHP_IMAGE_NAME):$$version"; \
	  $(call buildx_one,$$PLATFORM_CSV,$$tags,--build-arg PHP_VERSION=$$version --push --provenance=mode=max,src/Dockerfile,./src); \
	  echo ">>> Pushed: $(DOCKER_HUB)/$(PHP_IMAGE_NAME):$$version"; \
	done; \
	echo ">>> Setting latest tag -> $(LATEST_VERSION)"; \
	docker buildx imagetools create \
	  --tag $(DOCKER_HUB)/$(PHP_IMAGE_NAME):latest \
	  $(DOCKER_HUB)/$(PHP_IMAGE_NAME):$(LATEST_VERSION)
.PHONY: build-remote-all

build-remote-version: .buildx-create  ## Build specific remote php image for PHP_VERSION
	@set -e; \
	$(call cache_flags) ; \
	PLATFORM_CSV="$$(printf '%s' "$(PLATFORMS)" | tr ' ' ',')"; \
	tags="-t $(DOCKER_HUB)/$(PHP_IMAGE_NAME):$(PHP_VERSION)"; \
	$(call buildx_one,$$PLATFORM_CSV,$$tags,--build-arg PHP_VERSION=$(PHP_VERSION) --push --provenance=mode=max,src/Dockerfile,./src); \
	if [ "$(PHP_VERSION)" = "$(LATEST_VERSION)" ]; then \
	  echo ">>> Setting latest tag -> $(LATEST_VERSION)"; \
	  docker buildx imagetools create \
	    --tag $(DOCKER_HUB)/$(PHP_IMAGE_NAME):latest \
	    $(DOCKER_HUB)/$(PHP_IMAGE_NAME):$(LATEST_VERSION); \
	fi
.PHONY: build-remote-version

build-remote-latest: .buildx-create ## Build specific remote latest php image
	@set -e; \
	$(call cache_flags) ; \
	PLATFORM_CSV="$$(printf '%s' "$(PLATFORMS)" | tr ' ' ',')"; \
	tags="-t $(DOCKER_HUB)/$(PHP_IMAGE_NAME):latest -t $(DOCKER_HUB)/$(PHP_IMAGE_NAME):$(LATEST_VERSION)"; \
	$(call buildx_one,$$PLATFORM_CSV,$$tags,--build-arg PHP_VERSION=$(LATEST_VERSION) --push --provenance=mode=max,src/Dockerfile,./src)
.PHONY: build-remote-latest

build-test-images: .buildx-create ## Build multiplatform images for local testing (iteriert PLATFORMS; optional Cache)
	@set -e; \
	$(call cache_flags) ; \
	for arch in $(PLATFORMS); do \
	  tag="-t $(PHP_IMAGE_NAME):$${arch##*/}-test"; \
	  echo "Building test image for $$arch ..."; \
	  $(call buildx_one,$$arch,$$tag,--build-arg PHP_VERSION=$(PHP_VERSION) --load,src/Dockerfile,./src); \
	done; \
	echo "Local multiplatform build completed. Use $(PHP_IMAGE_NAME):arm64-test and $(PHP_IMAGE_NAME):amd64-test"
.PHONY: build-test-images

clean:  ## Stops and removes containers, images and caches
	$(DOCKER_COMPOSE) down --volumes --remove-orphans --rmi "all"
	@docker buildx prune -a -f
	docker images --filter dangling=true -q | xargs -r docker rmi
.PHONY: clean

clean-cache:  ## Remove only buildx cache and dangling images (keeps running containers)
	@docker buildx prune -a -f
	docker images --filter dangling=true -q | xargs -r docker rmi
.PHONY: clean-cache

shell: ## Run a shell inside the container (compose service)
	$(DOCKER_COMPOSE) run --rm -it $(PHP_IMAGE_NAME) sh
.PHONY: shell

# ---------------------------------------------------------------------------

.buildx-create:
	@docker buildx ls | grep -q 'multiarch-builder' || docker buildx create --name multiarch-builder --use
	@docker buildx use multiarch-builder
.PHONY: .buildx-create

define cache_flags
  set +u; \
  BACKEND="$${CACHE_BACKEND:-auto}"; \
  if [ -z "$$BACKEND" ] || [ "$$BACKEND" = "auto" ]; then \
    if [ "$${GITHUB_ACTIONS:-}" = "true" ]; then BACKEND="gha"; \
    elif [ "$${CI:-}" = "true" ]; then BACKEND="registry"; \
    else BACKEND="none"; fi; \
  fi; \
  case "$$BACKEND" in \
    gha)      CFROM="--cache-from=type=gha"; \
              CTO="--cache-to=type=gha,mode=max";; \
    registry) if [ -z "$(CACHE_REF)" ]; then echo "ERROR: CACHE_REF required for registry backend" >&2; exit 2; fi; \
              CFROM="--cache-from=type=registry,ref=$(CACHE_REF)"; \
              CTO="--cache-to=type=registry,ref=$(CACHE_REF),mode=max";; \
    local)    mkdir -p "$(CACHE_DIR)"; \
              CFROM="--cache-from=type=local,src=$(CACHE_DIR)"; \
              CTO="--cache-to=type=local,dest=$(CACHE_DIR),mode=max";; \
    none|"")  CFROM=""; CTO="";; \
    *)        echo "ERROR: unknown CACHE_BACKEND=$$BACKEND" >&2; exit 2;; \
  esac; \
  echo ">> Cache backend: $$BACKEND"
endef

define buildx_one
  docker buildx build \
    --platform $(1) \
    $$CFROM $$CTO \
    $(BUILD_ARGS) \
    $$( [ "$(NO_CACHE)" = "true" ] && echo "--no-cache" ) \
    $(2) \
    $(3) \
    -f $(4) \
    $(5)
endef
