# ---------------------------------------------------------------------------
# Tests (Multi-Arch: amd64 & arm64)
# Erwartete Tags: $(PHP_IMAGE_NAME):amd64-test und :arm64-test
# ---------------------------------------------------------------------------
##@ Test

PHP_EXTENSIONS := apcu redis gd intl mbstring pcntl bcmath soap exif sockets dom zip mysqli curl pdo_mysql pdo_pgsql pcov amqp rdkafka

test-opcache: build-test-images ## OPcache geladen + aktiv (enable & enable_cli) und JIT aktiviert auf beiden Archs
	@set -e; \
	for arch in amd64 arm64; do \
	  echo ">>> Prüfen: OPcache & JIT auf $$arch"; \
	  docker run --rm --platform=linux/$$arch -e XDEBUG_MODE=off $(PHP_IMAGE_NAME):$$arch-test php -r "\
if (!(extension_loaded('Zend OPcache') || extension_loaded('opcache'))) {fwrite(STDERR,'OPcache nicht geladen'); exit(1);} \
if (ini_get('opcache.enable')!=='1')     {fwrite(STDERR,'opcache.enable != '.ini_get('opcache.enable')); exit(1);} \
if (ini_get('opcache.enable_cli')!=='1') {fwrite(STDERR,'opcache.enable_cli != '.ini_get('opcache.enable_cli')); exit(1);} \
\$$jit = ini_get('opcache.jit'); \
if (in_array(strtolower((string)\$$jit), ['', '0','off','disable','disabled'], true)) {fwrite(STDERR,'opcache.jit ist deaktiviert: '.\$$jit); exit(1);} \
\$$jit_buffer = ini_get('opcache.jit_buffer_size'); \
if (\$$jit_buffer === '0' || \$$jit_buffer === '' || (int)\$$jit_buffer === 0) {fwrite(STDERR,'opcache.jit_buffer_size ist 0'); exit(1);} \
"; \
	  echo "✅ OPcache aktiv & JIT aktiviert auf $$arch"; \
	done
.PHONY: test-opcache

test-extensions: build-test-images ## Alle gewünschten Erweiterungen geladen auf beiden Archs
	@set -e; \
	for arch in amd64 arm64; do \
	  echo ">>> Prüfen: PHP-Erweiterungen auf $$arch"; \
	  for ext in $(PHP_EXTENSIONS); do \
	    docker run --rm --platform=linux/$$arch $(PHP_IMAGE_NAME):$$arch-test php -r "\
if (!extension_loaded('$$ext')) {fwrite(STDERR,'Fehlt: $$ext'); exit(1);} \
"; \
	  done; \
	  echo "✅ Alle Extensions geladen auf $$arch"; \
	done
.PHONY: test-extensions

## Kombi
test-all: test-opcache test-extensions ## Alle Tests
	@echo "✅ Alle Tests für AMD64 und ARM64 bestanden!"
.PHONY: test-all
