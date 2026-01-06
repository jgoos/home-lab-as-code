RHEL_VERSION ?= 10
RHEL_VERSIONS ?= 7 8 9 10

ISO_PATH_7 ?= packer/iso-files/rhel-server-7.9-x86_64-dvd.iso
ISO_SHA256_7 ?= 19d653ce2f04f202e79773a0cbeda82070e7527557e814ebbce658773fbe8191
ISO_LABEL_7 ?=

ISO_PATH_8 ?= packer/iso-files/rhel-8.6-x86_64-dvd.iso
ISO_SHA256_8 ?= c324f3b07283f9393168f0a4ad2167ebbf7e4699d65c9670e0d9e58ba4e2a9a8
ISO_LABEL_8 ?=

ISO_PATH_9 ?= packer/iso-files/rhel-baseos-9.0-x86_64-dvd.iso
ISO_SHA256_9 ?= a387f3230acf87ee38707ee90d3c88f44d7bf579e6325492f562f0f1f9449e89
ISO_LABEL_9 ?=

ISO_PATH_10 ?= packer/iso-files/rhel-10.1-x86_64-dvd.iso
ISO_SHA256_10 ?= 5925e05c32d8324a72e146a29293d60707571817769de73df63eab8dbd6d3196
ISO_LABEL_10 ?= RHEL-10-1-BaseOS-x86_64
PACKER_CONFIG ?= packer
PACKER_ONLY ?= qemu.rhel$(RHEL_VERSION)
ARTIFACTS_DIR ?= artifacts/packer
OUTPUT_DIR ?= $(ARTIFACTS_DIR)/output-rhel$(RHEL_VERSION)
ISO_PATH ?= $(ISO_PATH_$(RHEL_VERSION))
ISO_SHA256 ?= $(ISO_SHA256_$(RHEL_VERSION))
ISO_CHECKSUM ?= sha256:$(ISO_SHA256)
ISO_LABEL ?= $(ISO_LABEL_$(RHEL_VERSION))
BREAKPOINT_ENABLED ?= false
PACKER_LOG_PATH ?= $(ARTIFACTS_DIR)/packer-debug.log
PACKER_UI_LOG ?= $(ARTIFACTS_DIR)/packer-ui.log
SSH_USERNAME ?= cloud-user
SSH_PASSWORD ?= cloud-user
DISK_SIZE ?= 20G
MEMORY ?= 2048
CPUS ?= 2
BOOT_WAIT ?= 15s
BOOT_KEY_INTERVAL ?= 100ms
SERIAL_LOG ?= $(ARTIFACTS_DIR)/serial-rhel$(RHEL_VERSION).log

.PHONY: packer-preflight packer-init packer-validate \
	packer-build packer-build-debug packer-serial-tail \
	packer-build-all

packer-preflight:
	@mkdir -p $(ARTIFACTS_DIR)
	@command -v packer >/dev/null 2>&1 || { echo "ERROR: packer not found in PATH"; exit 1; }
	@test -f $(ISO_PATH) || { echo "ERROR: ISO not found at $(ISO_PATH)"; exit 1; }
	@$(MAKE) _packer-checksum

_packer-checksum:
	@set -e; \
	if command -v sha256sum >/dev/null 2>&1; then \
		actual=$$(sha256sum $(ISO_PATH) | awk '{print $$1}'); \
	elif command -v shasum >/dev/null 2>&1; then \
		actual=$$(shasum -a 256 $(ISO_PATH) | awk '{print $$1}'); \
	else \
		echo "ERROR: sha256sum or shasum is required"; exit 1; \
	fi; \
	if [ "$$actual" != "$(ISO_SHA256)" ]; then \
		echo "ERROR: SHA-256 mismatch"; \
		echo "  expected: $(ISO_SHA256)"; \
		echo "  actual:   $$actual"; \
		exit 1; \
	fi; \
	echo "OK: SHA-256 matches $(ISO_SHA256)"

packer-init: packer-preflight
	@packer init $(PACKER_CONFIG)

packer-validate: packer-preflight
	@packer validate -only=$(PACKER_ONLY) \
		-var "iso_path=$(abspath $(ISO_PATH))" \
		-var "iso_checksum=$(ISO_CHECKSUM)" \
		-var "iso_label=$(ISO_LABEL)" \
		-var "artifacts_dir=$(abspath $(ARTIFACTS_DIR))" \
		-var "breakpoint_enabled=$(BREAKPOINT_ENABLED)" \
		-var "ssh_username=$(SSH_USERNAME)" \
		-var "ssh_password=$(SSH_PASSWORD)" \
		-var "disk_size=$(DISK_SIZE)" \
		-var "memory=$(MEMORY)" \
		-var "cpus=$(CPUS)" \
		-var "boot_wait=$(BOOT_WAIT)" \
		-var "boot_key_interval=$(BOOT_KEY_INTERVAL)" \
		$(PACKER_CONFIG)

packer-build: packer-preflight
	@mkdir -p $(ARTIFACTS_DIR)
	@rm -rf $(OUTPUT_DIR)
	@set -o pipefail; PACKER_LOG=1 PACKER_LOG_PATH=$(PACKER_LOG_PATH) \
		packer build -timestamp-ui -machine-readable -on-error=run-cleanup-provisioner -only=$(PACKER_ONLY) \
		-var "iso_path=$(abspath $(ISO_PATH))" \
		-var "iso_checksum=$(ISO_CHECKSUM)" \
		-var "iso_label=$(ISO_LABEL)" \
		-var "artifacts_dir=$(abspath $(ARTIFACTS_DIR))" \
		-var "breakpoint_enabled=$(BREAKPOINT_ENABLED)" \
		-var "ssh_username=$(SSH_USERNAME)" \
		-var "ssh_password=$(SSH_PASSWORD)" \
		-var "disk_size=$(DISK_SIZE)" \
		-var "memory=$(MEMORY)" \
		-var "cpus=$(CPUS)" \
		-var "boot_wait=$(BOOT_WAIT)" \
		-var "boot_key_interval=$(BOOT_KEY_INTERVAL)" \
		$(PACKER_CONFIG) | tee $(PACKER_UI_LOG)

packer-build-debug: packer-preflight
	@echo "DEBUG MODE: requires a TTY; this is intended for local, interactive use only."
	@mkdir -p $(ARTIFACTS_DIR)
	@rm -rf $(OUTPUT_DIR)
	@set -o pipefail; PACKER_LOG=1 PACKER_LOG_PATH=$(PACKER_LOG_PATH) \
		packer build -debug -timestamp-ui -on-error=ask -only=$(PACKER_ONLY) \
		-var "iso_path=$(abspath $(ISO_PATH))" \
		-var "iso_checksum=$(ISO_CHECKSUM)" \
		-var "iso_label=$(ISO_LABEL)" \
		-var "artifacts_dir=$(abspath $(ARTIFACTS_DIR))" \
		-var "breakpoint_enabled=$(BREAKPOINT_ENABLED)" \
		-var "ssh_username=$(SSH_USERNAME)" \
		-var "ssh_password=$(SSH_PASSWORD)" \
		-var "disk_size=$(DISK_SIZE)" \
		-var "memory=$(MEMORY)" \
		-var "cpus=$(CPUS)" \
		-var "boot_wait=$(BOOT_WAIT)" \
		-var "boot_key_interval=$(BOOT_KEY_INTERVAL)" \
		$(PACKER_CONFIG) | tee $(PACKER_UI_LOG)

packer-serial-tail:
	@mkdir -p $(ARTIFACTS_DIR)
	@echo "Tailing serial console: $(SERIAL_LOG)"
	@tail -f $(SERIAL_LOG)

packer-build-all:
	@set -e; \
	for v in $(RHEL_VERSIONS); do \
		echo "==> Building RHEL $$v"; \
		$(MAKE) packer-build RHEL_VERSION=$$v; \
	done
