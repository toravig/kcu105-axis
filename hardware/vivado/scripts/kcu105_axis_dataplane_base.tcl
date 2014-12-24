set version base
set project_name "kcu105_axis_dataplane_${version}"
set project_dir "runs_base"
set ip_package_dir "../../sources/ip_package"
set hdl_dir "../../sources/hdl"
set ui_dir "../../sources/ui"
set constrs_dir "../../sources/constraints"
set scripts_dir "../scripts"
set bd_name "kcu105_${version}"
set part "xcku040-ffva1156-2-e"

# set up project
create_project $project_name ../$project_dir/$project_name -part $part -force
set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]

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
add_files -fileset constrs_1 -norecurse $constrs_dir/${bd_name}.xdc
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# apply UI file
file copy -force $ui_dir/bd_877310d7.ui ../$project_dir/$project_name/$project_name.srcs/sources_1/bd/$bd_name/ui/bd_877310d7.ui

# re-open bd design with layout and comments
open_bd_design ../$project_dir/$project_name/$project_name.srcs/sources_1/bd/$bd_name/$bd_name.bd
regenerate_bd_layout
save_bd_design
reset_run synth_1
