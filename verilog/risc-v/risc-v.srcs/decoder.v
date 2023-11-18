`timescale 1ns / 1ps

module decoder(
    input[31:0] instruction,
    output[6:0] opcode
);
    assign opcode = instruction[6:0];
endmodule
