/* verilator lint_off DECLFILENAME */

interface sha1_block_boundry;
   logic [31:0] H0;
   logic [31:0] H1;
   logic [31:0] H2;
   logic [31:0] H3;
   logic [31:0] H4;
   modport master (
      output H0,
      output H1,
      output H2,
      output H3,
      output H4
   );
   modport slave (
      input H0,
      input H1,
      input H2,
      input H3,
      input H4
   );
endinterface

module sha1_head (
   sha1_block_boundry.master next_intf
);

   assign next_intf.H0 = 32'h67452301;
   assign next_intf.H1 = 32'hefcdab89;
   assign next_intf.H2 = 32'h98badcfe;
   assign next_intf.H3 = 32'h10325476;
   assign next_intf.H4 = 32'hc3d2e1f0;

endmodule

interface sha1_word_boundry;
   logic [31:0] Ws00;
   logic [31:0] Ws01;
   logic [31:0] Ws02;
   logic [31:0] Ws03;
   logic [31:0] Ws04;
   logic [31:0] Ws05;
   logic [31:0] Ws06;
   logic [31:0] Ws07;
   logic [31:0] Ws08;
   logic [31:0] Ws09;
   logic [31:0] Ws10;
   logic [31:0] Ws11;
   logic [31:0] Ws12;
   logic [31:0] Ws13;
   logic [31:0] Ws14;
   logic [31:0] Ws15;
   logic [31:0] A, B, C, D, E;
   modport master (
      output Ws00,
      output Ws01,
      output Ws02,
      output Ws03,
      output Ws04,
      output Ws05,
      output Ws06,
      output Ws07,
      output Ws08,
      output Ws09,
      output Ws10,
      output Ws11,
      output Ws12,
      output Ws13,
      output Ws14,
      output Ws15,
      output A, B, C, D, E
   );
   modport slave (
      input Ws00,
      input Ws01,
      input Ws02,
      input Ws03,
      input Ws04,
      input Ws05,
      input Ws06,
      input Ws07,
      input Ws08,
      input Ws09,
      input Ws10,
      input Ws11,
      input Ws12,
      input Ws13,
      input Ws14,
      input Ws15,
      output A, B, C, D, E
   );
endinterface

module sha1_block (
   input logic [511:0] block_i,
   sha1_block_boundry.slave prev_intf,
   sha1_block_boundry.master next_intf
);

   sha1_word_boundry words[0:80]();

   assign words[0].Ws00 = block_i[511:480];
   assign words[0].Ws01 = block_i[479:448];
   assign words[0].Ws02 = block_i[447:416];
   assign words[0].Ws03 = block_i[415:384];
   assign words[0].Ws04 = block_i[383:352];
   assign words[0].Ws05 = block_i[351:320];
   assign words[0].Ws06 = block_i[319:288];
   assign words[0].Ws07 = block_i[287:256];
   assign words[0].Ws08 = block_i[255:224];
   assign words[0].Ws09 = block_i[223:192];
   assign words[0].Ws10 = block_i[191:160];
   assign words[0].Ws11 = block_i[159:128];
   assign words[0].Ws12 = block_i[127:96];
   assign words[0].Ws13 = block_i[95:64];
   assign words[0].Ws14 = block_i[63:32];
   assign words[0].Ws15 = block_i[31:0];

   assign words[0].A = prev_intf.H0;
   assign words[0].B = prev_intf.H1;
   assign words[0].C = prev_intf.H2;
   assign words[0].D = prev_intf.H3;
   assign words[0].E = prev_intf.H4;

   generate
   for (genvar t = 0; t < 80; t++) begin : g_t
      sha1_node #(.T (t)) i_node (
         .prev_intf (words[t]),
         .next_intf (words[t+1])
      );
   end
   endgenerate

   assign next_intf.H0 = prev_intf.H0 + words[80].A;
   assign next_intf.H1 = prev_intf.H1 + words[80].B;
   assign next_intf.H2 = prev_intf.H2 + words[80].C;
   assign next_intf.H3 = prev_intf.H3 + words[80].D;
   assign next_intf.H4 = prev_intf.H4 + words[80].E;

endmodule

module sha1_node #(
   parameter T = 0
) (
   sha1_word_boundry.slave prev_intf,
   sha1_word_boundry.master next_intf
);

   logic [31:0] f, K;
   always_comb begin
      if (T < 20) begin
         f = (prev_intf.B & prev_intf.C) | (~prev_intf.B & prev_intf.D);
         K = 32'h5a827999;
      end else if (T < 40) begin
         f = prev_intf.B ^ prev_intf.C ^ prev_intf.D;
         K = 32'h6ed9eba1;
      end else if (T < 60) begin
         f = (prev_intf.B & prev_intf.C) | (prev_intf.B & prev_intf.D) | (prev_intf.C & prev_intf.D);
         K = 32'h8f1bbcdc;
      end else begin
         f = prev_intf.B ^ prev_intf.C ^ prev_intf.D;
         K = 32'hca62c1d6;
      end
   end

   logic [31:0] P;
   always_comb begin
      P = {prev_intf.A[26:0],prev_intf.A[31:27]};
      P += f;
      P += prev_intf.Ws00;
      P += prev_intf.E;
      P += K;
   end

   always_comb begin
      next_intf.A = P;
      next_intf.B = prev_intf.A;
      next_intf.C = {prev_intf.B[1:0],prev_intf.B[31:2]};
      next_intf.D = prev_intf.C;
      next_intf.E = prev_intf.D;
   end

   logic [31:0] X;
   always_comb begin
      X = prev_intf.Ws14;
      X ^= prev_intf.Ws09;
      X ^= prev_intf.Ws03;
      X ^= prev_intf.Ws01;
   end

   always_comb begin
      next_intf.Ws00 = (T < 15) ? prev_intf.Ws01 : {X[30:0],X[31]};
      next_intf.Ws01 = prev_intf.Ws02;
      next_intf.Ws02 = prev_intf.Ws03;
      next_intf.Ws03 = prev_intf.Ws04;
      next_intf.Ws04 = prev_intf.Ws05;
      next_intf.Ws05 = prev_intf.Ws06;
      next_intf.Ws06 = prev_intf.Ws07;
      next_intf.Ws07 = prev_intf.Ws08;
      next_intf.Ws08 = prev_intf.Ws09;
      next_intf.Ws09 = prev_intf.Ws10;
      next_intf.Ws10 = prev_intf.Ws11;
      next_intf.Ws11 = prev_intf.Ws12;
      next_intf.Ws12 = prev_intf.Ws13;
      next_intf.Ws13 = prev_intf.Ws14;
      next_intf.Ws14 = prev_intf.Ws15;
      next_intf.Ws15 = prev_intf.Ws00;
   end

endmodule
