`timescale 1ns / 1ps

`define colorCuadros 3'b000 //negro

`define xDerCentral 8'b01000001 // +65
`define yDerCentral 8'b00110000 // +48
`define xDerArrAbaj 8'b01100001 // +97
`define yDerArr 8'b00010000 // +16
`define yDerAbaj 8'b01010000 // +80
`define xDerSuperior 8'b01000001 // +65
`define yDerSuperior 8'b00010000 // -16

`define xIzCentral 8'b00011111 // +31
`define yIzCentral 8'b00110000 // +48
`define xIzArrAbaj 8'b00000000 // +0
`define yIzArr 8'b00010000 // +16
`define yIzAbaj 8'b01010000 // +80
`define xIzSuperior 8'b00011111 // +31
`define yIzSuperior 8'b00010000 // -16

`define xEnArrCentral 8'b00110000 // +48
`define yEnArrCentral 8'b00100001 // -33
`define xEnArrDer 8'b01010000 // +80
`define yEnArrDer 8'b00000001 // -1
`define xEnArrIz 8'b00010000 // +16
`define yEnArrIz 8'b00000001 // -1
`define xEnAbajDer 8'b01010000 // +80
`define yEnAbajDer 8'b00111111 // +63
`define xEnAbajIz 8'b00010000 // +16
`define yEnAbajIz 8'b00111111 // +63

module Detector(
	input wire [15:0] posicionActual,
	input wire Clock,
	//input wire Enable,
	
	input wire iz, der;
	input wire ClockPantalla;
	
	input wire [2:0] estadoLeido,
	output reg [15:0] dirLeerEstado,
	output reg GameOver
	//output reg Control;
);

reg Izquierda, Derecha, Arriba;
wire [4:0] estadoEv;
//reg ResetCounter;

wire [7:0] x;
wire [7:0] y;

wire [15:0] dirInterno;
assign dirLeerEstado = dirInterno;

wire OverInterno;
assign GameOver = OverInterno;

/*wire ControlInterno;
assign Control = ControlInterno;*/

UPCOUNTER_POSEDGE # ( 5 ) EstadoPuntoAEvaluar
(
.Clock(   	Clock              ), 
.Reset(   	1'b0               ), //ResetCounter
.Initial( 	5'b00000       	   ),
.Enable(    1'b1               ),
.Q(       	estadoEv           )
);

always @ (posedge Clock)
begin
	
	case(estadoEv)
	
	/*5'b00000: //inicializo
	begin
		Derecha = 0;
		Izquierda = 0;
		Arriba = 0;
	end*/
	
		//derecha     derecha     derecha     derecha     derecha
	
	5'b00000: //evalúo derecha centro
	begin
		Derecha = 0; //inicializo las variabes
		Izquierda = 0;
		Arriba = 0;
	
		assign x = posicionActual[15:8] + `xDerCentral;
		assign y = posicionActual[7:0] + `yDerCentral;
		dirInterno = {x,y};
	end
	
	5'b00001: 
	begin
		if (estadoLeido == `colorCuadros)
			Derecha = 1;
		else
			Derecha = 0;
	end
	
	5'b00010: //evalúo derecha arriba
	begin
		assign x = posicionActual[15:8] + `xDerArrAbaj;
		assign y = posicionActual[7:0] + `yDerArr;
		dirInterno = {x,y};
	end
	
	5'b00011:
	begin
		if (estadoLeido == `colorCuadros or Derecha == 1)
			Derecha = 1;
		else
			Derecha = 0;
	end
	
	5'b00100: //evalúo derecha abajo
	begin
		assign x = posicionActual[15:8] + `xDerArrAbaj;
		assign y = posicionActual[7:0] + `yDerAbaj;
		dirInterno = {x,y};
	end
	
	5'b00101:
	begin
		if (estadoLeido == `colorCuadros or Derecha == 1)
			Derecha = 1;
		else
			Derecha = 0;
	end
	
	5'b00110: //evalúo derecha superior
	begin
		assign x = posicionActual[15:8] + `xDerSuperior;
		assign y = posicionActual[7:0] - `yDerSuperior;
		dirInterno = {x,y};
	end
	
	5'b00111: 
	begin
		if (estadoLeido == `colorCuadros or Derecha == 1)
			Derecha = 1;
		else
			Derecha = 0;
	end
	
		//izquierda     izquierda     izquierda     izquierda     izquierda
	
	5'b01000: //evalúo izquierda centro
	begin
		assign x = posicionActual[15:8] + `xIzCentral;
		assign y = posicionActual[7:0] + `yIzCentral;
		dirInterno = {x,y};
	end
	
	5'b01001: 
	begin
		if (estadoLeido == `colorCuadros)
			Izquierda = 1;
		else
			Izquierda = 0;
	end
	
	5'b01010: //evalúo izquierda arriba
	begin
		assign x = posicionActual[15:8] + `xIzArrAbaj;
		assign y = posicionActual[7:0] + `yIzArr;
		dirInterno = {x,y};
	end
	
	5'b01011:
	begin
		if (estadoLeido == `colorCuadros or Izquierda == 1)
			Izquierda = 1;
		else
			Izquierda = 0;
	end
	
	5'b01100: //evalúo izquierda abajo
	begin
		assign x = posicionActual[15:8] + `xIzArrAbaj;
		assign y = posicionActual[7:0] + `yIzAbaj;
		dirInterno = {x,y};
	end
	
	5'b01101:
	begin
		if (estadoLeido == `colorCuadros or Izquierda == 1)
			Izquierda = 1;
		else
			Izquierda = 0;
	end
	
	5'b01110: //evalúo izquierda superior
	begin
		assign x = posicionActual[15:8] + `xIzSuperior;
		assign y = posicionActual[7:0] - `yIzSuperior;
		dirInterno = {x,y};
	end
	
	5'b01111: 
	begin
		if (estadoLeido == `colorCuadros or Izquierda == 1)
			Izquierda = 1;
		else
			Izquierda = 0;
	end
	
		//encima     encima     encima     encima     encima
		
	5'b10000: //evalúo encima superior central
	begin
		assign x = posicionActual[15:8] + `xEnArrCentral;
		assign y = posicionActual[7:0] - `yEnArrCentral;
		dirInterno = {x,y};
	end
	
	5'b10001: 
	begin
		if (estadoLeido == `colorCuadros)
			Arriba = 1;
		else
			Arriba = 0;
	end
	
	5'b10010: //evalúo encima superior derecha
	begin
		assign x = posicionActual[15:8] + `xEnArrDer;
		assign y = posicionActual[7:0] - `yEnArrDer;
		dirInterno = {x,y};
	end
	
	5'b10011: 
	begin
		if (estadoLeido == `colorCuadros or Arriba == 1)
			Arriba = 1;
		else
			Arriba = 0;
	end
	
	5'b10100: //evalúo encima superior izquierda
	begin
		assign x = posicionActual[15:8] + `xEnArrIz;
		assign y = posicionActual[7:0] - `yEnArrIz;
		dirInterno = {x,y};
	end
	
	5'b10101: 
	begin
		if (estadoLeido == `colorCuadros or Arriba == 1)
			Arriba = 1;
		else
			Arriba = 0;
	end
	
	5'b10110: //evalúo encima inferior derecha
	begin
		assign x = posicionActual[15:8] + `xEnAbajDer;
		assign y = posicionActual[7:0] + `yEnAbajDer;
		dirInterno = {x,y};
	end
	
	5'b10111: 
	begin
		if (estadoLeido == `colorCuadros or Arriba == 1)
			Arriba = 1;
		else
			Arriba = 0;
	end
	
	5'b11000: //evalúo encima inferior izquierda
	begin
		assign x = posicionActual[15:8] + `xEnAbajIz;
		assign y = posicionActual[7:0] + `yEnAbajIz;
		dirInterno = {x,y};
	end
	
	5'b11001: 
	begin
		if (estadoLeido == `colorCuadros or Arriba == 1)
			Arriba = 1;
		else
			Arriba = 0;
	end
	
	endcase
	
	/*
	//ControlInterno = 1;
	
		//lado derecho
	assign x = posicionActual[15:8] + 8'b00101101; //columna, +45 de pos x original

	assign y = posicionActual[7:0] - 8'b00101101; //fila, inicialmente -45 de pos y original
	reg [7:0] i;
	reg [7:0] ifinal = y + 8'b01011010; // +90
	for(i=y; i<ifinal; i=i+8'b1)
	begin
		dirInterno = {x,i};
	end
	
		//lado izquierdo
	assign x = posicionActual[15:8] - 8'b00101101; //columna, -45 de pos x original

	assign y = posicionActual[7:0] - 8'b00101101; //fila, inicialmente -45 de pos y original
	reg [7:0] i;
	reg [7:0] ifinal = y + 8'b01011010; // +90
	for(i=y; i<ifinal; i=i+8'b1)
	begin
		dirInterno = {x,i};
	end
	
		//encima
	assign y = posicionActual[7:0] - 8'b00101101; //fila, -45 de pos y original
	
	assign x = posicionActual[15:8] - 8'b00101101; //columna, inicialmente -45 de pos x original
	reg [7:0] i;
	reg [7:0] ifinal = x + 8'b01011010; // +90
	for(i=x; i<ifinal; i=i+8'b1)
	begin
		dirInterno = {i,y};
	end*/
end

always @ (posedge der)
begin
	if (Derecha) //if (Derecha or OverInterno)
		OverInterno = 1'b1;
	else
		OverInterno = 1'b0;
end

always @ (posedge iz)
begin
	if (Izquierda) //if (Izquierda or OverInterno)
		OverInterno = 1'b1;
	else
		OverInterno = 1'b0;
end

always @ (posedge ClockPantalla)
begin
	if (Arriba) //if (Arriba or OverInterno)
		OverInterno = 1'b1;
	else
		OverInterno = 1'b0;
end

/*
always @ (*)
begin
	if (Derecha and posedge der) //esto no es así
	begin
		if (estadoLeido == 3'b000)
			OverInterno = 1'b1;
		else
			OverInterno = 1'b0;
	end
	else
		OverInterno = 1'b0;
end*/

endmodule