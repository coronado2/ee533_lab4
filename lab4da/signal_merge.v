`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:03:58 02/06/2026 
// Design Name: 
// Module Name:    signal_merge 
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
module signal_merge(
    input [1:0] state,
    input [2:0] hdr_cnt,
    input begin_pkt,
    input end_pkt,
    input in_pkt,
    input fifo_empty,
    input rd_en,
    input out_wr,
    input out_rdy,
    input match,
    input reset,
    input ids_cmd,
    output [31:0] trace
    );

	 assign trace = {
      1'b0,           // [31] reserved / unused maybe i need for future
      ids_cmd,        // [30]
      8'b0,           // [29:22]

      reset,          // [21]
      out_rdy,        // [20]
      out_wr,         // [19]
      match,          // [18]
      rd_en,          // [17]
      fifo_empty,     // [16]

      in_pkt,         // [15]
      end_pkt,        // [14]
      begin_pkt,      // [13]

      hdr_cnt,        // [12:10]
      state,          // [9:8]

      8'b0            // [7:0] unused / padding
    };



endmodule
