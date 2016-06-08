`timescale 1ns / 1ps
`include "Defintions.v"

module VGA_CONTROLLER
(
input wire [1:0] Clock_25,
input wire Reset,
output wire oHS, oVS, oVmemAddress
);

wire [9:0] wCurrentColumn, wCurrentRow;

UPCOUNTER_POSEDGE #(10) CurrentCol
(
	.Clock(  Clock_25[1]  ), 
	.Reset( (wCurrentColumn > 639) || Reset ),
	.Initial( 16'b0 ),
	.Enable(  1'b1  ),
	.Q( wCurrentColumn )
);

/*UPCOUNTER_POSEDGE # (10) CurrentRow
(
	.Clock(   Clock_25[1]  ), 
	.Reset(   Reset ),
	.Initial( 16'b0 ),
	.Enable( wCurrentColumn > 4'd0639),
	.Q( wCurrentRow )
);*/

endmodule 