`timescale 1ns / 1ps

module accumulator(
    input wire clk,
    input wire reset,
    
    input wire write_enabled,
    input wire[31:0] in_data,
    output reg[31:0] acc_val
);    
    always @(posedge clk) begin
        if (reset)
            acc_val <= 0;
        else if (write_enabled)
            acc_val <= acc_val + in_data;
    end
endmodule
