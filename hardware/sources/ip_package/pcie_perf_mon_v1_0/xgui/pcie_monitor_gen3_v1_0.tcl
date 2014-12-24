# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Page0 [ipgui::add_page $IPINST -name "Page 0" -layout vertical]
	set Component_Name [ipgui::add_param $IPINST -parent $Page0 -name Component_Name]
	set TDATA_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name TDATA_WIDTH]
	set TKEEP_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name TKEEP_WIDTH]
}

proc update_PARAM_VALUE.TDATA_WIDTH { PARAM_VALUE.TDATA_WIDTH } {
	# Procedure called to update TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TDATA_WIDTH { PARAM_VALUE.TDATA_WIDTH } {
	# Procedure called to validate TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.TKEEP_WIDTH { PARAM_VALUE.TKEEP_WIDTH } {
	# Procedure called to update TKEEP_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TKEEP_WIDTH { PARAM_VALUE.TKEEP_WIDTH } {
	# Procedure called to validate TKEEP_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.TDATA_WIDTH { MODELPARAM_VALUE.TDATA_WIDTH PARAM_VALUE.TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TDATA_WIDTH}] ${MODELPARAM_VALUE.TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.TKEEP_WIDTH { MODELPARAM_VALUE.TKEEP_WIDTH PARAM_VALUE.TKEEP_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TKEEP_WIDTH}] ${MODELPARAM_VALUE.TKEEP_WIDTH}
}

