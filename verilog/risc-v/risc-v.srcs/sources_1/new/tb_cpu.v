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


module tb_cpu;
    reg clk;
    
    always begin
        #5 clk = !clk;
        if (clk)
            $display("Clock up");
        else
            $display("Clock down");
    end
    
    initial begin
        $display("Starting tb_cpu");
        clk=0;
        
        #100; 
        $display("Finishing tb_cpu");
        $finish;
    end
endmodule
