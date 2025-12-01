#!/bin/bash
set -e

# =============================================================================
# Headgent PHP CLI - Runtime Configuration Script
# Generates PHP configuration based on environment variables at container startup
# =============================================================================

# Ensure the user config directory exists
mkdir -p /home/appuser/php-config

# =============================================================================
# Automatic conflict resolution: PCOV and Xdebug are mutually exclusive
# =============================================================================
# If PCOV is enabled, automatically disable Xdebug
if [ "${PCOV_ENABLED}" = "1" ]; then
  XDEBUG_MODE=off
  echo "ℹ️  PCOV enabled - automatically disabling Xdebug (XDEBUG_MODE=off)"
fi

# Generate dynamic PHP configuration based on environment variables
cat > /home/appuser/php-config/99-runtime-config.ini << PHPINI
; =============================================================================
; Headgent Digital PHP CLI Runtime Configuration
; Generated at container startup from environment variables
; Override any setting by setting the corresponding ENV variable
; =============================================================================

; Memory settings
memory_limit = ${PHP_MEMORY_LIMIT}
max_execution_time = ${PHP_MAX_EXECUTION_TIME}

; Date settings
date.timezone = ${PHP_TIMEZONE}

; Error handling
error_reporting = ${PHP_ERROR_REPORTING}
display_errors = ${PHP_DISPLAY_ERRORS}
log_errors = ${PHP_LOG_ERRORS}

; APCu configuration
apc.enabled = 1
apc.shm_size = ${APCU_SHM_SIZE}
apc.enable_cli = 1
apc.serializer = php

; OPcache configuration (enabled for both AMD64 and ARM64)
opcache.enable = 1
opcache.enable_cli = 1
opcache.memory_consumption = ${OPCACHE_MEMORY_CONSUMPTION}
opcache.interned_strings_buffer = 8
opcache.max_accelerated_files = ${OPCACHE_MAX_ACCELERATED_FILES}
opcache.revalidate_freq = ${OPCACHE_REVALIDATE_FREQ}
opcache.fast_shutdown = 1

; JIT enabled by default (PHP 8.2+, stable on AMD64 and ARM64)
; Set OPCACHE_JIT=off or OPCACHE_JIT_BUFFER_SIZE=0 to disable
opcache.jit = ${OPCACHE_JIT}
opcache.jit_buffer_size = ${OPCACHE_JIT_BUFFER_SIZE}

; Xdebug configuration (runtime controllable)
; IMPORTANT: Set XDEBUG_MODE=off for production to enable JIT
; Xdebug in debug mode disables JIT due to conflicts with zend_execute_ex
xdebug.mode = ${XDEBUG_MODE}
xdebug.start_with_request = ${XDEBUG_START_WITH_REQUEST}
xdebug.client_host = ${XDEBUG_CLIENT_HOST}
xdebug.client_port = ${XDEBUG_CLIENT_PORT}
xdebug.log_level = ${XDEBUG_LOG_LEVEL}

; PCOV configuration (runtime controllable)
; IMPORTANT: pcov and xdebug are mutually exclusive for code coverage
; Set PCOV_ENABLED=1 to enable pcov (faster coverage than xdebug)
; When enabled, xdebug should be set to XDEBUG_MODE=off
pcov.enabled = ${PCOV_ENABLED}

; Security settings
expose_php = Off
PHPINI

# Execute the original command
exec "$@"
