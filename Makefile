BUILDDIR:=$(shell pwd)

BUILDROOT=$(BUILDDIR)/buildroot
BUILDROOT_EXTERNAL=$(BUILDDIR)/buildroot-external
DEFCONFIG_DIR = $(BUILDROOT_EXTERNAL)/configs
VERSION_DATE := $(shell date -u +'%Y%m%d')
VERSION_DEV := "dev$(VERSION_DATE)"

TARGETS := $(notdir $(patsubst %_defconfig,%,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
TARGETS_CONFIG := $(notdir $(patsubst %_defconfig,%-config,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))

# Set O variable if not already done on the command line
ifneq ("$(origin O)", "command line")
O := $(BUILDDIR)/output
else
override O := $(BUILDDIR)/$(O)
endif

.NOTPARALLEL: $(TARGETS) $(TARGETS_CONFIG) all

.PHONY: $(TARGETS) $(TARGETS_CONFIG) all clean help

all: $(TARGETS)

savedefconfig:
	@echo "config $*"
	$(MAKE) -C $(BUILDROOT) O=$(O) BR2_EXTERNAL=$(BUILDROOT_EXTERNAL) "savedefconfig"

$(TARGETS_CONFIG): %-config:
	@echo "config $*"
	mv $(DEFCONFIG_DIR)/$*_defconfig $(DEFCONFIG_DIR)/$*_defconfig.original
	awk 1 $(DEFCONFIG_DIR)/$*_defconfig.original $(BUILDROOT_EXTERNAL)/overlay_defconfig > $(DEFCONFIG_DIR)/$*_defconfig
	$(MAKE) -C $(BUILDROOT) O=$(O) BR2_EXTERNAL=$(BUILDROOT_EXTERNAL) "$*_defconfig"
	mv $(DEFCONFIG_DIR)/$*_defconfig.original $(DEFCONFIG_DIR)/$*_defconfig

$(TARGETS): %: %-config
	@echo "build $@"
	$(MAKE) -C $(BUILDROOT) O=$(O) BR2_EXTERNAL=$(BUILDROOT_EXTERNAL) VERSION_DEV=$(VERSION_DEV)
	mv $O/images/sdcard.img $O/images/$@.img
	cp $O/images/$@.img $O/images/$@_$(VERSION_DEV).img
	@echo "finished $@"

clean:
	$(MAKE) -C $(BUILDROOT) O=$(O) BR2_EXTERNAL=$(BUILDROOT_EXTERNAL) clean

help:
	@echo "Supported targets: $(TARGETS)"
	@echo "Run 'make <target>' to build a target image."
	@echo "Run 'make all' to build all target images."
	@echo "Run 'make clean' to clean the build output."
	@echo "Run 'make <target>-config' to configure buildroot for a target."

.PHONY: list
list:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'