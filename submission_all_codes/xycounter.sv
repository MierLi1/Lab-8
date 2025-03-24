`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2025 05:06:17 PM
// Design Name: 
// Module Name: xycounter
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


`timescale 1ns/1ps
`default_nettype none

module xycounter #(parameter width = 2, parameter height = 2  ) (
    input wire clock,
    input wire enable,    
    output logic [$clog2(width)-1:0] x = 0,  
    output logic [$clog2(height)-1:0] y = 0 
);

    always_ff @(posedge clock) begin
        if (enable) begin
            if (x == width - 1) begin
                x <= 0; 
                if (y == height - 1) begin
                    y <= 0; 
                end else begin
                    y <= y + 1; 
                end
            end else begin
                x <= x + 1; 
            end
        end
    end
endmodule
