# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  #Adding Page
  set Page_0  [  ipgui::add_page $IPINST -name "Page 0" -display_name {Page 0}]
  set_property tooltip {Page 0} ${Page_0}
  set Component_Name  [  ipgui::add_param $IPINST -name "Component_Name" -parent ${Page_0} -display_name {Component Name}]
  set_property tooltip {Component Name} ${Component_Name}
  set BIT64_ADDR_EN  [  ipgui::add_param $IPINST -name "BIT64_ADDR_EN" -parent ${Page_0} -display_name {Bit64 Addr En}]
  set_property tooltip {Bit64 Addr En} ${BIT64_ADDR_EN}
  set START_ADDRESS  [  ipgui::add_param $IPINST -name "START_ADDRESS" -parent ${Page_0} -display_name {Start Address}]
  set_property tooltip {Start Address} ${START_ADDRESS}


}

proc update_PARAM_VALUE.BIT64_ADDR_EN { PARAM_VALUE.BIT64_ADDR_EN } {
	# Procedure called to update BIT64_ADDR_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BIT64_ADDR_EN { PARAM_VALUE.BIT64_ADDR_EN } {
	# Procedure called to validate BIT64_ADDR_EN
	return true
}

proc update_PARAM_VALUE.START_ADDRESS { PARAM_VALUE.START_ADDRESS } {
	# Procedure called to update START_ADDRESS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.START_ADDRESS { PARAM_VALUE.START_ADDRESS } {
	# Procedure called to validate START_ADDRESS
	return true
}


proc update_MODELPARAM_VALUE.START_ADDRESS { MODELPARAM_VALUE.START_ADDRESS PARAM_VALUE.START_ADDRESS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.START_ADDRESS}] ${MODELPARAM_VALUE.START_ADDRESS}
}

proc update_MODELPARAM_VALUE.BIT64_ADDR_EN { MODELPARAM_VALUE.BIT64_ADDR_EN PARAM_VALUE.BIT64_ADDR_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BIT64_ADDR_EN}] ${MODELPARAM_VALUE.BIT64_ADDR_EN}
}

proc update_MODELPARAM_VALUE.M_ID_WIDTH { MODELPARAM_VALUE.M_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "M_ID_WIDTH". Setting updated value from the model parameter.
set_property value 4 ${MODELPARAM_VALUE.M_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.M_ADDR_WIDTH { MODELPARAM_VALUE.M_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "M_ADDR_WIDTH". Setting updated value from the model parameter.
set_property value 32 ${MODELPARAM_VALUE.M_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.M_LEN_WIDTH { MODELPARAM_VALUE.M_LEN_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "M_LEN_WIDTH". Setting updated value from the model parameter.
set_property value 4 ${MODELPARAM_VALUE.M_LEN_WIDTH}
}

proc update_MODELPARAM_VALUE.M_DATA_WIDTH { MODELPARAM_VALUE.M_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "M_DATA_WIDTH". Setting updated value from the model parameter.
set_property value 128 ${MODELPARAM_VALUE.M_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.AXIS_TDATA_WIDTH { MODELPARAM_VALUE.AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "AXIS_TDATA_WIDTH". Setting updated value from the model parameter.
set_property value 128 ${MODELPARAM_VALUE.AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.AXIS_TKEEP_WIDTH { MODELPARAM_VALUE.AXIS_TKEEP_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "AXIS_TKEEP_WIDTH". Setting updated value from the model parameter.
set_property value 16 ${MODELPARAM_VALUE.AXIS_TKEEP_WIDTH}
}

