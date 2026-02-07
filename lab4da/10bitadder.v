`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:38:46 02/06/2026 
// Design Name: 
// Module Name:    10bitadder 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module addr_adder_10bit (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable, 
    output reg [9:0]   addr_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            addr_out <= 10'd0;
        end
        else if (enable) begin
            addr_out <= addr_out + 10'd1;
        end
    end

endmodule