`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2023 11:12:47 AM
// Design Name: 
// Module Name: accumulator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


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
