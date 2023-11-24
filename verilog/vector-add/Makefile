
### Help Section ###
.PHONY: help
help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make clean TARGET=<hw_emu/hw>"
	$(ECHO) "      Command to remove all generated files."
	$(ECHO) ""
	$(ECHO) "  make run TARGET=<hw_emu>"
	$(ECHO) "      Command to run application in emulation."
	$(ECHO) ""
	$(ECHO) "  make build TARGET=<hw_emu/hw>"
	$(ECHO) "      Command to build the project."
	$(ECHO) ""
	$(ECHO) " Default TARGET=hw_emu"
	$(ECHO) ""


### Checking environment ###
ifndef XILINX_VITIS
$(error XILINX_VITIS variable is not set)
endif

ifndef XILINX_XRT
$(error XILINX_XRT variable is not set)
endif

ifndef AWS_PLATFORM
$(error AWS_PLATFORM has to be defined)
endif


### Setting up Project Variables ###
TARGET := hw_emu
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

XSA := $(strip $(patsubst %.xpfm, % , $(shell basename $(AWS_PLATFORM))))
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
VPP_FLAGS += -t $(TARGET) --platform $(AWS_PLATFORM) --save-temps
CXX := g++
CXXFLAGS += $(opencl_CXXFLAGS) -Wall -O0 -g -std=c++1y -fmessage-length=0
CXXFLAGS += -I$(SHARED_DIR)/xcl2
LDFLAGS += $(opencl_LDFLAGS) -lrt -lstdc++


### Build ###
DIRS_READY := $(BUILD_DIR)/.dirs_created
$(DIRS_READY):
	mkdir $(BUILD_DIR) 
	mkdir $(TEMP_DIR) 
	touch $(DIRS_READY)

$(XO): $(DIRS_READY) $(KERNEL_DIR)/package_kernel.tcl $(KERNEL_DIR)/gen_xo.tcl $(KERNEL_DIR)/hdl/*.sv $(KERNEL_DIR)/hdl/*.v 
	$(VIVADO) -mode batch -source $(KERNEL_DIR)/gen_xo.tcl -tclargs $(XO) $(TARGET) $(AWS_PLATFORM) $(XSA) $(PACKAGE_DIR) $(TEMP_DIR)

$(XCLBIN): $(XO)
	$(VPP) $(VPP_FLAGS) -l $(VPP_LDFLAGS) --temp_dir $(TEMP_DIR) -o'$(LINK_XCLBIN)' $(XO)
	$(VPP) -p $(LINK_XCLBIN) -t $(TARGET) --platform $(AWS_PLATFORM) --package.out_dir $(PACKAGE_DIR) -o $(XCLBIN)

$(HOST): $(DIRS_READY) $(HOST_SRCS) 
	$(CXX) -o $@ $(HOST_SRCS) $(CXXFLAGS) $(LDFLAGS)

BUILD_ARTIFACTS := $(XCLBIN) $(HOST)
.PHONY: build
build: $(BUILD_ARTIFACTS)


### Run ###
$(TEMP_DIR)/emconfig.json: $(DIRS_READY)
	emconfigutil --platform $(AWS_PLATFORM) --od $(TEMP_DIR)

.PHONY: run
run: $(BUILD_ARTIFACTS) $(TEMP_DIR)/emconfig.json
ifeq ($(TARGET), hw_emu)
	cp -rf $(TEMP_DIR)/emconfig.json .
	XCL_EMULATION_MODE=$(TARGET) $(HOST) $(XCLBIN)
	rm -rf ./emconfig.json
else
	$(error Wrong TARGET for run, should be hw_emu)
endif
 

### CLEAN ###
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) _x .Xil || true
	rm -f *.jou
	rm -f *.log
