module tile #(
   parameter MSG_LEN = 1234
) (
   input logic clk_i,
   input logic rst_ni,

   input logic msg_val_i,
   input logic [MSG_LEN-1:0] msg_i,
   output logic msg_rdy_o,

   input logic [159:0] dgst_i,
   input logic [159:0] dgst_mask_i,

   output logic dgst_val_o,
   output logic dgst_o,
   input logic dgst_rdy_i
);

   logic [2:0] state;
   logic [$clog2(BLOCKS)-1:0] blk_id;
   logic [511:0] blk[0:BLOCKS-1];
   logic init, next;

   // TODO: state machine

   logic [159:0] dgst;

   sha1_core i_core (
      .clk (clk_i),
      .reset_n (rst_ni),

      .init,
      .next,

      .block (blk[blk_id]),

      .ready (msg_rdy_o),
      .digest (dgst),
      .digest_valid (dgst_val_o)
   );

   assign dgst_o = ~|((dgst ^ dgst_i) & dgst_mask_i);

endmodule
