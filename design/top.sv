module top #(
   parameter BLOCKS = 1
) (
   input logic clk_i,
   input logic [511:0] block_i[0:BLOCKS-1],
   output logic [159:0] dgst_o
);

   sha1_block_boundry blocks[0:BLOCKS]();

   sha1_head i_head (
      .next_intf (blocks[0])
   );
   generate
   for (genvar i = 0; i < BLOCKS; i++) begin : g_b
      sha1_block i_block (
         .clk_i,
         .block_i (block_i[i]),
         .prev_intf (blocks[i]),
         .next_intf (blocks[i+1])
      );
   end
   endgenerate

   assign dgst_o[31:0] = blocks[BLOCKS].H0;
   assign dgst_o[63:32] = blocks[BLOCKS].H1;
   assign dgst_o[95:64] = blocks[BLOCKS].H2;
   assign dgst_o[127:96] = blocks[BLOCKS].H3;
   assign dgst_o[159:128] = blocks[BLOCKS].H4;

endmodule
