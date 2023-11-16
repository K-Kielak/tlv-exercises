`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2023 11:17:11 AM
// Design Name: 
// Module Name: tb_accumulator
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


`define assert(condition, test_name) \
    if (!condition) \
        $display("%s - FAILED", test_name); \
    else \
        $display("%s - SUCCESS", test_name);


module tb_accumulator;
    reg clk, reset, write_enabled;
    reg[31:0] in_data;
    wire acc_val;
    
    accumulator acc (
        .clk(clk),
        .reset(reset),
        .write_enabled(write_enabled),
        .in_data(in_data),
        .acc_val(acc_val)
    );
    
    always @(*) begin
        #5 clk = !clk;
    end

    initial begin
        clk = 0;
        reset = 1;
        write_enabled = 1;
        in_data = 3;
        
        #7  // Stay a bit with reset for predictable starting conditions
        $display("\nStarting accumulator tests");
        `assert(acc_val === 0, "acc_val is 0 at reset");
        
        #1 reset = 0;
        #1 `assert(acc_val === 0, "acc_val doesn't update without clock changes");
        #4 `assert(acc_val === 0, "acc_val doesn't update on negative clock edge");
        #5 `assert(acc_val === 3, "acc_val updates on positive clock edge");
        #20 `assert(acc_val === 9, "acc_val continues to update as clock progresses and the rest is unchanged");
        
        write_enabled = 0;
        in_data = -2;
        #20 `assert(acc_val === 9, "acc_val stays constant when write is not enabled");
        
        write_enabled = 1;
        #20 `assert(acc_val === 5, "acc_val updates again after enabling write");
        
        reset = 1;
        #10 `assert(acc_val === 0, "acc_val successfully resets on reset signal");
        
        #20;
        $display("\nTests finished");
        $finish;
    end

endmodule
