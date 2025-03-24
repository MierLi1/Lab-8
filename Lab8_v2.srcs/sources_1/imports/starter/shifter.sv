`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/22/2025 04:22:22 PM
// Design Name: 
// Module Name: shifter
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
module shifter #(parameter N = 32)(
    input wire signed [N-1:0] IN,
    input wire [$clog2(N)-1:0]shamt,
    input wire left, logical,
    output wire [N-1:0] OUT
    );
    
    assign OUT = left ? (IN << shamt):(logical ? IN >> shamt: IN >>> shamt);
    
endmodule
