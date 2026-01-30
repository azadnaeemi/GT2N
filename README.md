# GT2N PDK

This is the initial release for GT2N PDK with 71 standard cells. It is based on 2nm GAAFET with BSPDN.

If you use this PDK for publishing your work, we would appreciate citation of the following paper:

D. Jang, P. Kumar, M. N. H. Shazon, S. J. Ram, A. Svizhenko, V. Moroz, A. Ceyhan, N. A. Radhakrishn, and A. Naeemi, "GT2N: An Open-Source 2nm Nanosheet PDK Enabling Multi-Width/VT Benchmarking," in IEEE International Symposium on Circuits and Systems (ISCAS).

Quick setup guide for Custom Compiler:

Create a folder (e.g. gt2_techlib) and copy GT2/cdslib/nmos_rvt and GT2/cdslib/pmos_rvt inside that folder.
Inside the folder from where custom_compiler is run, add following to the lib.defs file:
gt2_official <path_to_gt2_techlib folder>/gt2_techlib

You can specify any name for the library instead of using gt2_offical. The current standard cell schematics are linked with the devices using this name. In case any other library name is used, the device references might need to be updated in the schematics.

To assign technology to the lib, the following .tf file can be imported using "Technology Manager" and applied to the gt2_official lib:
GT2/cdslib/gt2_techfile.tf

To import all the standard cells, either custom_compiler .oa format or .gds files can be used.
Create a folder for standard cell library, e.g. gt2_lib and add it to the lib.defs file:
gt2_lib <path_to_gt2_techlib folder>/gt2_lib

In the "Technology Manager", the associated technology needs to be changed to gt2_official (or the lib name used in the previous stage), alternatively, .tf file can also be imported and applied to gt2_lib. This is necessary, otherwise layers would not be identified. Any new library created needs to follow the same process. To assign colors to the layer, load "GT2/cds/gt2_layer_colors.tcl" using the "Display Resource Manager".

Copy everything inside GT2/std_cell folder to gt2_lib. This includes layout, schematic and abstract views for custom_compiler.

Standard cell layouts can also be imported using .gds file: GT2/gds/gt2_6t_std_cell_rvt.gds

LVS and DRC rulesets for icvalidator is present in "GT2/icv_runset".

The collaterals required for synthesis and PnR are:

LIB: GT2/lib/gt2_rvt_tt_0p7v25c.lib

LEF: GT2/lef/gt2_std_cell_rvt.lef

Techlef: GT2/techlef/gt2_tech.lef

ICT: GT2/ict/GT2.ict

QRCTECH: GT2/qrc/qrcTechFile.tch

ITF: GT2/nxtgrd/GT2.itf

NXTGRD: GT2/nxtgrd/GT2.nxtgrd

The GAAFET model cards are:

GT2/models/hspice/gt2_lvt.mod

GT2/models/hspice/gt2_rvt.mod
