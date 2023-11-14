\m4_TLV_version 1d: tl-x.org
\SV
   // This code can be found in: https://github.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/risc-v_shell.tlv
   
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv'])



   //---------------------------------------------------------------------------------
   // /====================\
   // | Sum 1 to 9 Program |
   // \====================/
   //
   // Program to test RV32I
   // Add 1,2,3,...,9 (in that order).
   //
   // Regs:
   //  x12 (a2): 10
   //  x13 (a3): 1..10
   //  x14 (a4): Sum
   // 
   m4_asm(ADDI, x14, x0, 0)             // Initialize sum register a4 with 0
   m4_asm(ADDI, x12, x0, 1010)          // Store count of 10 in register a2.
   m4_asm(ADDI, x13, x0, 1)             // Initialize loop count register a3 with 0
   // Loop:
   m4_asm(ADD, x14, x13, x14)           // Incremental summation
   m4_asm(ADDI, x13, x13, 1)            // Increment loop count by 1
   m4_asm(BLT, x13, x12, 1111111111000) // If a3 is less than a2, branch to label named <loop>
   // Test result value in x14, and set x31 to reflect pass/fail.
   m4_asm(ADDI, x30, x14, 111111010100) // Subtract expected value of 44 to set x30 to 1 if and only iff the result is 45 (1 + 2 + ... + 9).
   m4_asm(BGE, x0, x0, 0) // Done. Jump to itself (infinite loop). (Up to 20-bit signed immediate plus implicit 0 bit (unlike JALR) provides byte address; last immediate bit should also be 0)
   m4_asm_end()
   m4_define(['M4_MAX_CYC'], 50)
   //---------------------------------------------------------------------------------
            
 	`define BYTE 4;
\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
   /* verilator lint_on WIDTH */
\TLV
   
   $reset = *reset;
   
   // Program counter
   $pc[31:0] = >>1$next_pc;
   $next_pc[31:0] = $reset ? 0 : $pc + `BYTE;
   
   // Load instruction
   `READONLY_MEM($pc, $$instr[31:0]);
   
   // Decode instruction
   $opcode[6:0] = $instr[6:0];
   $is_u_instr = $opcode ==? 7'b0x_101_11;
   $is_i_instr = $opcode ==? 7'b00_x0x_11 ||
                 $opcode == 7'b11_001_11;
   $is_r_instr = $opcode == 7'b01_011_11 ||
                 $opcode == 7'b01_100_11 ||
                 $opcode == 7'b01_110_11 ||
                 $opcode == 7'b10_100_11;
   $is_s_instr = $opcode ==? 7'b01_00x_11;
   $is_b_instr = $opcode == 7'b11_000_11;
   $is_j_instr = $opcode == 7'b11_011_11;
   
   $rs1[4:0] = $instr[19:15];
   $rs2[4:0] = $instr[24:20];
   $rd[4:0] = $instr[11:7];
   $funct3[2:0] = $instr[14:12];
   $imm[31:0] =
      $is_i_instr ? {{21{$instr[31]}}, $instr[30:20]} :
      $is_s_instr ? {{21{$instr[31]}}, $instr[30:25], $instr[11:7]} :
      $is_b_instr ? {{20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0} :
      $is_u_instr ? {$instr[31:12], 12'b0} :
      $is_j_instr ? {{12{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:21], 1'b0} :
      32'b0;  // Default
   
   $rs1_valid = $is_r_type || $is_i_type || $is_s_type || $is_b_type;
   $rs2_valid = $is_r_type || $is_s_type || $is_b_type;
   $rd_valid = $is_r_type || $is_i_type || $is_u_type || $is_j_type;
   $funct3_valid = $is_r_type || $is_i_type || $is_s_type || $is_b_type;
   $imm_valid = $is_i_type || $is_s_type || $is_b_type || $is_u_type || $is_j_type;
   
   $dec_bits[10:0] = {$instr[30], $funct3, $opcode};
   $is_beq = $dec_bits ==? 11'bx_000_1100011;
   $is_bne = $dec_bits ==? 11'bx_001_1100011;
   $is_blt = $dec_bits ==? 11'bx_100_1100011;
   $is_bge = $dec_bits ==? 11'bx_101_1100011;
   $is_bltu = $dec_bits ==? 11'bx_110_1100011;
   $is_bgeu = $dec_bits ==? 11'bx_111_1100011;
   $is_addi = $dec_bits ==? 11'bx_000_0010011;
   $is_add = $dec_bits ==? 11'b0_000_0110011;
   
   // ALU
   $result[31:0] = 
      $is_addi ? $src1_value + $imm :
      $is_add ? $src1_value + $src2_value :
      32'b0;
   
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = 1'b0;
   *failed = *cyc_cnt > M4_MAX_CYC;
   
   m4+rf(32, 32, $reset, $rd_valid, $rd, $result, $rs1_valid, $rs1, $src1_value, $rs2_valid, $rs2, $src2_value)
   //m4+dmem(32, 32, $reset, $addr[4:0], $wr_en, $wr_data[31:0], $rd_en, $rd_data)
   m4+cpu_viz()
\SV
   endmodule
