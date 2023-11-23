# How to run Verilog code?

To be able to run and compile any of the Verilog code you need to clone https://github.com/aws/aws-fpga
and source its `vitis_setup.sh` script.

Ideally you would do that inside of the [FPGA Developer AMI](https://aws.amazon.com/marketplace/pp/prodview-gimv3gqbpe57k)
image. Otherwise, you will also need to install all the Xilinx dependencies manually what proves to be extremely hard
to get right (believe me, I've been trying for a week, and each time failed miserably).

If in doubt, refer to the https://github.com/aws/aws-fpga repository.
