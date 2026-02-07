///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// $Id: module_template 2008-03-13 gac1 $
//
// Module: ids.v
// Project: NF2.1
// Description: Defines a simple ids module for the user data path.  The
// modules reads a 64-bit register that contains a pattern to match and
// counts how many packets match.  The register contents are 7 bytes of
// pattern and one byte of mask.  The mask bits are set to one for each
// byte of the pattern that should be included in the mask -- zero bits
// mean "don't care".
//
///////////////////////////////////////////////////////////////////////////////

// PASSTHROUGH IDS.V

`timescale 1ns/1ps

`define IDS_BLOCK_ADDR 1

module ids 
   #(
      parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH = DATA_WIDTH/8,
      parameter UDP_REG_SRC_WIDTH = 2
   )
   (
      input  [DATA_WIDTH-1:0]             in_data,
      input  [CTRL_WIDTH-1:0]             in_ctrl,
      input                               in_wr,
      output                              in_rdy,

      output [DATA_WIDTH-1:0]             out_data,
      output [CTRL_WIDTH-1:0]             out_ctrl,
      output                              out_wr,
      input                               out_rdy,
      
      // --- Register interface
      input                               reg_req_in,
      input                               reg_ack_in,
      input                               reg_rd_wr_L_in,
      input  [`UDP_REG_ADDR_WIDTH-1:0]    reg_addr_in,
      input  [`CPCI_NF2_DATA_WIDTH-1:0]   reg_data_in,
      input  [UDP_REG_SRC_WIDTH-1:0]      reg_src_in,

      output                              reg_req_out,
      output                              reg_ack_out,
      output                              reg_rd_wr_L_out,
      output  [`UDP_REG_ADDR_WIDTH-1:0]   reg_addr_out,
      output  [`CPCI_NF2_DATA_WIDTH-1:0]  reg_data_out,
      output  [UDP_REG_SRC_WIDTH-1:0]     reg_src_out,

      // misc
      input                                reset,
      input                                clk
   );

   //------------------------- Passthrough-------------------------------
   assign out_data = in_data;
   assign out_ctrl = in_ctrl;
   assign out_wr = in_wr;
   assign in_rdy = out_rdy;
   
   assign reg_req_out = reg_req_in;
   assign reg_ack_out = reg_ack_in;
   assign reg_rd_wr_L_out = reg_rd_wr_L_in;
   assign reg_addr_out = reg_addr_in;
   assign reg_data_out = reg_data_in;
   assign reg_src_out = reg_src_in;

   // LOGIC ANALYZER
   wire [31:0] la_out_da;

   wire begin_pkt          = 1'b0;
   wire end_of_pkt         = 1'b0;
   wire [2:0] hdr_cnt      = 3'b000;
   wire ids_cmd            = 1'b0;
   wire in_fifo_empty      = 1'b0;

   wire in_fifo_rd_en      = out_wr;
   wire in_pkt_body        = 1'b1;
   wire matcher_match      = 1'b0;
   wire matcher_reset      = reset;
   wire [1:0] state        = 2'b00;

   logic_analyzer LA(
      .begin_pkt(begin_pkt),
      .clk(clk),
      .end_of_pkt(end_of_pkt),
      .header_counter(hdr_cnt),
      .ids_cmd(ids_cmd),
      .in_fifo_empty(in_fifo_empty),
      .in_fifo_rd_en(in_fifo_rd_en),
      .in_pkt_body(in_pkt_body),
      .matcher_match(matcher_match),
      .matcher_reset(matcher_reset),
      .out_rdy(out_rdy),
      .out_wr(out_wr),
      .state(state),
      .out_da(la_out_da)
   );


 
endmodule 
