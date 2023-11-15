`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2023 12:47:51 PM
// Design Name: 
// Module Name: tb_cpu
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
    


module tb_cpu;
    // Setup
    reg clk, reset;
    wire[31:0] pc;
    cpu test_cpu(
        .clk(clk),
        .reset(reset),
        .pc(pc)
    );
    
    always
        #5 clk = !clk;
        
    initial begin
        clk=0;
        reset=1;
    end
        
    // Tests
    initial begin
        $display("\nStarting CPU tests...");
        
        #7; // Stay a bit with reset for predictable starting conditions
        $display("\nTesting for correct starting conditions:");
        `assert(pc === 0, "PC is 0 at reset");
        
        // Set reset to 0 to start normal operations
        #1 reset = 0;  // time = 8
        $display("\nTesting for correct PC behaviour:");
        #1 `assert(pc === 0, "PC doesn't update without clock changes");  // time = 9
        #4 `assert(pc === 0, "PC doesn't update on negative clock edge"); // time = 13
        #5 `assert(pc === 1, "PC updates on positive clock edge"); // time = 18;
        #30 `assert(pc === 4, "3 clock cycles lead to PC increment of 3"); // time = 48
        
        #10; 
        $display("\nFinished CPU tests.");
        $finish;
    end
endmodule
