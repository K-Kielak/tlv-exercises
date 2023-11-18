`timescale 1ns / 1ps

`define assert(condition, test_name) \
    if (!condition) \
        $display("%s - FAILED", test_name); \
    else \
        $display("%s - SUCCESS", test_name);

module tb_cpu;
    parameter real CLK_PERIOD = 10; // 10 MHz

    // Setup
    reg clk, reset;
    wire[31:0] pc;
    
    initial begin
        clk = 0;
        forever begin
            clk = #(CLK_PERIOD/2) ~clk;
        end
    end
        
    cpu test_cpu(
        .clk(clk),
        .reset(reset),
        .pc(pc)
    );
        
    // Tests
    initial begin
        #1 reset = 1;
        $display("\nStarting CPU tests...");
        
        repeat (2) @(posedge clk); // Stay a bit with reset for predictable starting conditions
        $display("\nTesting for correct starting conditions:");
        `assert(pc === 0, "PC is 0 at reset");
        
        // Set reset to 0 to start normal operations
        #1 reset = 0;  // time = 8
        $display("\nTesting for correct PC behaviour:");
        #1 `assert(pc === 0, "PC doesn't update without clock changes");  // time = 9
        @(negedge clk) #1 `assert(pc === 0, "PC doesn't update on negative clock edge"); // time = 13
        @(posedge clk) #1 `assert(pc === 1, "PC updates on positive clock edge"); // time = 18;
        
        repeat (3) @(posedge clk);
        #1 `assert(pc === 4, "3 clock cycles lead to PC increment of 3"); // time = 48
        
        #20; 
        $display("\nFinished CPU tests.");
        $finish;
    end
endmodule
