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

# set up IP repo
set_property ip_repo_paths $ip_package_dir [current_fileset]
update_ip_catalog -rebuild

# set up bd design
create_bd_design $bd_name
source $scripts_dir/${bd_name}_bd.tcl
regenerate_bd_layout
validate_bd_design
save_bd_design

# add hdl sources and xdc constraints to project
add_files -fileset sources_1 -norecurse $hdl_dir/${bd_name}_top.v
add_files -fileset constrs_1 -norecurse $constrs_dir/${bd_name}.xdc
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]

reset_run synth_1
launch_runs synth_1
wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
puts "Implementation process is complete !"
close_project
