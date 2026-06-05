set layer_adjustment 0.2
if { [info exists ::env(ROUTING_LAYER_ADJUSTMENT)] && $::env(ROUTING_LAYER_ADJUSTMENT) ne "" } {
  set layer_adjustment $::env(ROUTING_LAYER_ADJUSTMENT)
}
set_global_routing_layer_adjustment $::env(MIN_ROUTING_LAYER)-$::env(MAX_ROUTING_LAYER) $layer_adjustment

set_routing_layers -clock $::env(MIN_CLK_ROUTING_LAYER)-$::env(MAX_ROUTING_LAYER)
set_routing_layers -signal $::env(MIN_ROUTING_LAYER)-$::env(MAX_ROUTING_LAYER)
