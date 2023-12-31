#
# Copyright (C) 2019-2021 Xilinx, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may
# not use this file except in compliance with the License. A copy of the
# License is located at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#

if { $::argc != 6 } {
    puts "ERROR: Program \"$::argv0\" requires 6 arguments!\n"
    puts "Usage: $::argv0 <xoname> <target> <xpfm_path> <device> <package_dir> <temp_dir>\n"
    exit
}

set xoname  [lindex $::argv 0]
set target    [lindex $::argv 1]
set xpfm_path [lindex $::argv 2]
set device    [lindex $::argv 3]
set package_dir [lindex $::argv 4]
set temp_dir [lindex $::argv 5]

set suffix "kernel_${target}_${device}"

source -notrace ./src/kernel/package_kernel.tcl

if {[file exists "${xoname}"]} {
    file delete -force "${xoname}"
}

package_xo -xo_path ${xoname} -kernel_name kernel_rtl -ip_directory ${package_dir}
