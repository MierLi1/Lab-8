`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 03:22:47 PM
// Design Name: 
// Module Name: datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module datapath #(
    parameter Nreg = 32,
    parameter Dbits = 32
)(
    input wire clk, reset, enable,
    output logic [Dbits-1:0] pc = 32'h0040_0000,
    input wire [Dbits-1:0] instr,
    input wire [1:0] pcsel, wasel, wdsel,
    input wire sgnext, bsel, werf,
    input wire [1:0] asel,
    input wire [4:0] alufn,
    output wire Z,
    output wire [Dbits-1:0] mem_addr,
    output wire [Dbits-1:0] mem_writedata,
    input wire [Dbits-1:0] mem_readdata
);

    wire [Dbits-1:0] ReadData1, ReadData2;
    wire [Dbits-1:0] aluA, aluB, alu_result;
    wire [Dbits-1:0] signImm, write_data;
    wire [4:0] write_reg;
    
    assign signImm = sgnext ? {{16{instr[15]}}, instr[15:0]} : {{16{1'b0}}, instr[15:0]};
    
    register_file #(.Nloc(Nreg), .Dbits(Dbits)) rf (
        .clock(clk),
        .wr(werf),
        .ReadAddr1(instr[25:21]), // rs
        .ReadAddr2(instr[20:16]), // rt
        .WriteAddr(write_reg),
        .WriteData(write_data),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );
    assign aluA = (asel == 2'b00) ? ReadData1 : // Register value (default)
                        (asel == 2'b01) ? {{(Dbits-5){1'b0}}, instr[10:6]} :        // Use PC for jumps/branches
                        (asel == 2'b10) ? 32'h 00000010:        // Use 0 (for some special cases)
                        ReadData1; // Default
    assign aluB = bsel ? signImm : ReadData2;
    
    ALU #(.N(Dbits)) alu(
        .A(aluA),
        .B(aluB),
        .ALUfn(alufn),
        .R(alu_result),
        .FlagZ(Z)
    );
    
    assign write_data = (wdsel == 2'b01) ? alu_result :
                        (wdsel == 2'b10) ? mem_readdata :
                        (wdsel == 2'b00) ? pc + 4 : 0;

    assign write_reg = (wasel == 2'b00) ? instr[15:11] :  // R-type (rd)
                       (wasel == 2'b01) ? instr[20:16] :  // I-type (rt)
                       5'd31; // J-type (jal, writes to $ra)


    assign mem_addr = alu_result;
    assign mem_writedata = ReadData2;


    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'h0040_0000;
        else if (enable) begin
            case (pcsel)
                2'b00: pc <= pc + 4; 
                2'b01: pc <= pc + (signImm << 2) + 4;
                2'b10: pc <= {pc[31:28], instr[25:0], 2'b00};
                2'b11: pc <= ReadData1;
            endcase
        end
    end

endmodule
