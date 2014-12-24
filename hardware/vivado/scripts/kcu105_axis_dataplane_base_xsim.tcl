set version base
set project_name "kcu105_axis_dataplane_${version}"
set project_dir "runs_base_xsim"
set ip_package_dir "../../sources/ip_package"
set hdl_dir "../../sources/hdl"
set ui_dir "../../sources/ui"
set constrs_dir "../../sources/constraints"
set scripts_dir "../scripts"
set bd_name "kcu105_${version}"
set part "xcku040-ffva1156-2-e"

set SIM_TOOL "xsim"

# set up project
create_project $project_name ../$project_dir/$project_name -part $part -force

# set up IP repo
set_property ip_repo_paths $ip_package_dir [current_fileset]
update_ip_catalog -rebuild

# set up bd design
create_bd_design $bd_name
source $scripts_dir/${bd_name}_bd.tcl
regenerate_bd_layout
validate_bd_design
save_bd_design
close_bd_design $bd_name

# add hdl sources and xdc constraints to project
add_files -fileset sources_1 -norecurse $hdl_dir/${bd_name}_top.v
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

set_property top ${bd_name}_top [current_fileset]
update_compile_order -fileset sources_1

set_property include_dirs {../../sources/testbench ../../sources/testbench/dsport ../../sources/testbench/tests ../../sources/testbench/include} [get_filesets sim_1]

set_property verilog_define {{SIMULATION=1}} [get_filesets sim_1]
set_property runtime {} [get_filesets sim_1]

read_verilog "../../sources/testbench/board.v"
read_verilog "../../sources/testbench/dsport/xilinx_pcie_uscale_rp.v"
read_verilog "../../sources/testbench/dsport/pcie3_uscale_rp_top.v"
read_verilog "../../sources/testbench/dsport/pci_exp_usrapp_com.v"
read_verilog "../../sources/testbench/dsport/pci_exp_usrapp_tx.v"
read_verilog "../../sources/testbench/dsport/pci_exp_usrapp_cfg.v"
read_verilog "../../sources/testbench/dsport/pci_exp_usrapp_rx.v"
read_verilog "../../sources/testbench/dsport/pci_exp_usrapp_pl.v"
read_verilog "../../sources/testbench/functional/pcie3_ultrascale_0_phy_sig_gen_clk.v"
read_verilog "../../sources/testbench/functional/pcie3_ultrascale_0_phy_sig_gen.v"

set_property USED_IN simulation [get_files ../../sources/testbench/board.v]
set_property USED_IN simulation [get_files ../../sources/testbench/dsport/xilinx_pcie_uscale_rp.v]
set_property USED_IN simulation [get_files ../../sources/testbench/dsport/pcie3_uscale_rp_top.v]
set_property USED_IN simulation [get_files ../../sources/testbench/dsport/pci_exp_usrapp_com.v]
set_property USED_IN simulation [get_files ../../sources/testbench/dsport/pci_exp_usrapp_tx.v]
set_property USED_IN simulation [get_files ../../sources/testbench/dsport/pci_exp_usrapp_cfg.v]
set_property USED_IN simulation [get_files ../../sources/testbench/dsport/pci_exp_usrapp_rx.v]
set_property USED_IN simulation [get_files ../../sources/testbench/dsport/pci_exp_usrapp_pl.v]
set_property USED_IN simulation [get_files ../../sources/testbench/functional/pcie3_ultrascale_0_phy_sig_gen_clk.v]
set_property USED_IN simulation [get_files ../../sources/testbench/functional/pcie3_ultrascale_0_phy_sig_gen.v]

if {$SIM_TOOL == "mti"} {
  set CurrWrkDir [pwd]
  if [info exists env(MODELSIM)] {
    puts "MODELSIM env pointing to ini exists..."
  } elseif {[file exists $CurrWrkDir/modelsim.ini] == 1} {
    set env(MODELSIM) $CurrWrkDir/modelsim.ini
    puts "Setting \$MODELSIM to modelsim.ini"
  } else {
    puts "\n\nERROR! modelsim.ini not found!"
    exit
  }

  set_property target_simulator ModelSim [current_project]
  set_property -name modelsim.vlog_more_options -value +acc -objects [get_filesets sim_1]
  set_property compxlib.compiled_library_dir {} [current_project]
}

update_compile_order -fileset sources_1

# apply UI file
file copy -force $ui_dir/bd_877310d7.ui ../$project_dir/$project_name/$project_name.srcs/sources_1/bd/$bd_name/ui/bd_877310d7.ui

# re-open bd design with layout and comments
open_bd_design ../$project_dir/$project_name/$project_name.srcs/sources_1/bd/$bd_name/$bd_name.bd
