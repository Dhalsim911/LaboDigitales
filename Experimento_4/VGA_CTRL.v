`timescale 1ns / 1ps

module VGA_controller
(
	input wire				Clock_lento,
	input wire 				Reset,
	//input wire	[2:0]		iVGA_RGB,
	//input wire  [2:0]		iColorCuadro,
	//input wire  [7:0]		iXRedCounter,
	//input wire  [7:0]		iYRedCounter,
	output wire	[2:0]		oVGA_RGB,
	output wire				oHsync,
	output wire				oVsync,
	output wire [9:0]		oVcounter,
	output wire [9:0]		oHcounter
);
//wire iVGA_R, iVGA_G, iVGA_B;
wire oVGA_R, oVGA_G, oVGA_B;
//wire wEndline;
//wire [3:0] wMarco; //, wCuadro;
//wire [2:0] wVGAOutputSelection;

assign wMarco = 3'b0;
//assign wCuadro = 3'b100;
//assign wVGAOutputSelection = ( ((oHcounter >= iXRedCounter + 10'd240) && (oHcounter <= iXRedCounter + 10'd240 + 10'd32)) &&
//										 ((oVcounter >= iYRedCounter + 10'd141) && (oVcounter <= iYRedCounter + 10'd141 + 8'd32))) ?
//										iColorCuadro : {iVGA_R, iVGA_G, iVGA_B};

//assign iVGA_R = iVGA_RGB[2];
//assign iVGA_G = iVGA_RGB[1];
//assign iVGA_B = iVGA_RGB[0];
assign oVGA_RGB = {oVGA_R, oVGA_G, oVGA_B};

assign oHsync = (oHcounter < 704) ? 1'b1 : 1'b0;
assign wEndline = (oHcounter == 799);
assign oVsync = (oVcounter < 519) ? 1'b1 : 1'b0;

// Marco negro e imagen de 256*256
assign {oVGA_R, oVGA_G, oVGA_B} = (oVcounter < 119 || oVcounter >= 419 || 
					  oHcounter < 218 || oHcounter > 518) ? 
					  wMarco : 3'b010; //wVGAOutputSelection;

UPCOUNTER_POSEDGE # (10) HORIZONTAL_COUNTER
(
.Clock	(   Clock_lento   ), 
.Reset	( (oHcounter > 799) || Reset 		),
.Initial	( 10'b0  			),
.Enable	(  1'b1				),
.Q			(	oHcounter      )
);

UPCOUNTER_POSEDGE # (10) VERTICAL_COUNTER
(
.Clock	( Clock_lento    ), 
.Reset	( (oVcounter > 520) || Reset ),
.Initial	( 10'b0  			),	
.Enable	( wEndline            ),
.Q			( oVcounter      )
);

endmodule