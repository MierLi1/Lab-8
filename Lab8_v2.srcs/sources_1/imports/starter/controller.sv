`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Montek Singh
// 3/3/2025
//
//////////////////////////////////////////////////////////////////////////////////

`default_nettype none

// These are non-R-type.
// OPCODES defined here:

`define LW     6'b 100011
`define SW     6'b 101011

`define ADDI   6'b 001000
`define ADDIU  6'b 001001     // NOTE:  addiu *does* sign-extend the imm
`define SLTI   6'b 001010
`define SLTIU  6'b 001011
`define ORI    6'b 001101
`define LUI    6'b 001111
`define ANDI   6'b 001100
`define XORI   6'b 001110

`define BEQ    6'b 000100
`define BNE    6'b 000101
`define J      6'b 000010
`define JAL    6'b 000011


// These are all R-type, i.e., OPCODE=0.
// FUNC field defined here:

`define ADD    6'b 100000
`define ADDU   6'b 100001
`define SUB    6'b 100010
`define AND    6'b 100100
`define OR     6'b 100101
`define XOR    6'b 100110
`define NOR    6'b 100111
`define SLT    6'b 101010
`define SLTU   6'b 101011
`define SLL    6'b 000000
`define SLLV   6'b 000100
`define SRL    6'b 000010
`define SRLV   6'b 000110
`define SRA    6'b 000011
`define SRAV   6'b 000111
`define JR     6'b 001000
`define JALR   6'b 001001


module controller(

// DO NOT CHANGE inputs and outputs

   input  wire enable,
   input  wire [5:0] op, 
   input  wire [5:0] func,
   input  wire Z,
   output wire [1:0] pcsel,
   output wire [1:0] wasel, 
   output wire sgnext,
   output wire bsel,
   output wire [1:0] wdsel, 
   output logic [4:0] alufn,      // will become wire because updated in always_comb
   output wire wr,
   output wire werf, 
   output wire [1:0] asel
   ); 

// CHANGE below by filling in the missing pieces 


  assign pcsel = ((op == 6'b0) & (func == `JR | func == `JALR)) ?  2'b11 // controls 4-way multiplexer
               : (((op == `J) | (op == `JAL))) ? 2'b10
               : ((((op == `BEQ) & (Z == 1)) | ((op == `BNE)) & (Z == 0 ))) ? 2'b01                                     // for beq/bne check Z flag!
               : 2'b00;

  logic [9:0] controls;                // will become wires because of always_comb
  wire _werf_, _wr_;                   // need to be ANDed with enable (to freeze processor)
  assign werf = _werf_ & enable;       // turn off register writes when processor is disabled
  assign wr = _wr_ & enable;           // turn off memory writes when processor is disabled
 
  assign {_werf_, wdsel[1:0], wasel[1:0], asel[1:0], bsel, sgnext, _wr_} = controls[9:0];

  always_comb
     case(op)                                     // non-R-type instructions
        `LW: controls <= 10'b 1_10_01_00_1_1_0;     // LW
        `SW: controls <= 10'b 0_01_01_00_1_1_1;                        // SW
      `ADDI,                                        // ADDI
     `ADDIU,                                        // ADDIU
      `SLTI: controls <= 10'b 1_01_01_00_1_1_0;     // SLTI
     `SLTIU: controls <= 10'b 1_01_01_00_1_1_0;
       `ORI: controls <= 10'b 1_01_01_00_1_0_0;
       `LUI: controls <= 10'b 1_01_01_10_1_1_0;  
       `ANDI: controls <= 10'b 1_01_01_00_1_0_0;    
       `XORI: controls <= 10'b 1_01_01_00_1_0_0;
       `BEQ: controls <= 10'b 0_xx_xx_00_0_1_0;  
       `BNE: controls <= 10'b 0_xx_xx_00_0_1_0;  
       `J: controls <= 10'b 0_xx_xx_xx_x_x_0;
       `JAL: controls <= 10'b 1_00_10_xx_x_x_0;             // ORI
       // add remaining non-R-type instructions here
      6'b000000:                                    
         case(func)                              // R-type
             `ADD,
            `ADDU: controls <= 10'b 1_01_00_00_0_x_0; // ADD and ADDU
             `SUB: controls <= 10'b 1_01_00_00_0_x_0; // SUB
             `AND: controls <= 10'b 1_01_00_00_0_x_0;
             `OR : controls <= 10'b 1_01_00_00_0_x_0;
             `XOR: controls <= 10'b 1_01_00_00_0_x_0;
             `NOR: controls <= 10'b 1_01_00_00_0_x_0;
             `SLT: controls <= 10'b 1_01_00_00_0_0_0;
             `SLTU: controls <= 10'b 1_01_00_00_0_0_0;
             `SLL: controls <= 10'b 1_01_00_01_0_1_0;
             `SLLV: controls <= 10'b 1_01_00_00_0_x_0;
             `SRL: controls <= 10'b 1_01_00_01_0_1_0;
             `SRLV: controls <= 10'b 1_01_00_00_0_x_0;
             `SRA: controls <= 10'b 1_01_00_01_0_1_0;
             `SRAV: controls <= 10'b 1_01_00_00_0_x_0;
             `JR: controls <= 10'b 0_xx_xx_xx_x_x_0;
             `JALR: controls <= 10'b 1_00_00_xx_x_x_0;
             
             
             // add remaining R-type instructions here
            default:   controls <= 10'b 0_xx_xx_xx_x_x_0; // unknown instruction, turn off register and memory writes
         endcase
      default: controls <= 10'b 0_xx_xx_xx_x_x_0;         // unknown instruction, turn off register and memory writes
    endcase
    

  always_comb
    case(op)                        // non-R-type instructions
        `LW,                          // LW
        `SW,                          // SW
      `ADDI,                          // ADDI
     `ADDIU: alufn <= 5'b 0xx01;      // ADDIU
      `SLTI: alufn <= 5'b 1x011;      // SLTI
      `SLTIU: alufn <= 5'b 1x111;
       `BEQ,                          // BEQ
       `BNE: alufn <= 5'b 1xx01;             // BNE
       `ORI: alufn <= 5'b x0100;
       `LUI: alufn <= 5'b x0010;
       `ANDI: alufn <= 5'b x0000; 
       `XORI: alufn <= 5'b x1000;
       `J: alufn <= 5'b xxxxx;
       `JAL: alufn <= 5'b xxxxx;
       // add remaining non-R-type instructions here
      6'b000000:                      
         case(func)                 // R-type
             `ADD: alufn <= 5'b 0xx01;
            `ADDU: alufn <= 5'b 0xx01; // ADD and ADDU
             `SUB: alufn <= 5'b 1xx01; // SUB
             `AND: alufn <= 5'b x0000;
             `OR: alufn <= 5'b x0100;
             `XOR: alufn <= 5'b x1000;
             `NOR: alufn <= 5'b x1100;
             `SLT: alufn <= 5'b 1x011;
             `SLTU: alufn <= 5'b 1x111;
             `SLL: alufn <= 5'b x0010;
             `SLLV: alufn <= 5'b x0010;
             `SRL: alufn <= 5'b x1010;
             `SRLV: alufn <= 5'b x1010;
             `SRA: alufn <= 5'b x1110;
             `SRAV: alufn <= 5'b x1110; 
             `JR: alufn <= 5'b xxxxx;
             `JALR: alufn <= 5'b xxxxx;
             // add remaining R-type instructions here
            default:   alufn <= 5'b xxxxx; // unknown func
         endcase
      default: alufn <= 5'b xxxxx;         // for all other instructions, alufn is a don't-care.
    endcase
    
endmodule