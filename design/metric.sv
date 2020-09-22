module metric (
   input logic clk_i,
   input logic [159:0] a_i,
   input logic [159:0] b_i,
   output logic [$clog2(160+1):0] metric_o
);

   logic [159:0] diff;
   assign diff = a_i ^ b_i;

   /* verilator lint_off UNUSED */
   logic [31:0] m;
   integer i;
   always_comb begin
      m = 160;
      for (i = 159; i >= 0; i--) begin
         if (diff[i]) begin
            m = 159 - i;
         end
      end
   end

   always_ff @(posedge clk_i) begin
      metric_o <= m[$clog2(160+1):0];
   end

endmodule
