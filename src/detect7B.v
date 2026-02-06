////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 10.1
//  \   \         Application : sch2verilog
//  /   /         Filename : detect7B.vf
// /___/   /\     Timestamp : 02/04/2026 15:06:09
// \   \  /  \ 
//  \___\/\___\ 
//
//Command: C:\Xilinx\10.1\ISE\bin\nt\unwrapped\sch2verilog.exe -intstyle ise -family virtex2p -w C:/test_sch/detect7B.sch detect7B.vf
//Design Name: detect7B
//Device: virtex2p
//Purpose:
//    This verilog netlist is translated from an ECS schematic.It can be 
//    synthesized and simulated, but it should not be modified. 
//
`timescale 1ns / 1ps

module detect7B(ce, 
                clk, 
                hwregA, 
                match_en, 
                mrst, 
                pipe1, 
                match);

    input ce;
    input clk;
    input [63:0] hwregA;
    input match_en;
    input mrst;
    input [71:0] pipe1;
   output match;
   
   wire [71:0] pipe0;
   wire XLXN_9;
   wire XLXN_10;
   wire [111:0] XLXN_14;
   wire XLXN_20;
   wire match_DUMMY;
   
   assign match = match_DUMMY;
   busmerge XLXI_1 (.da(pipe0[47:0]), 
                    .db(pipe1[63:0]), 
                    .q(XLXN_14[111:0]));
   wordmatch XLXI_2 (.datacomp(hwregA[55:0]), 
                     .datain(XLXN_14[111:0]), 
                     .wildcard(hwregA[62:56]), 
                     .match(XLXN_9));
   reg9B XLXI_3 (.ce(ce), 
                 .clk(clk), 
                 .clr(XLXN_10), 
                 .d(pipe1[71:0]), 
                 .q(pipe0[71:0]));
   FD XLXI_4 (.C(clk), 
              .D(mrst), 
              .Q(XLXN_10));
   defparam XLXI_4.INIT = 1'b0;
   FDCE XLXI_5 (.C(clk), 
                .CE(XLXN_20), 
                .CLR(XLXN_10), 
                .D(XLXN_20), 
                .Q(match_DUMMY));
   defparam XLXI_5.INIT = 1'b0;
   AND3B1 XLXI_6 (.I0(match_DUMMY), 
                  .I1(match_en), 
                  .I2(XLXN_9), 
                  .O(XLXN_20));
endmodule
