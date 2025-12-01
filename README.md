
# Headgent PHP CLI

![Build Status](https://github.com/headgent/phpcli/actions/workflows/ci.yml/badge.svg)
[![Docker Image Version](https://img.shields.io/docker/v/headgent/phpcli?sort=semver)](https://hub.docker.com/r/headgent/phpcli)

### Production-grade PHP CLI images built for modern workloads

Ship faster, scale smarter, and deploy with confidence. Our battle-tested images power **PHP 8.2–8.4** workloads on **linux/amd64** and **linux/arm64**, delivering enterprise performance with developer-friendly defaults.

---

## 🚀 Why Choose Headgent PHP CLI?

### Built for Production, Optimized for Performance

Modern PHP applications demand more than basic runtime environments. **Headgent PHP CLI** delivers a complete, production-ready foundation that eliminates infrastructure complexity and accelerates your deployment pipeline:

- **🎯 Zero-Configuration Message Queues** – RabbitMQ (`amqp`) and Kafka (`rdkafka`) extensions pre-installed for asynchronous job processing, event-driven architectures, and microservices communication
- **⚡ Maximum Performance** – OPcache + JIT enabled by default on all platforms (AMD64 & ARM64), delivering up to 3x faster execution for compute-intensive CLI workloads
- **🔒 Security-First Design** – Non-root user, minimal attack surface, production `php.ini`, and regular security updates from Alpine Linux
- **🔄 True Multi-Arch Support** – Native ARM64 support means seamless deployment on Apple Silicon, AWS Graviton, and modern cloud infrastructure
- **📦 Reproducible Builds** – Pinned PECL versions, locked Alpine base, and controlled dependencies guarantee identical behavior across dev, staging, and production
- **🛠️ Developer Experience** – Runtime-configurable via ENV vars, Xdebug pre-installed, and Composer ready to go—no Dockerfile editing required

---

## ✨ What's Inside

### Complete Extension Stack for Professional PHP

**Database Connectivity:**
- `pdo`, `pdo_mysql`, `mysqli`, `pdo_pgsql` – Full MySQL/MariaDB and PostgreSQL support

**Message Queue & Caching:**
- `amqp` (PECL 2.1.2) – RabbitMQ client for reliable message delivery
- `rdkafka` (PECL 6.0.5) – Apache Kafka client for high-throughput event streaming
- `apcu` (PECL 5.1.27) – In-memory user cache for blazing-fast data access
- `redis` (PECL 6.2.0) – Redis client for distributed caching and pub/sub

**Web Services & I/O:**
- `curl`, `soap` – HTTP/REST API clients and SOAP web services
- `sockets` – Low-level network socket programming
- `dom`, `zip` – XML processing and archive manipulation

**Internationalization & Data:**
- `mbstring`, `intl` – Unicode and multi-language support
- `bcmath` – Arbitrary precision mathematics

**Media Processing:**
- `gd` (FreeType + JPEG support) – Image generation and manipulation
- `exif` – Extract image metadata

**Development & Debugging:**
- `xdebug` (PECL 3.4.5) – Step debugging with breakpoint support
- `pcov` (PECL 1.0.12) – Fast code coverage for CI/CD pipelines
- `pcntl` – Process control for worker queues and daemons
- `opcache` – Bytecode cache with JIT compilation (built-in)

**Performance Foundation:**
- **OPcache** enabled for CLI/FPM – Eliminates PHP compilation overhead
- **JIT** enabled by default (mode `1254`) – Up to 3x performance boost for CPU-intensive code
- **Two-stage build** – Full toolchain isolated to build stage, lean runtime (~142-148MB)

---

## 🎯 Perfect For

- **Asynchronous Job Workers** – Laravel Queue, Symfony Messenger, custom worker pools
- **Event-Driven Microservices** – RabbitMQ/Kafka consumers, event processors, CQRS systems
- **Scheduled Tasks & Cron Jobs** – Database maintenance, report generation, data synchronization
- **CLI Tools & Scripts** – Deployment automation, data migration, DevOps utilities
- **API Clients & Integrations** – Third-party API consumers, webhook processors
- **Long-Running Daemons** – WebSocket servers, IoT data collectors, real-time processors

---

## 🏗️ Architecture & Tags

### Multi-Architecture Support
- **linux/amd64** – Intel/AMD x86_64 processors
- **linux/arm64** – Apple Silicon (M1/M2/M3), AWS Graviton, Ampere, Raspberry Pi 4+

### Version Tags
- `8.2`, `8.3`, `8.4` – Specific PHP minor versions
- `latest` → Currently tracks `8.4` (highest stable version)

**Published on Docker Hub:** https://hub.docker.com/r/headgent/phpcli/tags

**Minimum PHP Version:** 8.2 (JIT stable from this version)
**PHP 8.5 Support:** Will be added when official Docker images are released (expected November 2025)

---

## ⚡ Performance: OPcache & JIT

PHP 8.2+ delivers production-stable JIT (Just-In-Time) compilation on both AMD64 and ARM64. Our images enable JIT by default with optimal settings for CLI workloads.

### Configuration Modes

**🛠️ Development Mode (Default)**
```bash
# Xdebug active, JIT automatically disabled by PHP
XDEBUG_MODE=debug  # (default)
```
- ✅ Step debugging with breakpoints works out-of-the-box
- ⚠️ PHP automatically disables JIT (expected behavior due to `zend_execute_ex()` conflict)
- 🎯 Optimized for local development and debugging workflows

**🚀 Production Mode**
```bash
# Xdebug inactive, JIT enabled for maximum performance
XDEBUG_MODE=off
```
- ✅ JIT fully operational (up to 3x faster execution)
- ✅ Minimal overhead, maximum throughput
- 🎯 Recommended for staging, production, and performance testing

**🔧 Manual JIT Control**
```bash
# Disable JIT regardless of Xdebug mode
OPCACHE_JIT=off
# or
OPCACHE_JIT_BUFFER_SIZE=0
```

**💡 Key Insight:** Xdebug and JIT cannot run simultaneously. This is by design—when `XDEBUG_MODE=debug`, PHP automatically disables JIT to ensure debugging reliability. The warning you see is informational, not an error.

---

## 📊 Code Coverage: PCOV vs Xdebug

### Why PCOV?

When running code coverage in CI/CD pipelines, **PCOV is 2x faster** than Xdebug because it's purpose-built for coverage collection without debugging overhead.

### Configuration Modes

**🚀 Fast Coverage Mode (PCOV)**
```bash
# Enable PCOV for fast code coverage
docker run --rm \
  -e PCOV_ENABLED=1 \
  -v $(pwd):/app \
  headgent/phpcli:8.4 \
  vendor/bin/phpunit --coverage-html coverage/
```
- ✅ PCOV automatically activated
- ✅ Xdebug automatically disabled (conflict resolution)
- ✅ ~2x faster than Xdebug coverage
- 🎯 Recommended for CI/CD pipelines

**🔍 Debug + Coverage Mode (Xdebug)**
```bash
# Use Xdebug for debugging AND coverage
docker run --rm \
  -e XDEBUG_MODE=coverage,debug \
  -v $(pwd):/app \
  headgent/phpcli:8.4 \
  vendor/bin/phpunit --coverage-html coverage/
```
- ✅ Step debugging + coverage in one tool
- ⚠️ Slower than PCOV
- 🎯 Use when you need debugging capabilities

**⚡ Production Mode (No Coverage)**
```bash
# Disable both for maximum performance
docker run --rm \
  -e XDEBUG_MODE=off \
  -e PCOV_ENABLED=0 \
  -v $(pwd):/app \
  headgent/phpcli:8.4 \
  vendor/bin/phpunit
```
- ✅ JIT fully operational
- ✅ Maximum test execution speed
- 🎯 Use for performance benchmarks

### Automatic Conflict Resolution

**Smart Logic:** When `PCOV_ENABLED=1`, the entrypoint automatically sets `XDEBUG_MODE=off` to prevent conflicts. You don't need to manage this manually.

```bash
# This automatically disables Xdebug
docker run --rm -e PCOV_ENABLED=1 headgent/phpcli:8.4 php -v
# Output: "ℹ️  PCOV enabled - automatically disabling Xdebug (XDEBUG_MODE=off)"
```

---

## 🔧 Configuration

All settings can be overridden at runtime via `docker run -e VAR=value`:

### Runtime Environment Variables

| Category | Variable | Default | Description |
|---|---|---|---|
| **PHP Core** | `PHP_MEMORY_LIMIT` | `512M` | Maximum memory per script |
| | `PHP_MAX_EXECUTION_TIME` | `0` | Max execution time (0 = unlimited) |
| | `PHP_TIMEZONE` | `UTC` | Default timezone |
| | `PHP_ERROR_REPORTING` | `E_ALL & ~E_DEPRECATED` | Error reporting level |
| | `PHP_DISPLAY_ERRORS` | `Off` | Display errors to output |
| | `PHP_LOG_ERRORS` | `On` | Log errors to file/stderr |
| **OPcache** | `OPCACHE_MEMORY_CONSUMPTION` | `128` | OPcache memory (MB) |
| | `OPCACHE_MAX_ACCELERATED_FILES` | `4000` | Max cached files |
| | `OPCACHE_REVALIDATE_FREQ` | `2` | Revalidate interval (seconds) |
| | `OPCACHE_JIT` | `1254` | JIT mode (1254=tracing, off=disabled) |
| | `OPCACHE_JIT_BUFFER_SIZE` | `128M` | JIT buffer size |
| **APCu** | `APCU_SHM_SIZE` | `64M` | Shared memory size |
| **Xdebug** | `XDEBUG_MODE` | `debug` | `debug`, `develop`, `trace`, `coverage`, `off` |
| | `XDEBUG_START_WITH_REQUEST` | `yes` | Auto-start debugging |
| | `XDEBUG_CLIENT_HOST` | `host.docker.internal` | IDE host (macOS/Windows) |
| | `XDEBUG_CLIENT_PORT` | `9003` | IDE port |
| | `XDEBUG_LOG_LEVEL` | `0` | Log verbosity (0-10) |
| **PCOV** | `PCOV_ENABLED` | `0` | `1`=enabled, `0`=disabled (auto-disables Xdebug when `1`) |

### PECL Extension Versions

| Extension | Version | Purpose |
|---|---|---|
| `amqp` | `2.1.2` | RabbitMQ AMQP 0-9-1 protocol client |
| `rdkafka` | `6.0.5` | Apache Kafka high-performance client |
| `apcu` | `5.1.27` | In-memory user cache |
| `redis` | `6.2.0` | Redis client for caching/pub-sub |
| `xdebug` | `3.4.5` | Step debugging with breakpoints |
| `pcov` | `1.0.12` | Fast code coverage collection |

### Build Arguments

All runtime defaults can also be set at build time via `--build-arg`:
- **Versions:** `PHP_VERSION`, `ALPINE_VERSION`, `APCU_VERSION`, `REDIS_VERSION`, `XDEBUG_VERSION`, `PCOV_VERSION`, `AMQP_VERSION`, `RDKAFKA_VERSION`
- **PHP Settings:** All runtime environment variables listed above

> 💡 **Configuration Philosophy:** Build ARGs set defaults, ENV vars override at runtime. No Dockerfile edits needed for configuration changes.

---

## 🚀 Quick Start

### Pull & Run
```bash
# Pull latest version
docker pull headgent/phpcli:latest

# Print PHP info
docker run --rm headgent/phpcli:8.4 php -v

# Check loaded extensions (including message queue support)
docker run --rm headgent/phpcli:8.4 php -m

# Verify JIT status (production mode)
docker run --rm -e XDEBUG_MODE=off headgent/phpcli:8.4 \
  php -r '$s=opcache_get_status(); echo "JIT: ".($s["jit"]["on"]?"✅ ACTIVE":"❌ OFF")."\n";'
```

### Production Deployment
```bash
# Run with optimized settings for production
docker run --rm \
  -e XDEBUG_MODE=off \
  -e PHP_MEMORY_LIMIT=1G \
  -e OPCACHE_JIT_BUFFER_SIZE=256M \
  -v $(pwd):/app \
  headgent/phpcli:8.4 \
  php artisan queue:work
```

### Development with Xdebug
```bash
# Run with debugging enabled (default)
docker run --rm \
  -e XDEBUG_MODE=debug \
  -e XDEBUG_CLIENT_HOST=host.docker.internal \
  -v $(pwd):/app \
  headgent/phpcli:8.4 \
  php your-script.php
```

### RabbitMQ Worker Example
```bash
# Laravel Queue worker with RabbitMQ
docker run --rm \
  -e XDEBUG_MODE=off \
  -e PHP_MEMORY_LIMIT=512M \
  --network=app-network \
  -v $(pwd):/app \
  headgent/phpcli:8.4 \
  php artisan queue:work rabbitmq --tries=3
```

### Kafka Consumer Example
```bash
# Symfony Messenger Kafka consumer
docker run --rm \
  -e XDEBUG_MODE=off \
  -e PHP_MAX_EXECUTION_TIME=0 \
  --network=app-network \
  -v $(pwd):/app \
  headgent/phpcli:8.4 \
  php bin/console messenger:consume kafka_events --memory-limit=512M
```

### Composer Usage
```bash
# Install dependencies
docker run --rm -v $(pwd):/app headgent/phpcli:8.4 composer install

# Update dependencies
docker run --rm -v $(pwd):/app headgent/phpcli:8.4 composer update

# Run scripts
docker run --rm -v $(pwd):/app headgent/phpcli:8.4 composer run-script test
```

---

## 🔬 Build & Test (For Contributors)

### Local Build
```bash
# Clone repository
git clone https://github.com/headgent/phpcli.git
cd phpcli

# Build single version
make build

# Build all PHP versions (8.2, 8.3, 8.4)
make build-all

# Build multi-arch test images
make build-test-images
```

### Testing
```bash
# Run all tests (OPcache, JIT, extensions) on both architectures
make test-all

# Test OPcache & JIT specifically
make test-opcache

# Test extension loading
make test-extensions
```

### Makefile Targets
- `make build` – Build single version from `.env` (native arch)
- `make build-all` – Build all PHP versions locally
- `make build-test-images` – Build multi-arch test images (`:amd64-test`, `:arm64-test`)
- `make build-remote-all` – Build & push all versions to Docker Hub (multi-arch manifests)
- `make test-all` – Verify OPcache, JIT, and all extensions on both architectures
- `make shell` – Interactive shell in container
- `make clean` – Remove containers, images, caches
- `make info` – Display current `.env` settings

---

## 📊 Image Size

**Optimized for Production:**
- PHP 8.2/8.3: **~142MB** (compressed)
- PHP 8.4: **~148MB** (compressed)

**What's Included:**
- Complete PHP runtime with 20+ extensions
- RabbitMQ + Kafka support
- Composer
- OPcache + JIT
- Development tools (Xdebug)

**What's NOT Included:**
- Build toolchain (isolated to build stage)
- MySQL client (optional via `INSTALL_MYSQL_CLIENT=true`)
- Unnecessary system packages

---

## 🔒 Security

- **Non-root user:** All processes run as `appuser` (UID/GID 1001)
- **Minimal attack surface:** Only runtime dependencies in final image
- **Regular updates:** Built on Alpine Linux with security patches
- **Production defaults:** `expose_php=Off`, secure error handling
- **Healthcheck included:** Validates PHP and Composer on startup

---

## 📄 License

MIT © Headgent GmbH

---

## 💬 Support

- **Issues:** https://github.com/headgent/phpcli/issues
- **Docker Hub:** https://hub.docker.com/r/headgent/phpcli
- **Email:** devops@headgent.dev

---

**Built with ❤️ by Headgent GmbH** – Empowering developers to ship production-ready PHP applications with confidence.
