`timescale 1ns / 1ps

module cpu(
    input clk,
    input reset,
    output reg[31:0] pc
);  
    always @(posedge clk) begin
        if (reset == 1)
            pc <= 0;
        else
            pc <= pc + 1;
    end
    
    
endmodule
