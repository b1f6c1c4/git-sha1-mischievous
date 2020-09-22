`include "global.svh"

module system #(
   parameter TILES = 1 // "inv"
) (
   input logic clk_i,
   input logic reset_ni,
   input logic [31:0] seed_i,
   input logic [MSG-1:0] msg_i,
   input logic [MSG-1:0] mask_i,
   input logic [159:0] dgst_i,
   output logic [$clog2(160+1):0] progress_o,
   output logic [MSG-1:0] msg_o
);
   localparam MSG = 512 * `BLOCKS;
   localparam SKIP = 114;
   localparam DH = 241 * `BLOCKS + 2;

   logic [$clog2(2+SKIP+DH):0] state;
   logic [$clog2(160+1):0] progress_next;
   logic [MSG-1:0] msg_next;
   always_ff @(posedge clk_i, negedge reset_ni) begin
      if (~reset_ni) begin
         state <= 0;
         progress_o <= 0;
         msg_o <= 0;
      end else if (state <= SKIP + DH) begin
         state <= state + 1;
      end else begin
         progress_o <= progress_next;
         msg_o <= msg_next;
      end
   end

   logic [31:0] seed;
   rng i_rng (
      .clk (clk_i),
      .reset (reset_ni),
      .loadseed_i (state <= 1),
      .seed_i,
      .number_o (seed)
   );

   logic [$clog2(160+1):0] metric[0:TILES-1];
   logic [MSG-1:0] msg[0:TILES-1];
   generate
   for (genvar i = 0; i < TILES; i++) begin : g_t
      tile i_tile (
         .clk_i,
         .reset_ni,
         .seed_val_i (state > SKIP),
         .seed_i (seed),
         .msg_i,
         .mask_i,
         .dgst_i,
         .metric_o (metric[i]),
         .msg_o (msg[i])
      );
   end
   endgenerate

   integer i;
   always_comb begin
      progress_next = progress_o;
      msg_next = msg_o;
      for (i = 0; i < TILES; i++) begin
         if (metric[i] > progress_next) begin
            progress_next = metric[i];
            msg_next = msg[i];
         end
      end
   end

endmodule
