`timescale 1ns / 1ps

`define assert(condition, test_name) \
    if (!condition) \
        $display("%s - FAILED", test_name); \
    else \
        $display("%s - SUCCESS", test_name);


module tb_accumulator;
    parameter real CLK_PERIOD = 10;  // 100 MHz
    
    reg clk, reset, write_enabled;
    reg[31:0] in_data;
    wire acc_val;
    
    initial begin 
        clk = 0;
        forever begin
            clk = #(CLK_PERIOD/2) ~clk;
        end
    end

    accumulator acc (
        .clk(clk),
        .reset(reset),
        .write_enabled(write_enabled),
        .in_data(in_data),
        .acc_val(acc_val)
    );
    
    initial begin
        #1;
        reset = 1;
        write_enabled = 1;
        in_data = 3;
        
        repeat (2) @(posedge clk);  // Stay a bit with reset for predictable starting conditions
        $display("\nStarting accumulator tests");
        #1 `assert(acc_val === 0, "acc_val is 0 at reset");
        #1 reset = 0;
        #1 `assert(acc_val === 0, "acc_val doesn't update without clock changes");
        
        @(negedge clk) #1 `assert(acc_val === 0, "acc_val doesn't update on negative clock edge");
        @(posedge clk) #1 `assert(acc_val === 3, "acc_val updates on positive clock edge");
        
        repeat (2) @(posedge clk);
        #1 `assert(acc_val === 9, "acc_val continues to update as clock progresses and the rest is unchanged");
        
        write_enabled = 0;
        in_data = -2;
        repeat (2) @(posedge clk);
        #1 `assert(acc_val === 9, "acc_val stays constant when write is not enabled");
        
        write_enabled = 1;
        repeat (2) @(posedge clk);
        #1 `assert(acc_val === 5, "acc_val updates again after enabling write");
        
        reset = 1;
        @(posedge clk) #1 `assert(acc_val === 0, "acc_val successfully resets on reset signal");
        
        #20;
        $display("\nTests finished");
        $finish;
    end

endmodule
