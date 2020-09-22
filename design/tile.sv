`include "global.svh"

module tile (
   input logic clk_i,
   input logic reset_ni,
   input logic seed_val_i,
   input logic [31:0] seed_i,
   input logic [MSG-1:0] msg_i,
   input logic [MSG-1:0] mask_i,
   input logic [159:0] dgst_i,
   output logic [$clog2(160+1):0] metric_o,
   output logic [MSG-1:0] msg_o
);
   localparam MSG = 512 * `BLOCKS;
   localparam RNGS = 16 * `BLOCKS;
   localparam DH = 241 * `BLOCKS + 1; // TODO

   logic [$clog2(RNGS+1)-1:0] load_rng;
   logic [MSG-1:0] random;

   generate
   for (genvar i = 0; i < RNGS; i++) begin : g_r
      rng i_rng (
         .clk (clk_i),
         .reset (reset_ni),
         .loadseed_i (seed_val_i && load_rng == i),
         .seed_i,
         .number_o (random[i*32+31:i*32])
      );
   end
   endgenerate

   logic [MSG-1:0] msg[0:DH];
   generate
   for (genvar i = 0; i < DH; i++) begin : g_m
      always @(posedge clk_i) begin
         msg[i+1] <= msg[i];
      end
   end
   endgenerate

   assign msg[0] = mask_i & random | ~mask_i & msg_i;
   assign msg_o = msg[DH];

   sha1_block_boundry blocks[0:`BLOCKS]();

   sha1_head i_head (
      .next_intf (blocks[0])
   );
   generate
   for (genvar i = 0; i < `BLOCKS; i++) begin : g_b
      sha1_block #(.ID (i)) i_block (
         .clk_i,
         .block_i (msg[0][512*i+511:0]),
         .prev_intf (blocks[i]),
         .next_intf (blocks[i+1])
      );
   end
   endgenerate

   logic [159:0] dgst;
   assign dgst[31:0] = blocks[`BLOCKS].H4;
   assign dgst[63:32] = blocks[`BLOCKS].H3;
   assign dgst[95:64] = blocks[`BLOCKS].H2;
   assign dgst[127:96] = blocks[`BLOCKS].H1;
   assign dgst[159:128] = blocks[`BLOCKS].H0;

   metric i_metric (
      .clk_i,
      .a_i (dgst_i),
      .b_i (dgst),
      .metric_o
   );

   always_ff @(posedge clk_i, negedge reset_ni) begin
      if (~reset_ni) begin
         load_rng <= 0;
      end else if (seed_val_i && load_rng < RNGS) begin
         load_rng <= load_rng + 1;
      end
   end

endmodule
