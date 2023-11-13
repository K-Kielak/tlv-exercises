\m5_TLV_version 1d: tl-x.org
\m5
\SV
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m5_makerchip_module   // (Expanded in Nav-TLV pane.)
   /* verilator lint_on WIDTH */
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/calc_viz.tlv'])
\TLV
   $reset = *reset;
   
   // The code starts with 0 and each cycle applies a random binary operation
   // (+, -, *, or /) with a random number 0 - 8 to produce a new value.
   
   // val1 is equal to previous output
   $val1[31:0] = >>1$out;
   // val2 is a random number 0 - 8
   $val2[31:0] = {29'd0, $val2_rand[2:0]};
   $op[1:0] = $op_rand[1:0];

   $sum[31:0] = $val1 + $val2;
   $diff[31:0] = $val1 - $val2;
   $prod[31:0] = $val1 * $val2;
   $quot[31:0] = $val1 / $val2;
   
   $out[31:0] =
      $reset == 1 ? 0 :
      $op == 0 ? $sum :
      $op == 1 ? $diff :
      $op == 2 ? $prod :
      $quot;
   
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
   m4+calc_viz()
\SV
   endmodule

