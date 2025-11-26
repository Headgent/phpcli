# Headgent PHP CLI

![Build Status](https://github.com/headgent/phpcli/actions/workflows/ci.yml/badge.svg)
[![Docker Image Version](https://img.shields.io/docker/v/headgent/phpcli?sort=semver)](https://hub.docker.com/r/headgent/phpcli)

### Versionierte, Multi-Arch PHP CLI Images für schnelle, reproduzierbare Konsolenanwendungen

Unsere Images unterstützen **PHP 8.2 – 8.4** (Mindestversion 8.2), laufen auf **linux/amd64** und **linux/arm64** und sind optimiert für stabile, produktionsreife CLI-Workloads.

---

## ✨Highlights

- **Konsistente Multi-Arch Builds** (AMD64 + ARM64) via `buildx`.
- **OPcache + JIT standardmäßig auf allen Plattformen aktiviert** für maximale Performance (opt-out via ENV).
- **PECL-Extensions festgesetzt** für reproduzierbare Builds: `apcu`, `redis`, `xdebug`.
- **Production-first Runtime**: Zwei-Stage-Build, minimale Runtime-Dependencies, Non‑Root User.
- **Laufzeit-konfigurierbares PHP** über ENV und ein Entrypoint, der beim Containerstart eine dedizierte `99-runtime-config.ini` erzeugt.
- **Composer vorinstalliert** und sofort nutzbar.

---

## Features

- **Erweiterungen (gebaut/installiert):**
    - Core DB: `pdo`, `pdo_mysql`, `mysqli`, `pdo_pgsql`
    - Caching: `apcu` (PECL), `redis` (PECL)
    - Web/IO: `curl`, `soap`
    - Daten: `dom`, `zip`
    - i18n: `mbstring`, `intl`
    - Prozesse: `pcntl`
    - Mathematik: `bcmath`
    - Bilder & Metadaten: `gd` (mit FreeType/JPEG), `exif`
    - Networking: `sockets`
    - Debug: `xdebug` (PECL)
    - Performance: `opcache` (built-in)
- **Runtime:**
    - **Alpine Linux** Base, produktives `php.ini`
    - **Non-root User** (`appuser`), **Healthcheck**, **Composer** vorinstalliert
    - Entrypoint generiert `99-runtime-config.ini` aus ENV

---

## 🔑 Fundamentale Vorteile

- **Reproduzierbarkeit:** Fixierte PECL-Versionen + kontrolliertes Alpine-Base = stabile, wiederholbare Builds.
- **Performance & Stabilität:** OPcache + JIT aktiviert (PHP 8.2+ stabil auf AMD64 & ARM64).
- **Schlanke Runtime:** Voller Toolchain nur im Build-Stage; Runtime bleibt minimal.
- **Security by default:** Non‑Root `appuser`, Healthchecks und klare Konfigurationsgrenzen.
- **Multi-Version-Strategie:** Ein einziges Dockerfile baut 8.2/8.3/8.4 mit identischem Verhalten.

---

## Architekturen & Tags

- Architekturen: **linux/amd64**, **linux/arm64**
- Tags: `8.2`, `8.3`, `8.4` und `latest` → verweist auf die höchste deklarierte Version (aktuell `8.4`)

Images werden auf Docker Hub veröffentlicht: https://hub.docker.com/r/headgent/phpcli/tags

---

## ⚙️ OPcache & JIT

- ✅ **OPcache** ist **aktiviert** für CLI und FPM Kontexte.
- ✅ **JIT** ist **standardmäßig aktiviert** (Modus `1254` = Tracing-JIT mit Call-Graph).

PHP 8.2+ bietet stabilen JIT-Support auf AMD64- und ARM64-Plattformen.

### JIT-Konfigurationsmodi

**Entwicklungs-/Debug-Modus (Standard):**
- `XDEBUG_MODE=debug` (Standard)
- JIT wird **automatisch von PHP deaktiviert**
- Grund: Xdebug überschreibt `zend_execute_ex()`, was mit JIT inkompatibel ist
- Optimiert für Entwicklung mit Step-Debugging und Breakpoints

**Produktiv-Modus:**
- Setze `XDEBUG_MODE=off` in Produktion
- JIT ist **aktiv** und bietet maximale Performance
- Empfohlen für Produktiv-Workloads

**Opt-out (manuelle Deaktivierung):**
- Setze `OPCACHE_JIT=off` oder `OPCACHE_JIT_BUFFER_SIZE=0`
- JIT deaktiviert unabhängig vom Xdebug-Modus
- Verwende dies, wenn du JIT-Performance-Optimierungen explizit deaktivieren möchtest

⚠️ **Wichtig:** Xdebug und JIT können nicht gleichzeitig laufen. Wenn Xdebug im `debug`-Modus ist, gibt PHP eine Warnung aus und deaktiviert automatisch JIT. Dies ist erwartetes Verhalten und stellt sicher, dass die Debugging-Funktionalität korrekt funktioniert.

---


## 🔧 Konfigurierbare Parameter (komplett)

### Build-Argumente (werden zu Runtime-Defaults)
| ARG | Standard | Beschreibung |
|---|---:|---|
| `PHP_VERSION` | `8.3` | PHP Minor Version zum Bauen (`8.2`, `8.3`, `8.4`). |
| `ALPINE_VERSION` | `3.20` | Alpine Base Tag genutzt von `php:<PHP_VERSION>-cli-alpine<ALPINE_VERSION>`. |
| `APCU_VERSION` | `5.1.27` | PECL apcu Version (fixiert). |
| `REDIS_VERSION` | `6.2.0` | PECL redis Version (fixiert). |
| `XDEBUG_VERSION` | `3.4.5` | PECL xdebug Version (fixiert). |
| `PHP_MEMORY_LIMIT` | `512M` | Standard Memory Limit. |
| `PHP_MAX_EXECUTION_TIME` | `0` | Standard Max Execution Time (0 = unbegrenzt). |
| `PHP_TIMEZONE` | `UTC` | Standard Zeitzone. |
| `APCU_SHM_SIZE` | `64M` | Standard APCu Shared Memory Size. |
| `OPCACHE_MEMORY_CONSUMPTION` | `128` | OPcache Speicher in MB. |
| `OPCACHE_MAX_ACCELERATED_FILES` | `4000` | OPcache max gecachte Dateien. |
| `OPCACHE_REVALIDATE_FREQ` | `2` | OPcache Revalidate Intervall (Sek.). |
| `OPCACHE_JIT` | `1254` | JIT-Modus: `1254` (Tracing), `off`/`0` (deaktiviert). |
| `OPCACHE_JIT_BUFFER_SIZE` | `128M` | JIT-Puffergröße (auf `0` setzen zum Deaktivieren). |
| `PHP_ERROR_REPORTING` | `E_ALL & ~E_DEPRECATED & ~E_STRICT` | PHP Error Level. |
| `PHP_DISPLAY_ERRORS` | `Off` | PHP Display Errors. |
| `PHP_LOG_ERRORS` | `On` | PHP Log Errors. |

> Diese ARGs werden im Runtime-Stage in `ENV` kopiert und dienen als Standardwerte. Alle können via `docker run ... -e VAR=...` überschrieben werden.

### Runtime-Umgebung (PHP Core / Entrypoint-gesteuert)
| ENV | Typ | Standard | Hinweise |
|---|---|---:|---|
| `PHP_MEMORY_LIMIT` | string | `512M` | `memory_limit` |
| `PHP_MAX_EXECUTION_TIME` | int | `0` | `max_execution_time` |
| `PHP_TIMEZONE` | string | `UTC` | `date.timezone` |
| `PHP_ERROR_REPORTING` | string | `E_ALL & ~E_DEPRECATED & ~E_STRICT` | |
| `PHP_DISPLAY_ERRORS` | `On/Off` | `Off` | |
| `PHP_LOG_ERRORS` | `On/Off` | `On` | |
| `APCU_SHM_SIZE` | string | `64M` | `apc.shm_size`, `apc.enable_cli=1` fixiert |
| `OPCACHE_MEMORY_CONSUMPTION` | int | `128` | |
| `OPCACHE_MAX_ACCELERATED_FILES` | int | `4000` | |
| `OPCACHE_REVALIDATE_FREQ` | int | `2` | |
| `OPCACHE_JIT` | string/int | `1254` | JIT-Modus (z.B. `1254`, `off`, `0`). |
| `OPCACHE_JIT_BUFFER_SIZE` | string | `128M` | JIT-Puffergröße. Auf `0` setzen zum Deaktivieren. |
| *(durch Entrypoint fixiert)* | — | — | `opcache.enable=1`, `opcache.enable_cli=1`, `expose_php=Off`. |

### Runtime-Umgebung (Xdebug)
| ENV | Standard | Beschreibung |
|---|---:|---|
| `XDEBUG_MODE` | `debug` | z.B. `debug`, `develop`, `trace`, `coverage` (kommagetrennt). **⚠️ `debug`-Modus deaktiviert JIT! Auf `off` setzen für Produktion.** |
| `XDEBUG_START_WITH_REQUEST` | `yes` | `yes`/`no`. |
| `XDEBUG_CLIENT_HOST` | `host.docker.internal` | Typischerweise `host.docker.internal` (macOS/Windows) oder Host-IP. |
| `XDEBUG_CLIENT_PORT` | `9003` | Client Port. |
| `XDEBUG_LOG_LEVEL` | `0` | 0–10 (Verbose). |

> **Xdebug ist installiert und aktiviert; Verhalten wird über obige ENV-Variablen gesteuert.**
>
> - **`XDEBUG_MODE=debug` (Standard):** Aktiviert Step-Debugging mit Breakpoints. **JIT wird automatisch von PHP deaktiviert** aufgrund von Inkompatibilität mit Xdebugs `zend_execute_ex()`-Override. Optimiert für Entwicklung.
> - **`XDEBUG_MODE=off`:** Xdebug lädt, bleibt aber inaktiv. **JIT bleibt aktiv** für maximale Performance. Verwenden in Produktion.
>
> 💡 **Best Practice:** Standard ist für Entwicklung optimiert. Für Produktion `XDEBUG_MODE=off` setzen, um JIT zu aktivieren und Performance zu maximieren.

---

## Verwendung

### Build (einzelne Version)
```bash
docker build -t headgent/phpcli:8.3   --build-arg PHP_VERSION=8.3   --build-arg ALPINE_VERSION=3.20   --build-arg APCU_VERSION=5.1.27   --build-arg REDIS_VERSION=6.2.0   --build-arg XDEBUG_VERSION=3.4.5   ./src
```

### Run
```bash
# PHP Info anzeigen
docker run --rm headgent/phpcli:8.3 php -i | less

# Runtime-PHP-Einstellungen überschreiben
docker run --rm -e PHP_MEMORY_LIMIT=1G -e PHP_TIMEZONE=Europe/Berlin headgent/phpcli:8.3 php -r 'echo ini_get("memory_limit"),"\n",ini_get("date.timezone"),"\n";'

# Entwicklungs-Modus (Standard) - Xdebug aktiv, JIT deaktiviert
docker run --rm headgent/phpcli:8.3 php dein-script.php

# Produktiv-Modus - Xdebug deaktivieren um JIT zu aktivieren
docker run --rm -e XDEBUG_MODE=off headgent/phpcli:8.3 php dein-script.php

# JIT-Status überprüfen
docker run --rm headgent/phpcli:8.3 php -r '$s=opcache_get_status(); echo "JIT Aktiv: ".($s["jit"]["on"]?"JA":"NEIN")."\n";'

# Xdebug-Modus überprüfen
docker run --rm headgent/phpcli:8.3 php -r 'echo "Xdebug Mode: ".ini_get("xdebug.mode")."\n";'
```

### Hinweise zur Größe
- Runtime-Stage enthält nur, was zum **Ausführen** deiner App und **Composer** benötigt wird.
- Build-Toolchain existiert nur im Build-Stage.
- `mysql-client`) ist standardmäßig nicht installiert

---

## Healthcheck

Das Image enthält einen Healthcheck, der PHP und Composer validiert:
```
php --version >/dev/null && composer --version >/dev/null
```

---

## Makefile Targets (optional)

Wenn du unser `support/docker.mk` nutzt, erhältst du Helfer für lokale und Remote-Multi-Arch-Builds, Cache-Backends und Tests. Siehe Kommentare in dieser Datei für Beispiele:

- `make build` – baut den Compose-Service lokal
- `make build-all` – baut alle PHP-Versionen lokal (native Arch)
- `make build-test-images` – baut amd64/arm64 Test-Tags lokal (mit optionalem Caching)
- `make build-remote-all` – pusht Multi-Arch-Tags für alle PHP-Versionen
- `make test-all` – führt OPcache/JIT und Extension-Checks auf beiden Architekturen aus

---

## Lizenz

MIT © Headgent GmbH
