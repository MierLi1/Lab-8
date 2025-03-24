`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/22/2025 04:43:48 PM
// Design Name: 
// Module Name: ALU
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


`default_nettype none
module ALU #(parameter N=32) (
    input wire [N-1:0] A, B,
    output wire [N-1:0] R,
    input wire [4:0] ALUfn,
    output wire FlagZ
);
    wire FlagN, FlagC, FlagV;
    wire subtract, bool1, bool0, shft, math;
    assign {subtract, bool1, bool0, shft, math} = ALUfn[4:0]; 

    wire [N-1:0] addsubResult, shiftResult, logicalResult;
    wire compResult;

    addsub #(N) AS(.A(A), .B(B), .Subtract(subtract), .Result(addsubResult), .FlagN, .FlagC, .FlagV);
    shifter #(N) S(.IN(B), .shamt(A[$clog2(N)-1:0]), .left(~bool1), .logical(~bool0), .OUT(shiftResult));    
    logical #(N) L(.A, .B, .op({bool1, bool0}), .R(logicalResult)); 
    comparator C(.FlagN, .FlagV, .FlagC, .bool0, .comparison(compResult));

    assign R = (~shft & math) ? addsubResult : 
               (shft & ~math) ? shiftResult : 
               (~shft & ~math) ? logicalResult : 
               {{(N-1){1'b0}}, compResult};

    assign FlagZ = ~|R; 

endmodule

