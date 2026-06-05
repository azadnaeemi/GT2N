# GT2N platform shim for ORFS.
#
# ORFS unconditionally includes $(PLATFORM_DIR)/config.mk during variable setup.
# We keep this file minimal and put run/design-specific settings in DESIGN_CONFIG
# (for example: 03_spnr/tt/w31_svtlvt/150ps/config.mk).

export PLATFORM ?= gt2n
