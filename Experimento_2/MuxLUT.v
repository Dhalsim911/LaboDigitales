`timescale 1ns / 1ps
`include "Defintions.v"

module MULT_LUT_2_BITS
(
input wire [15:0] iDato_A , 
input wire [1:0] iDato_B , 
output reg [31:0] oResult_Mux 
);

always @ ( * )
begin
	case (iDato_B)
	0: oResult_Mux = 0 ; 
	1: oResult_Mux = iDato_A; 
	2: oResult_Mux = iDato_A << 1; 
	3: oResult_Mux = (iDato_A << 1) + iDato_A; 
	endcase	
end
	
endmodule

module MULT_LUT_4_BITS
(
	wire [31:0] wBits_down,wBits_up,
	input wire [15:0] iDato_A , 
	input wire [3:0] iDato_B , 
	output wire [31:0] oResult_Mux 
);

	MULT_LUT_2_BITS Bits_down
	(
		.iDato_A( iDato_A ),
		.iDato_B( iDato_B[1:0]),
		.oResult_Mux( wBits_down )
	);

	MULT_LUT_2_BITS Bits_up
	(
		.iDato_A( iDato_A ),
		.iDato_B( iDato_B[3:2]),
		.oResult_Mux( wBits_up )
	);

	assign oResult_Mux = wBits_down + ( wBits_up << 2 );

endmodule

module MULT_LUT_8_BITS
(
	wire [31:0] wBits_down,wBits_up,
	input wire [15:0] iDato_A , 
	input wire [7:0] iDato_B , 
	output wire [31:0] oResult_Mux 
);

	MULT_LUT_4_BITS Bits_down
	(
		.iDato_A( iDato_A ),
		.iDato_B( iDato_B[3:0]),
		.oResult_Mux( wBits_down )
	);

	MULT_LUT_4_BITS Bits_up
	(
		.iDato_A( iDato_A ),
		.iDato_B( iDato_B[7:4]),
		.oResult_Mux( wBits_up )
	);

	assign oResult_Mux = wBits_down + ( wBits_up << 4 );

endmodule

module MULT_LUT_16_BITS
(
	wire [31:0] wBits_down,wBits_up,
	input wire [15:0] iDato_A , 
	input wire [15:0] iDato_B , 
	output wire [31:0] oResult_Mux 
);

	MULT_LUT_8_BITS Bits_down
	(
		.iDato_A( iDato_A ),
		.iDato_B( iDato_B[7:0]),
		.oResult_Mux( wBits_down )
	);

	MULT_LUT_8_BITS Bits_up
	(
		.iDato_A( iDato_A ),
		.iDato_B( iDato_B[15:8]),
		.oResult_Mux( wBits_up )
	);

	assign oResult_Mux = wBits_down +(wBits_up << 8);

endmodule
