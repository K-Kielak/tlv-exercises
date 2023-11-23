
### Help Section ###
.PHONY: help
help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make all TARGET=<sw_emu/hw_emu/hw> PLATFORM=<FPGA platform> EDGE_COMMON_SW=<rootfs and kernel image path>"
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
	$(ECHO) "  make sd_card TARGET=<sw_emu/hw_emu/hw> PLATFORM=<FPGA platform> EDGE_COMMON_SW=<rootfs and kernel image path>"
	$(ECHO) "      Command to prepare sd_card files."
	$(ECHO) ""
	$(ECHO) "  make run TARGET=<sw_emu/hw_emu/hw> PLATFORM=<FPGA platform> EDGE_COMMON_SW=<rootfs and kernel image path>"
	$(ECHO) "      Command to run application in emulation."
	$(ECHO) ""
	$(ECHO) "  make build TARGET=<sw_emu/hw_emu/hw> PLATFORM=<FPGA platform> EDGE_COMMON_SW=<rootfs and kernel image path>"
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

# Project paths
MK_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJ_DIR := $(shell dirname $(MK_PATH))
SRC_DIR := $(PROJ_DIR)/src
SHARED_DIR := $(shell dirname $(PROJ_DIR))/shared
XSA := $(call device2xsa, $(PLATFORM))
BUILD_DIR := $(PROJ_DIR)/build.$(TARGET).$(XSA)

HOST_SRCS := $(SRC_DIR)/host.cpp $(SHARED_DIR)/xcl2/xcl2.cpp
COMPILED_HOST := $(BUILD_DIR)/host

# Vivado
VIVADO_INCLUDE:= $(XILINX_VIVADO)/include

# OpenCL
xrt_path = $(XILINX_XRT)
OPENCL_INCLUDE:= $(xrt_path)/include

opencl_CXXFLAGS=-I$(OPENCL_INCLUDE) -I$(VIVADO_INCLUDE)
OPENCL_LIB:= $(xrt_path)/lib
opencl_LDFLAGS=-L$(OPENCL_LIB) -lOpenCL -pthread

# Compiler settings
VPP := v++
VPP_PFLAGS := 
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
# TODO do we need | check-xrt
$(BUILD_DIR): 
	mkdir $(BUILD_DIR)


.PHONY: compile-host
compile-host: $(COMPILED_HOST)
$(COMPILED_HOST): $(HOST_SRCS) $(BUILD_DIR)
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
