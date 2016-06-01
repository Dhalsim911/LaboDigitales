`timescale 1ns / 1ps

module VGA_CONTROLLER
(
input wire Clock_25,
input wire Reset,
output wire oHS, oVS, oVmemAddress
);

wire[15:0] wCurrentColumn;
wire[15:0] wCurrentRow;
reg rColumnEnd, rRowEnd;

UPCOUNTER_POSEDGE CurrentCol
(
	.Clock(   Clock_25  ), 
	.Reset(   Reset | rColumnEnd ),
	.Initial( 16'b0 ),
	.Enable(  1'b1  ),
	.Q( wCurrentColumn )
);

UPCOUNTER_POSEDGE CurrentRow
(
	.Clock(   Clock_25  ), 
	.Reset(   Reset | rRowEnd ),
	.Initial( 16'b0 ),
	.Enable( wCurrentColumn > 4'd0639),
	.Q( wCurrentRow )
);

endmodule 