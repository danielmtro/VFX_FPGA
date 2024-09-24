# TCL File Generated by Component Editor 20.1
# Tue Sep 24 17:20:25 AEST 2024
# DO NOT MODIFY


# 
# filter_select "filter_select" v1.0
#  2024.09.24.17:20:25
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module filter_select
# 
set_module_property DESCRIPTION ""
set_module_property NAME filter_select
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME filter_select
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL filter_select
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file filter_select.sv SYSTEM_VERILOG PATH filter_select.sv TOP_LEVEL_FILE

add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL filter_select
set_fileset_property SIM_VERILOG ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property SIM_VERILOG ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file filter_select.sv SYSTEM_VERILOG PATH filter_select.sv


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


# 
# connection point avalon_streaming_sink
# 
add_interface avalon_streaming_sink avalon_streaming end
set_interface_property avalon_streaming_sink associatedClock clock
set_interface_property avalon_streaming_sink associatedReset reset
set_interface_property avalon_streaming_sink dataBitsPerSymbol 4
set_interface_property avalon_streaming_sink errorDescriptor ""
set_interface_property avalon_streaming_sink firstSymbolInHighOrderBits true
set_interface_property avalon_streaming_sink maxChannel 0
set_interface_property avalon_streaming_sink readyLatency 0
set_interface_property avalon_streaming_sink ENABLED true
set_interface_property avalon_streaming_sink EXPORT_OF ""
set_interface_property avalon_streaming_sink PORT_NAME_MAP ""
set_interface_property avalon_streaming_sink CMSIS_SVD_VARIABLES ""
set_interface_property avalon_streaming_sink SVD_ADDRESS_GROUP ""

add_interface_port avalon_streaming_sink data_in data Input 12
add_interface_port avalon_streaming_sink eop_in endofpacket Input 1
add_interface_port avalon_streaming_sink ready_out ready Output 1
add_interface_port avalon_streaming_sink sop_in startofpacket Input 1
add_interface_port avalon_streaming_sink valid_in valid Input 1


# 
# connection point avalon_streaming_source
# 
add_interface avalon_streaming_source avalon_streaming start
set_interface_property avalon_streaming_source associatedClock clock
set_interface_property avalon_streaming_source associatedReset reset
set_interface_property avalon_streaming_source dataBitsPerSymbol 4
set_interface_property avalon_streaming_source errorDescriptor ""
set_interface_property avalon_streaming_source firstSymbolInHighOrderBits true
set_interface_property avalon_streaming_source maxChannel 0
set_interface_property avalon_streaming_source readyLatency 0
set_interface_property avalon_streaming_source ENABLED true
set_interface_property avalon_streaming_source EXPORT_OF ""
set_interface_property avalon_streaming_source PORT_NAME_MAP ""
set_interface_property avalon_streaming_source CMSIS_SVD_VARIABLES ""
set_interface_property avalon_streaming_source SVD_ADDRESS_GROUP ""

add_interface_port avalon_streaming_source data_out data Output 12
add_interface_port avalon_streaming_source eop_out endofpacket Output 1
add_interface_port avalon_streaming_source ready_in ready Input 1
add_interface_port avalon_streaming_source sop_out startofpacket Output 1
add_interface_port avalon_streaming_source valid_out valid Output 1


# 
# connection point filter_num
# 
add_interface filter_num conduit end
set_interface_property filter_num associatedClock clock
set_interface_property filter_num associatedReset ""
set_interface_property filter_num ENABLED true
set_interface_property filter_num EXPORT_OF ""
set_interface_property filter_num PORT_NAME_MAP ""
set_interface_property filter_num CMSIS_SVD_VARIABLES ""
set_interface_property filter_num SVD_ADDRESS_GROUP ""

add_interface_port filter_num filter_num filter_num Input 2


# 
# connection point fre_flag
# 
add_interface fre_flag conduit end
set_interface_property fre_flag associatedClock clock
set_interface_property fre_flag associatedReset ""
set_interface_property fre_flag ENABLED true
set_interface_property fre_flag EXPORT_OF ""
set_interface_property fre_flag PORT_NAME_MAP ""
set_interface_property fre_flag CMSIS_SVD_VARIABLES ""
set_interface_property fre_flag SVD_ADDRESS_GROUP ""

add_interface_port fre_flag freq_flag freq_flag Input 2

