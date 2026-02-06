`timescale 1ns/1ps

`define UDP_REG_ADDR_WIDTH 23
`define CPCI_NF2_DATA_WIDTH 32

module generic_hw_regs
   #(
      parameter UDP_REG_SRC_WIDTH     = 2,
      parameter TAG                   = 0,
      parameter REG_ADDR_WIDTH        = 5,
      parameter NUM_REGS_USED         = 8,
      parameter REG_START_ADDR        = 0,

      parameter REG_END_ADDR = REG_START_ADDR + NUM_REGS_USED,
      parameter OUTPUT_START = REG_START_ADDR * `CPCI_NF2_DATA_WIDTH,
      parameter OUTPUT_END   = REG_END_ADDR * `CPCI_NF2_DATA_WIDTH
   )
   (
      input                                  reg_req_in,
      input                                  reg_ack_in,
      input                                  reg_rd_wr_L_in,
      input  [`UDP_REG_ADDR_WIDTH-1:0]       reg_addr_in,
      input  [`CPCI_NF2_DATA_WIDTH-1:0]      reg_data_in,
      input  [UDP_REG_SRC_WIDTH-1:0]         reg_src_in,

      output reg                             reg_req_out,
      output reg                             reg_ack_out,
      output reg                             reg_rd_wr_L_out,
      output reg [`UDP_REG_ADDR_WIDTH-1:0]   reg_addr_out,
      output reg [`CPCI_NF2_DATA_WIDTH-1:0]  reg_data_out,
      output reg [UDP_REG_SRC_WIDTH-1:0]     reg_src_out,

      input  [OUTPUT_END - 1 : OUTPUT_START] hardware_regs,

      input                                  clk,
      input                                  reset
    );

   wire [REG_ADDR_WIDTH-1:0] addr;
   wire [`UDP_REG_ADDR_WIDTH-REG_ADDR_WIDTH-1:0] tag_addr;

   wire addr_good;
   wire tag_hit;

   wire [`CPCI_NF2_DATA_WIDTH-1:0] reg_file[REG_START_ADDR:REG_END_ADDR-1];

   assign addr = reg_addr_in;
   assign tag_addr = reg_addr_in[`UDP_REG_ADDR_WIDTH - 1:REG_ADDR_WIDTH];

   assign addr_good = addr < REG_END_ADDR && addr >= REG_START_ADDR;
   assign tag_hit = tag_addr == TAG;

   generate
      genvar i;
      for (i=REG_START_ADDR; i<REG_END_ADDR; i=i+1) begin:reg_file_assigns
         assign reg_file[i] =
            hardware_regs[`CPCI_NF2_DATA_WIDTH*(i+1)-1:`CPCI_NF2_DATA_WIDTH*i];
      end
   endgenerate

   always @(posedge clk) begin
      if(reset) begin
         reg_req_out     <= 0;
         reg_ack_out     <= 0;
         reg_rd_wr_L_out <= 0;
         reg_addr_out    <= 0;
         reg_src_out     <= 0;
         reg_data_out    <= 0;
      end
      else begin
         if(addr_good && tag_hit && reg_req_in) begin
            reg_req_out     <= reg_req_in;
            reg_ack_out     <= 1'b1;
            reg_rd_wr_L_out <= reg_rd_wr_L_in;
            reg_addr_out    <= reg_addr_in;
            reg_src_out     <= reg_src_in;

            if(reg_rd_wr_L_in) begin
               reg_data_out <= reg_file[addr];
            end
            else begin
               reg_data_out <= reg_data_in;
            end
         end
         else begin
            reg_req_out     <= reg_req_in;
            reg_ack_out     <= reg_ack_in;
            reg_rd_wr_L_out <= reg_rd_wr_L_in;
            reg_addr_out    <= reg_addr_in;
            reg_src_out     <= reg_src_in;
            reg_data_out    <= reg_data_in;
         end
      end
   end

endmodule
