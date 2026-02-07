////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 10.1
//  \   \         Application : sch2verilog
//  /   /         Filename : logic_analyzer.vf
// /___/   /\     Timestamp : 02/06/2026 14:53:15
// \   \  /  \ 
//  \___\/\___\ 
//
//Command: C:\Xilinx\10.1\ISE\bin\nt\unwrapped\sch2verilog.exe -intstyle ise -family virtex2p -w C:/Xilinx/10.1/ISE/lab4-analyzer/logic_analyzer.sch logic_analyzer.vf
//Design Name: logic_analyzer
//Device: virtex2p
//Purpose:
//    This verilog netlist is translated from an ECS schematic.It can be 
//    synthesized and simulated, but it should not be modified. 
//
`timescale 1ns / 1ps

module logic_analyzer(begin_pkt, 
                      clk, 
                      end_of_pkt, 
                      header_counter, 
                      ids_cmd, 
                      in_fifo_empty, 
                      in_fifo_rd_en, 
                      in_pkt_body, 
                      matcher_match, 
                      matcher_reset, 
                      out_rdy, 
                      out_wr, 
                      state, 
                      out_da);

    input begin_pkt;
    input clk;
    input end_of_pkt;
    input [2:0] header_counter;
    input ids_cmd;
    input in_fifo_empty;
    input in_fifo_rd_en;
    input in_pkt_body;
    input matcher_match;
    input matcher_reset;
    input out_rdy;
    input out_wr;
    input [1:0] state;
   output [31:0] out_da;
   
   wire [31:0] XLXN_2;
   wire XLXN_19;
   wire [0:0] XLXN_20;
   wire [9:0] XLXN_21;
   wire XLXN_25;
   
   da_bram XLXI_1 (.addra(XLXN_21[9:0]), 
                   .clka(clk), 
                   .dina(XLXN_2[31:0]), 
                   .ena(XLXN_19), 
                   .wea(XLXN_20[0]), 
                   .douta(out_da[31:0]));
   VCC XLXI_4 (.P(XLXN_19));
   AND2 XLXI_5 (.I0(out_wr), 
                .I1(in_fifo_rd_en), 
                .O(XLXN_20[0]));
   addr_adder_10bit XLXI_6 (.clk(clk), 
                            .enable(XLXN_20[0]), 
                            .reset(XLXN_25), 
                            .addr_out(XLXN_21[9:0]));
   GND XLXI_7 (.G(XLXN_25));
   signal_merge XLXI_10 (.begin_pkt(begin_pkt), 
                         .end_pkt(end_of_pkt), 
                         .fifo_empty(in_fifo_empty), 
                         .hdr_cnt(header_counter[2:0]), 
                         .ids_cmd(ids_cmd), 
                         .in_pkt(in_pkt_body), 
                         .match(matcher_match), 
                         .out_rdy(out_rdy), 
                         .out_wr(out_wr), 
                         .rd_en(in_fifo_rd_en), 
                         .reset(matcher_reset), 
                         .state(state[1:0]), 
                         .trace(XLXN_2[31:0]));
endmodule
