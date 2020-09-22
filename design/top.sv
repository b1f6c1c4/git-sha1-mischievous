module top (
   input logic [511:0] block_i,
   output logic [159:0] dgst_o
);

   sha1_block_boundry blocks[0:1]();

   sha1_head i_head (
      .next_intf (blocks[0])
   );
   sha1_block i_block (
      .block_i,
      .prev_intf (blocks[0]),
      .next_intf (blocks[1])
   );

   assign dgst_o[159:128] = blocks[1].H4;
   assign dgst_o[127:96] = blocks[1].H3;
   assign dgst_o[95:64] = blocks[1].H2;
   assign dgst_o[63:32] = blocks[1].H1;
   assign dgst_o[31:0] = blocks[1].H0;

endmodule
