*************************************************************************
   ____  ____ 
  /   /\/   / 
 /___/  \  /   
 \   \   \/    © Copyright 2014 Xilinx, Inc. All rights reserved.
  \   \        This file contains confidential and proprietary 
  /   /        information of Xilinx, Inc. and is protected under U.S. 
 /___/   /\    and international copyright and other intellectual 
 \   \  /  \   property laws. 
  \___\/\___\ 
 
*************************************************************************

Vendor: Xilinx 
Current readme.txt Version: 1.0.0
Date Last Modified:  21NOV2014 
Date Created: 21NOV2014

Associated Filename: rdf0307-kcu105-trd03-2014-3.zip
Associated Document: UG920

Supported Device(s): Kintex UltraScale (XCKU040-2FFVA1156E)
   
*************************************************************************

Disclaimer: 

      This disclaimer is not a license and does not grant any rights to 
      the materials distributed herewith. Except as otherwise provided in 
      a valid license issued to you by Xilinx, and to the maximum extent 
      permitted by applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE 
      "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL 
      WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
      INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, 
      NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and 
      (2) Xilinx shall not be liable (whether in contract or tort, 
      including negligence, or under any other theory of liability) for 
      any loss or damage of any kind or nature related to, arising under 
      or in connection with these materials, including for any direct, or 
      any indirect, special, incidental, or consequential loss or damage 
      (including loss of data, profits, goodwill, or any type of loss or 
      damage suffered as a result of any action brought by a third party) 
      even if such damage or loss was reasonably foreseeable or Xilinx 
      had been advised of the possibility of the same.

Critical Applications:

      Xilinx products are not designed or intended to be fail-safe, or 
      for use in any application requiring fail-safe performance, such as 
      life-support or safety devices or systems, Class III medical 
      devices, nuclear facilities, applications related to the deployment 
      of airbags, or any other applications that could lead to death, 
      personal injury, or severe property or environmental damage 
      (individually and collectively, "Critical Applications"). Customer 
      assumes the sole risk and liability of any use of Xilinx products 
      in Critical Applications, subject only to applicable laws and 
      regulations governing limitations on product liability.

THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS 
FILE AT ALL TIMES.

*************************************************************************

This readme file contains these sections:

1. REVISION HISTORY
2. OVERVIEW
3. SOFTWARE TOOLS AND SYSTEM REQUIREMENTS
4. DESIGN FILE HIERARCHY
5. INSTALLATION AND OPERATING INSTRUCTIONS
6. OTHER INFORMATION (OPTIONAL)
7. SUPPORT


1. REVISION HISTORY 
=========================================================================
            Readme  
Date        Version      Revision Description
=========================================================================
21NOV2014   1.0          Initial Xilinx release.


2. OVERVIEW

This readme describes how to use the files that come with rdf0307-kcu105-trd03-2014-3.zip 

TRD package consists of the following :
-	Two hardware designs : Base design and an user modification design(2x10G Ethernet design)
-	Linux 64-bit Fedora 20 device drivers with Java based Graphical User Interface for 
    controlling and monitoring the TRD.
-	ready to test bit files for both the designs

The PCI Express Streaming Data Plane TRD targets the Kintex® UltraScale™
XCKU040-2FFVA1156E FPGA running on the KCU105 evaluation board. It demonstrates an
AXI streaming data plane application using a PCI Express Endpoint block in a x8 Gen2
configuration through use of high performance Expresso DMA from Northwest Logic. 
Base design showcase raw data exchange between HOST and FPGA through PCIe. 
User Modification design is an superset of base design. It demonstrates
2x10G Ethernet application.


3. SOFTWARE TOOLS AND SYSTEM REQUIREMENTS

 a. Hardware
     i. KCU105 board with the Kintex® UltraScale XCKU040-2FFVA1156E FPGA   
    ii. USB cable, standard-A plug to micro-B plug (Digilent cable)
   iii. ATX power supply adapter
    iv. A Host computer with PCI Express slot, DVD drive, monitor, keyboard and mouse
     v. A control computer is required for running the Vivado Design Suite and configuring the
        FPGA. It can be a laptop or desktop computer with Microsoft Windows 7 operating system

 b. Software
    i.  Xilinx Vivado 2014.3 or higher
    ii. QuestaSim/Modelsim 10.2a
    iii.Fedora 20 Live DVD


Note: Before running any command line scripts, refer to the 
      Xilinx Design Tools: Installation and Licensing document to learn how 
      to set the appropriate environment variables for your operating system.
      All scripts mentioned in this readme file assume the environment for
      use of Vivado tools has been set.

4. DESIGN FILE HIERARCHY

The directory structure underneath the top-level folder is described 
below:

    kcu105_axis_dataplane : Main Reference Design folder
    |
    +-- hardware : Hardware Design specific files and scripts for simulation & implementation
    |   +-- sources
    |   |   +-- constraints : Constraint files
    |   |   +-- hdl : Custom RTL files required for the design
    |   |   +-- ip_package : Contains the locally packaged IPs required for the IPI flow
    |   |   +-- testbench : Testbench files for Out Of Box Simulation
    |   +-- vivado
    |       +-- scripts : Contains scripts for Implementation and Simulation
    +-- ready_to_test : Prebuilt bitfiles
    |   +-- ES : This bitstream is built out of Vivado 2014.1 tool.
    |   +-- PS : This bitstream is built out of 2014.3 toolchain. 
    +-- software : Source code for linux device driver, user application and Java based GUI
    |   +-- quickstart.sh : Script to invoke the GUI ( Do "chmod +x quickstart.sh" on the terminal, to make it an executable)   
    |   +-- linux_driver_app
    |       +-- driver
    |       +-- gui
    +--readme.txt : the file you are currently reading  


5. INSTALLATION AND OPERATING INSTRUCTIONS 
	- Please refer UG920 for details on software installation,Simulation, Bit file generation and testing the TRD design 
	- Considerations for simulating the design
		- Simulation options in the VIVADO project needs to be updated along with the compiled library path 
		- modelsim.ini file needs to be copied to ../hardware/vivado/scripts directory 


6. OTHER INFORMATION  

	1) Warnings 
		- NONE
	
	2) Design Notes
		The GUI in TRD uses jfreechart as a library and no modifications have been done to the downloaded source/JAR. jfreechart is downloaded
	   	from http://www.jfree.org/jfreechart/download.html and is licensed under the terms of LGPL. A copy of the source along with license is
	   	included in this distribution.
	
	3) Fixes 
		- NONE
	
	4) Known Issues 
	    - ES bit file generated with 2014.1 tool chain is not timing clean
		- Netperf on F20
		- Peer to Peer
	
7. SUPPORT        
	To obtain technical support for this reference design, go to 
	www.xilinx.com/support to locate answers to known issues in the Xilinx
	Answers Database.  
