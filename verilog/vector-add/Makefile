
### Help Section ###
.PHONY: help
help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make all TARGET=<hw_emu/hw> PLATFORM=<FPGA platform> EDGE_COMMON_SW=<rootfs and kernel image path>"
	$(ECHO) "      Command to generate the design for specified Target and Shell."
	$(ECHO) ""
	$(ECHO) "  make clean "
	$(ECHO) "      Command to remove the generated non-hardware files."
	$(ECHO) ""
	$(ECHO) "  make cleanall"
	$(ECHO) "      Command to remove all the generated files."
	$(ECHO) ""
	$(ECHO) "  make test PLATFORM=<FPGA platform>"
	$(ECHO) "      Command to run the application. This is same as 'run' target but does not have any makefile dependency."
	$(ECHO) ""
	$(ECHO) "  make sd_card TARGET=<hw_emu/hw> PLATFORM=<FPGA platform> EDGE_COMMON_SW=<rootfs and kernel image path>"
	$(ECHO) "      Command to prepare sd_card files."
	$(ECHO) ""
	$(ECHO) "  make run TARGET=<hw_emu/hw> PLATFORM=<FPGA platform> EDGE_COMMON_SW=<rootfs and kernel image path>"
	$(ECHO) "      Command to run application in emulation."
	$(ECHO) ""
	$(ECHO) "  make build TARGET=<hw_emu/hw> PLATFORM=<FPGA platform> EDGE_COMMON_SW=<rootfs and kernel image path>"
	$(ECHO) "      Command to build xclbin application."
	$(ECHO) ""
	$(ECHO) "  make host EDGE_COMMON_SW=<rootfs and kernel image path>"
	$(ECHO) "      Command to build host application."
	$(ECHO) "  EDGE_COMMON_SW is required for SoC shells"
	$(ECHO) ""

### Setting up Project Variables ###
ifeq ($(PLATFORM), )
$(error PLATFORM has to be defined)
endif

TARGET := hw
ifneq ($(TARGET),$(findstring $(TARGET), hw hw_emu))
$(error TARGET has to be either hw or hw_emu)
endif

# Project paths
MK_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJ_DIR := $(shell dirname $(MK_PATH))
SHARED_DIR := $(shell dirname $(PROJ_DIR))/shared
SRC_DIR := $(PROJ_DIR)/src
KERNEL_DIR := $(SRC_DIR)/kernel
HOST_DIR := $(SRC_DIR)/host

XSA := $(strip $(patsubst %.xpfm, % , $(shell basename $(PLATFORM))))
BUILD_DIR := $(PROJ_DIR)/build.$(TARGET).$(XSA)
TEMP_DIR := $(BUILD_DIR)/temp
PACKAGE_DIR := $(BUILD_DIR)/package

HOST_SRCS := $(HOST_DIR)/host.cpp $(SHARED_DIR)/xcl2/xcl2.cpp
HOST := $(BUILD_DIR)/host
XO := $(TEMP_DIR)/kernel.xo
LINK_XCLBIN := $(BUILD_DIR)/kernel.link.xclbin
XCLBIN := $(BUILD_DIR)/kernel.xclbin

# Vivado
VIVADO := $(XILINX_VIVADO)/bin/vivado
VIVADO_INCLUDE:= $(XILINX_VIVADO)/include

# OpenCL
xrt_path = $(XILINX_XRT)
OPENCL_INCLUDE:= $(xrt_path)/include

opencl_CXXFLAGS=-I$(OPENCL_INCLUDE) -I$(VIVADO_INCLUDE)
OPENCL_LIB:= $(xrt_path)/lib
opencl_LDFLAGS=-L$(OPENCL_LIB) -lOpenCL -pthread

# Compiler settings
VPP := v++
VPP_FLAGS += -t $(TARGET) --platform $(PLATFORM) --save-temps
CXX := g++
CXXFLAGS += $(opencl_CXXFLAGS) -Wall -O0 -g -std=c++1y -fmessage-length=0
CXXFLAGS += -I$(SHARED_DIR)/xcl2
LDFLAGS += $(opencl_LDFLAGS) -lrt -lstdc++

### ENVIRONMENT CHECKS ###
# TODO remember to use it
# TODO do we need all those checks?
check-xrt:
ifndef XILINX_XRT
	$(error XILINX_XRT variable is not set)
endif


### BUILD ###
build-dirs: 
	mkdir $(BUILD_DIR)
	mkdir $(TEMP_DIR)

$(XO): build-dirs $(KERNEL_DIR)/package_kernel.tcl $(KERNEL_DIR)/gen_xo.tcl $(KERNEL_DIR)/hdl/*.sv $(KERNEL_DIR)/hdl/*.v 
	$(VIVADO) -mode batch -source $(KERNEL_DIR)/gen_xo.tcl -tclargs $(XO) $(TARGET) $(PLATFORM) $(XSA) $(PACKAGE_DIR) $(TEMP_DIR)

.PHONY: xclbin
xclbin: $(XCLBIN)
$(XCLBIN): $(XO)
	$(VPP) $(VPP_FLAGS) -l $(VPP_LDFLAGS) --temp_dir $(TEMP_DIR) -o'$(LINK_XCLBIN)' $(XO)
	$(VPP) -p $(LINK_XCLBIN) -t $(TARGET) --platform $(PLATFORM) --package.out_dir $(PACKAGE_DIR) -o $(XCLBIN)


# TODO do we need | check-xrt
# TODO remove phony, it's only for testing purposes
.PHONY: compile-host
compile-host: $(HOST)
$(HOST): build-dirs $(HOST_SRCS) 
	$(CXX) -o $@ $(HOST_SRCS) $(CXXFLAGS) $(LDFLAGS)


### RUN ###
.PHONY: run
run: 
ifeq ($(TARGET),$(filter $(TARGET),sw_emu hw_emu))
	$(CP) $(EMCONFIG_DIR)/emconfig.json .
	XCL_EMULATION_MODE=$(TARGET) $(EXECUTABLE) $(CMD_ARGS)
else
	$(error Wrong TARGET for run, should be either sw_emu or hw_emu)
endif
 

### CLEAN ###
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) _x .Xil || true
	rm -f *.jou
	rm -f *.log
