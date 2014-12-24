# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  #Adding Page
  set Page_0  [  ipgui::add_page $IPINST -name "Page 0" -display_name {Page 0}]
  set_property tooltip {Page 0} ${Page_0}
  set Component_Name  [  ipgui::add_param $IPINST -name "Component_Name" -parent ${Page_0} -display_name {Component Name}]
  set_property tooltip {Component Name} ${Component_Name}


}


