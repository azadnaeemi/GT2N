# Isolated GT2N compatibility platform variant.
# Heavy foundry-like collateral is symlinked from ../gt2n; editable LEF/Tcl/DRC/LVS
# collateral is copied here so experiments do not mutate the baseline gt2n platform.
export PLATFORM ?= gt2n_compat_bspdn_proxy
