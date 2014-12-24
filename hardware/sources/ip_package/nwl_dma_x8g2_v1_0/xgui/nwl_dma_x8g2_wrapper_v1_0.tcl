# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  #Adding Page
  set Page_0  [  ipgui::add_page $IPINST -name "Page 0" -display_name {Page 0}]
  set_property tooltip {Page 0} ${Page_0}
  set Component_Name  [  ipgui::add_param $IPINST -name "Component_Name" -parent ${Page_0} -display_name {Component Name}]
  set_property tooltip {Component Name} ${Component_Name}
  set ENABLE_AXI_SLAVE  [  ipgui::add_param $IPINST -name "ENABLE_AXI_SLAVE" -parent ${Page_0} -display_name {Enable Axi Slave}]
  set_property tooltip {Enable Axi Slave} ${ENABLE_AXI_SLAVE}
  set DMA_CHANNEL_WIDTH  [  ipgui::add_param $IPINST -name "DMA_CHANNEL_WIDTH" -parent ${Page_0} -display_name {Dma Channel Width}]
  set_property tooltip {Dma Channel Width} ${DMA_CHANNEL_WIDTH}
  set SGLF_CH_ADDR_WIDTH  [  ipgui::add_param $IPINST -name "SGLF_CH_ADDR_WIDTH" -parent ${Page_0} -display_name {Sglf Ch Addr Width}]
  set_property tooltip {Sglf Ch Addr Width} ${SGLF_CH_ADDR_WIDTH}
  set NUM_DMA_CHANNELS  [  ipgui::add_param $IPINST -name "NUM_DMA_CHANNELS" -parent ${Page_0} -display_name {Num Dma Channels}]
  set_property tooltip {Num Dma Channels} ${NUM_DMA_CHANNELS}
  set M_ID_WIDTH  [  ipgui::add_param $IPINST -name "M_ID_WIDTH" -parent ${Page_0} -display_name {M Id Width}]
  set_property tooltip {M Id Width} ${M_ID_WIDTH}
  set M_DATA_WIDTH  [  ipgui::add_param $IPINST -name "M_DATA_WIDTH" -parent ${Page_0} -display_name {M Data Width}]
  set_property tooltip {M Data Width} ${M_DATA_WIDTH}
  set M_LEN_WIDTH  [  ipgui::add_param $IPINST -name "M_LEN_WIDTH" -parent ${Page_0} -display_name {M Len Width}]
  set_property tooltip {M Len Width} ${M_LEN_WIDTH}
  set S_DATA_WIDTH  [  ipgui::add_param $IPINST -name "S_DATA_WIDTH" -parent ${Page_0} -display_name {S Data Width}]
  set_property tooltip {S Data Width} ${S_DATA_WIDTH}
  set S_LEN_WIDTH  [  ipgui::add_param $IPINST -name "S_LEN_WIDTH" -parent ${Page_0} -display_name {S Len Width}]
  set_property tooltip {S Len Width} ${S_LEN_WIDTH}
  set S_ID_WIDTH  [  ipgui::add_param $IPINST -name "S_ID_WIDTH" -parent ${Page_0} -display_name {S Id Width}]
  set_property tooltip {S Id Width} ${S_ID_WIDTH}
  set SGL_WIDTH  [  ipgui::add_param $IPINST -name "SGL_WIDTH" -parent ${Page_0} -display_name {Sgl Width}]
  set_property tooltip {Sgl Width} ${SGL_WIDTH}
  set NUM_LANES  [  ipgui::add_param $IPINST -name "NUM_LANES" -parent ${Page_0} -display_name {Num Lanes}]
  set_property tooltip {Num Lanes} ${NUM_LANES}
  set M_ADDR_WIDTH  [  ipgui::add_param $IPINST -name "M_ADDR_WIDTH" -parent ${Page_0} -display_name {M Addr Width}]
  set_property tooltip {M Addr Width} ${M_ADDR_WIDTH}
  set P_DATA_WIDTH  [  ipgui::add_param $IPINST -name "P_DATA_WIDTH" -parent ${Page_0} -display_name {P Data Width}]
  set_property tooltip {P Data Width} ${P_DATA_WIDTH}
  set S_ADDR_WIDTH  [  ipgui::add_param $IPINST -name "S_ADDR_WIDTH" -parent ${Page_0} -display_name {S Addr Width}]
  set_property tooltip {S Addr Width} ${S_ADDR_WIDTH}


}

proc update_PARAM_VALUE.ENABLE_AXI_SLAVE { PARAM_VALUE.ENABLE_AXI_SLAVE } {
	# Procedure called to update ENABLE_AXI_SLAVE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ENABLE_AXI_SLAVE { PARAM_VALUE.ENABLE_AXI_SLAVE } {
	# Procedure called to validate ENABLE_AXI_SLAVE
	return true
}

proc update_PARAM_VALUE.DMA_CHANNEL_WIDTH { PARAM_VALUE.DMA_CHANNEL_WIDTH } {
	# Procedure called to update DMA_CHANNEL_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DMA_CHANNEL_WIDTH { PARAM_VALUE.DMA_CHANNEL_WIDTH } {
	# Procedure called to validate DMA_CHANNEL_WIDTH
	return true
}

proc update_PARAM_VALUE.SGLF_CH_ADDR_WIDTH { PARAM_VALUE.SGLF_CH_ADDR_WIDTH } {
	# Procedure called to update SGLF_CH_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SGLF_CH_ADDR_WIDTH { PARAM_VALUE.SGLF_CH_ADDR_WIDTH } {
	# Procedure called to validate SGLF_CH_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.NUM_DMA_CHANNELS { PARAM_VALUE.NUM_DMA_CHANNELS } {
	# Procedure called to update NUM_DMA_CHANNELS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_DMA_CHANNELS { PARAM_VALUE.NUM_DMA_CHANNELS } {
	# Procedure called to validate NUM_DMA_CHANNELS
	return true
}

proc update_PARAM_VALUE.M_ID_WIDTH { PARAM_VALUE.M_ID_WIDTH } {
	# Procedure called to update M_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_ID_WIDTH { PARAM_VALUE.M_ID_WIDTH } {
	# Procedure called to validate M_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.M_DATA_WIDTH { PARAM_VALUE.M_DATA_WIDTH } {
	# Procedure called to update M_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_DATA_WIDTH { PARAM_VALUE.M_DATA_WIDTH } {
	# Procedure called to validate M_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.M_LEN_WIDTH { PARAM_VALUE.M_LEN_WIDTH } {
	# Procedure called to update M_LEN_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_LEN_WIDTH { PARAM_VALUE.M_LEN_WIDTH } {
	# Procedure called to validate M_LEN_WIDTH
	return true
}

proc update_PARAM_VALUE.S_DATA_WIDTH { PARAM_VALUE.S_DATA_WIDTH } {
	# Procedure called to update S_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_DATA_WIDTH { PARAM_VALUE.S_DATA_WIDTH } {
	# Procedure called to validate S_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.S_LEN_WIDTH { PARAM_VALUE.S_LEN_WIDTH } {
	# Procedure called to update S_LEN_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_LEN_WIDTH { PARAM_VALUE.S_LEN_WIDTH } {
	# Procedure called to validate S_LEN_WIDTH
	return true
}

proc update_PARAM_VALUE.S_ID_WIDTH { PARAM_VALUE.S_ID_WIDTH } {
	# Procedure called to update S_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_ID_WIDTH { PARAM_VALUE.S_ID_WIDTH } {
	# Procedure called to validate S_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.SGL_WIDTH { PARAM_VALUE.SGL_WIDTH } {
	# Procedure called to update SGL_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SGL_WIDTH { PARAM_VALUE.SGL_WIDTH } {
	# Procedure called to validate SGL_WIDTH
	return true
}

proc update_PARAM_VALUE.NUM_LANES { PARAM_VALUE.NUM_LANES } {
	# Procedure called to update NUM_LANES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_LANES { PARAM_VALUE.NUM_LANES } {
	# Procedure called to validate NUM_LANES
	return true
}

proc update_PARAM_VALUE.M_ADDR_WIDTH { PARAM_VALUE.M_ADDR_WIDTH } {
	# Procedure called to update M_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_ADDR_WIDTH { PARAM_VALUE.M_ADDR_WIDTH } {
	# Procedure called to validate M_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.P_DATA_WIDTH { PARAM_VALUE.P_DATA_WIDTH } {
	# Procedure called to update P_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.P_DATA_WIDTH { PARAM_VALUE.P_DATA_WIDTH } {
	# Procedure called to validate P_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.S_ADDR_WIDTH { PARAM_VALUE.S_ADDR_WIDTH } {
	# Procedure called to update S_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_ADDR_WIDTH { PARAM_VALUE.S_ADDR_WIDTH } {
	# Procedure called to validate S_ADDR_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.NUM_LANES { MODELPARAM_VALUE.NUM_LANES PARAM_VALUE.NUM_LANES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_LANES}] ${MODELPARAM_VALUE.NUM_LANES}
}

proc update_MODELPARAM_VALUE.DMA_CHANNEL_WIDTH { MODELPARAM_VALUE.DMA_CHANNEL_WIDTH PARAM_VALUE.DMA_CHANNEL_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DMA_CHANNEL_WIDTH}] ${MODELPARAM_VALUE.DMA_CHANNEL_WIDTH}
}

proc update_MODELPARAM_VALUE.NUM_DMA_CHANNELS { MODELPARAM_VALUE.NUM_DMA_CHANNELS PARAM_VALUE.NUM_DMA_CHANNELS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_DMA_CHANNELS}] ${MODELPARAM_VALUE.NUM_DMA_CHANNELS}
}

proc update_MODELPARAM_VALUE.SGLF_CH_ADDR_WIDTH { MODELPARAM_VALUE.SGLF_CH_ADDR_WIDTH PARAM_VALUE.SGLF_CH_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SGLF_CH_ADDR_WIDTH}] ${MODELPARAM_VALUE.SGLF_CH_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.SGL_WIDTH { MODELPARAM_VALUE.SGL_WIDTH PARAM_VALUE.SGL_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SGL_WIDTH}] ${MODELPARAM_VALUE.SGL_WIDTH}
}

proc update_MODELPARAM_VALUE.P_DATA_WIDTH { MODELPARAM_VALUE.P_DATA_WIDTH PARAM_VALUE.P_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.P_DATA_WIDTH}] ${MODELPARAM_VALUE.P_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.S_ID_WIDTH { MODELPARAM_VALUE.S_ID_WIDTH PARAM_VALUE.S_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_ID_WIDTH}] ${MODELPARAM_VALUE.S_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.S_ADDR_WIDTH { MODELPARAM_VALUE.S_ADDR_WIDTH PARAM_VALUE.S_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_ADDR_WIDTH}] ${MODELPARAM_VALUE.S_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.S_LEN_WIDTH { MODELPARAM_VALUE.S_LEN_WIDTH PARAM_VALUE.S_LEN_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_LEN_WIDTH}] ${MODELPARAM_VALUE.S_LEN_WIDTH}
}

proc update_MODELPARAM_VALUE.S_DATA_WIDTH { MODELPARAM_VALUE.S_DATA_WIDTH PARAM_VALUE.S_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_DATA_WIDTH}] ${MODELPARAM_VALUE.S_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.M_ID_WIDTH { MODELPARAM_VALUE.M_ID_WIDTH PARAM_VALUE.M_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_ID_WIDTH}] ${MODELPARAM_VALUE.M_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.M_ADDR_WIDTH { MODELPARAM_VALUE.M_ADDR_WIDTH PARAM_VALUE.M_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_ADDR_WIDTH}] ${MODELPARAM_VALUE.M_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.M_LEN_WIDTH { MODELPARAM_VALUE.M_LEN_WIDTH PARAM_VALUE.M_LEN_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_LEN_WIDTH}] ${MODELPARAM_VALUE.M_LEN_WIDTH}
}

proc update_MODELPARAM_VALUE.M_DATA_WIDTH { MODELPARAM_VALUE.M_DATA_WIDTH PARAM_VALUE.M_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_DATA_WIDTH}] ${MODELPARAM_VALUE.M_DATA_WIDTH}
}

