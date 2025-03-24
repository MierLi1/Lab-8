`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/22/2025 03:28:29 PM
// Design Name: 
// Module Name: addsub
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

module addsub #(parameter N = 32)(
    input wire [N-1:0] A, B,
    input wire Subtract,
    output wire [N-1:0] Result,
    output wire FlagN, FlagC, FlagV
    );
    wire [N-1:0] ToBornottoB = {N{Subtract}} ^ B;
    adder #(N) add(.A(A), .B(ToBornottoB), .Cin(Subtract), .Sum(Result), .FlagN, .FlagC, .FlagV);
    
endmodule
