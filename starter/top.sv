`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Montek Singh
// 3/3/2025
//
//////////////////////////////////////////////////////////////////////////////////

`default_nettype none


// NOTE: There should not be any need to modify anything below!!!!
// Any changes to parameters must be made in the tester, from which
// actual parameter values are inherited.


module top #(

// DO NOT CHANGE

    parameter wordsize=32,                              // word size for the processor
    parameter Nreg=32,                                  // number of registers
    parameter imem_size=128,                            // imem size, must be >= # instructions in program
    parameter imem_init="wherever_code_is.mem",         // correct filename inherited from parent/tester
    parameter dmem_size=64,                             // dmem size, must be >= # words in .data of program + size of stack
    parameter dmem_init="wherever_data_is.mem"          // correct filename inherited from parent/tester
)(
    input wire clk, reset, enable
);

// DO NOT CHANGE
   
   wire [wordsize-1:0] pc, instr, mem_readdata, mem_writedata, mem_addr;
   wire mem_wr;

   mips #(.wordsize(wordsize), .Nreg(Nreg)) mips(.*);      // The ".*" construct makes all ports connect to wires with the same names

   rom_module #(.Nloc(imem_size), .Dbits(wordsize), .initfile(imem_init)) imem(.addr(pc[31:2]), .dout(instr));
                // dropped two LSBs from address to instr mem to convert byte address to word address
                
   ram_module #(.Nloc(dmem_size), .Dbits(wordsize), .initfile(dmem_init)) dmem(.clock(clk), .wr(mem_wr), 
        .addr(mem_addr[31:2]), .din(mem_writedata), .dout(mem_readdata));  
                // dropped two LSBs from address to data mem to convert byte address to word address

endmodule
