module solver #(
   parameter MSG_LEN = 1234,
   parameter TILES = 2
) (
   input clk_i,
   input rst_ni,

   input [114:0] seed_i,

   input [MSG_LEN-1:0] data_i,
   input [MSG_LEN-1:0] data_mask_i,

   input [159:0] dgst_i,
   input [159:0] dgst_mask_i,

   output [MSG_LEN-1:0] result_o,
   output result_val_o
);
   localparam BLOCKS = (MSG_LEN + 1 + 64) / 512;

   // TODO: generator
   // https://opencores.org/projects/systemc_rng

   logic [$clog2(TILES)-1:0] tile_id;
   logic msg_val;
   logic [MSG_LEN-1:0] msg;
   logic [TILES-1:0] msg_rdy;
   logic [TILES-1:0] dgst_val;
   logic [TILES-1:0] dgst;
   logic dgst_rdy;

   // TODO: coordinator

   generate
   for (genvar gi = 0; gi < TILES; gi++) begin : g_c
      tile #(
         .MSG_LEN (MSG_LEN)
      ) i_tile (
         .clk_i,
         .rst_ni,

         .msg_val_i (msg_val && tile_id == gi),
         .msg_i (msg),
         .msg_rdy_o (msg_rdy[gi]),

         .dgst_i,
         .dgst_mask_i,

         .dgst_val_o (dgst_val[gi]),
         .dgst_o (dgst[gi]),
         .dgst_rdy_i (dgst_rdy && tile_id == gi)
      );
   end
   endgenerate

endmodule
