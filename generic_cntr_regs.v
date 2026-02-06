`timescale 1ns/1ps

`define UDP_REG_ADDR_WIDTH 23
`define CPCI_NF2_DATA_WIDTH 32
`define IDS_BLOCK_TAG 1
`define IDS_REG_ADDR_WIDTH 16

module generic_cntr_regs
   #(
      parameter UDP_REG_SRC_WIDTH = 2,
      parameter TAG = 0,
      parameter REG_ADDR_WIDTH = 5,
      parameter NUM_REGS_USED = 8,
      parameter REG_START_ADDR = 0,
      parameter INPUT_WIDTH = 1,
      parameter MIN_UPDATE_INTERVAL = 8,
      parameter REG_WIDTH = `CPCI_NF2_DATA_WIDTH,
      parameter RESET_ON_READ = 0,
      parameter REG_END_ADDR = REG_START_ADDR + NUM_REGS_USED,
      parameter UPDATES_START = REG_START_ADDR * INPUT_WIDTH,
      parameter UPDATES_END = REG_END_ADDR * INPUT_WIDTH
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

      input  [UPDATES_END - 1:UPDATES_START] updates,
      input  [REG_END_ADDR-1:REG_START_ADDR] decrement,

      input                                  clk,
      input                                  reset
    );

  function integer log2;
      input integer number;
      begin
         log2=0;
         while(2**log2<number) begin
            log2=log2+1;
         end
      end
   endfunction

  function integer ceildiv;
      input integer num;
      input integer divisor;
      begin
         if (num <= divisor)
           ceildiv = 1;
         else begin
            ceildiv = num / divisor;
            if (ceildiv * divisor < num)
              ceildiv = ceildiv + 1;
         end
      end
  endfunction

   localparam MIN_CYCLE_TIME = NUM_REGS_USED + 1;
   localparam UPDATES_PER_CYCLE = ceildiv(MIN_CYCLE_TIME, MIN_UPDATE_INTERVAL);
   localparam LOG_UPDATES_PER_CYCLE = log2(UPDATES_PER_CYCLE);
   localparam DELTA_WIDTH = INPUT_WIDTH + LOG_UPDATES_PER_CYCLE + 1;

   localparam RESET = 0, NORMAL = 1;

   reg [REG_WIDTH-1:0] reg_file [REG_START_ADDR:REG_END_ADDR-1];

   wire [REG_ADDR_WIDTH-1:0] addr, addr_d1;
   wire [`UDP_REG_ADDR_WIDTH-REG_ADDR_WIDTH-1:0] tag_addr;

   reg  [REG_ADDR_WIDTH-1:0] reg_cnt;
   wire [REG_ADDR_WIDTH-1:0] reg_cnt_nxt;
   wire [REG_ADDR_WIDTH-1:0] reg_file_rd_addr;
   reg  [REG_ADDR_WIDTH-1:0] reg_file_rd_addr_ram;
   wire [REG_ADDR_WIDTH-1:0] reg_file_wr_addr;

   reg  [DELTA_WIDTH-1:0] deltas[REG_START_ADDR:REG_END_ADDR-1];
   wire [DELTA_WIDTH-1:0] delta;

   wire [DELTA_WIDTH-1:0] update[REG_START_ADDR:REG_END_ADDR-1];

   wire [REG_WIDTH-1:0] reg_file_out;
   reg  [REG_WIDTH-1:0] reg_file_in;
   reg                  reg_file_wr_en;

   reg  [REG_ADDR_WIDTH-1:0] reg_cnt_d1;
   reg                       reg_rd_req_good_d1, reg_wr_req_good_d1;
   reg  [`UDP_REG_ADDR_WIDTH-1:0] reg_addr_in_d1;
   reg  [`CPCI_NF2_DATA_WIDTH-1:0] reg_data_in_d1;
   reg                       reg_req_in_d1;
   reg                       reg_rd_wr_L_in_d1;
   reg  [UDP_REG_SRC_WIDTH-1:0] reg_src_in_d1;

   wire addr_good;
   wire tag_hit;
   wire reg_rd_req_good;
   wire reg_wr_req_good;

   integer i;
   reg state;

   assign addr = reg_addr_in[REG_ADDR_WIDTH-1:0];
   assign addr_d1 = reg_addr_in_d1[REG_ADDR_WIDTH-1:0];
   assign tag_addr = reg_addr_in[`UDP_REG_ADDR_WIDTH - 1:REG_ADDR_WIDTH];

   assign addr_good = (addr < REG_END_ADDR) && (addr >= REG_START_ADDR);
   assign tag_hit = (tag_addr == TAG);

   assign reg_rd_req_good = tag_hit && addr_good && reg_req_in && reg_rd_wr_L_in;
   assign reg_wr_req_good = tag_hit && addr_good && reg_req_in && ~reg_rd_wr_L_in;

   assign reg_cnt_nxt = (reg_cnt == REG_END_ADDR-1'b1) ? REG_START_ADDR : (reg_cnt + 1'b1);

   assign delta = deltas[reg_cnt_d1];

   assign reg_file_rd_addr = reg_rd_req_good ? addr : reg_cnt;

   assign reg_file_wr_addr =
      (state == RESET) ? reg_cnt :
      (reg_wr_req_good_d1 || reg_rd_req_good_d1) ? addr_d1 :
      reg_cnt_d1;

   always @(*) begin
      reg_file_in    = reg_file_out + {{(REG_WIDTH - DELTA_WIDTH){delta[DELTA_WIDTH-1]}}, delta};
      reg_file_wr_en = 0;

      if(state == RESET || (reg_rd_req_good_d1 && RESET_ON_READ)) begin
         reg_file_wr_en = 1;
         reg_file_in    = 0;
      end
      else if(!reg_wr_req_good_d1 && !reg_rd_req_good_d1) begin
         reg_file_wr_en = 1;
      end
      else if(reg_wr_req_good_d1) begin
         reg_file_in    = reg_data_in_d1;
         reg_file_wr_en = 1;
      end
   end

   generate
      genvar j;
      for (j = REG_START_ADDR; j < REG_END_ADDR; j = j + 1) begin : update_gen
         assign update[j] =
            {{(DELTA_WIDTH - INPUT_WIDTH){1'b0}},
             updates[(j + 1) * INPUT_WIDTH - 1 : j * INPUT_WIDTH]};
      end
   endgenerate

   always @(posedge clk) begin
      if(reg_file_wr_en) begin
         reg_file[reg_file_wr_addr] <= reg_file_in;
      end
      reg_file_rd_addr_ram <= reg_file_rd_addr;
   end

   assign reg_file_out = reg_file[reg_file_rd_addr_ram];

   always @(posedge clk) begin
      if(reset) begin
         reg_cnt            <= REG_START_ADDR;
         reg_rd_req_good_d1 <= 0;
         reg_wr_req_good_d1 <= 0;
         reg_req_in_d1      <= 0;
         reg_ack_out        <= 0;
         reg_req_out        <= 0;
         state              <= RESET;
         for (i = REG_START_ADDR; i < REG_END_ADDR; i = i + 1) begin
            deltas[i] <= 0;
         end
      end
      else begin
         reg_cnt_d1 <= reg_cnt;

         if(state == RESET) begin
            reg_cnt <= reg_cnt_nxt;
            if(reg_cnt == REG_END_ADDR-1'b1)
               state <= NORMAL;
         end
         else begin
            reg_cnt            <= (reg_rd_req_good || reg_wr_req_good) ? reg_cnt : reg_cnt_nxt;
            reg_rd_req_good_d1 <= reg_rd_req_good;
            reg_wr_req_good_d1 <= reg_wr_req_good;
            reg_addr_in_d1     <= reg_addr_in;
            reg_data_in_d1     <= reg_data_in;
            reg_req_in_d1      <= reg_req_in;
            reg_rd_wr_L_in_d1  <= reg_rd_wr_L_in;
            reg_src_in_d1      <= reg_src_in;

            reg_ack_out     <= reg_rd_req_good_d1 || reg_wr_req_good_d1 || reg_ack_in;
            reg_data_out    <= reg_rd_req_good_d1 ? reg_file_out : reg_data_in_d1;
            reg_addr_out    <= reg_addr_in_d1;
            reg_req_out     <= reg_req_in_d1;
            reg_rd_wr_L_out <= reg_rd_wr_L_in_d1;
            reg_src_out     <= reg_src_in_d1;

            for (i = REG_START_ADDR; i < REG_END_ADDR; i = i + 1) begin
               if ((i==reg_cnt_d1) &&
                   !reg_wr_req_good_d1 &&
                   !(reg_rd_req_good_d1 && RESET_ON_READ)) begin
                  deltas[i] <= decrement[i] ? -update[i] : update[i];
               end
               else begin
                  deltas[i] <= decrement[i] ? (deltas[i] - update[i]) : (deltas[i] + update[i]);
               end
            end
         end
      end
   end

endmodule
