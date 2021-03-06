//Mauricio José Valverde Monge A76674
//Francisco Andrés Vargas Piedra A76821
//MiniAlu.v Modificado para Laboratorio de Circuitos Digitales I

`timescale 1ns / 1ps
`include "Defintions.v"

module MiniAlu
(
 input wire Clock,
 input wire Reset,
 input wire PS2_CLK,
 input wire PS2_DATA,
 output wire VGA_RED, VGA_GREEN, VGA_BLUE, 
 output wire VGA_HSYNC,
 output wire VGA_VSYNC
);

wire [15:0] wIP,wIP_temp; //Wires de 16 bits para Dirección
reg         rWriteEnable,rBranchTaken; //Registros de 1 bit
wire [27:0] wInstruction;  /*Wire de 28 bits para instrucciones. Conecta al registro de Module_ROM*/									
wire [3:0]  wOperation;    
reg [15:0]  rResult;
wire [7:0]  wSourceAddr0,wSourceAddr1,wDestination;
wire [15:0] wSourceData0,wSourceData1,wIPInitialValue,wImmediateValue;

reg rVGAWriteEnable;
wire wVGA_R, wVGA_G, wVGA_B, wAleatorio;

wire [9:0] wH_counter,wV_counter;
wire [7:0] wH_read, wV_read;
assign wH_read = (wH_counter >= 240 && wH_counter <= 496) ? (wH_counter - 240) : 8'd0;
assign wV_read = (wV_counter >= 141 && wV_counter <= 397) ? (wV_counter - 141) : 8'd0;

reg rRetCall;
reg [7:0] rDirectionBuffer;
wire [7:0] wRetCall;
wire [7:0] wXRedCounter, wYRedCounter;
wire [3:0] HolyCow;

// Definición del clock de 25 MHz
wire Clock_lento; // Clock con frecuencia de 25 MHz

// Se crea una entrada de reset especial 
// para el clock lento, ya que se quiere
// que se inicie desde el puro inicio.
reg rflag;
reg Reset_clock;
always @ (posedge Clock)
begin
	if (rflag) begin
		Reset_clock <= 0;
	end
	else begin
		Reset_clock <= 1;
		rflag <= 1;
	end
end

LFSR aleatorio
(
.Clock (Clock),
.Reset (Reset),
.rAleatorio(wAleatorio)
);


// Instancia para crear el clock lento 
wire wClock_counter;
assign Clock_lento = wClock_counter;
UPCOUNTER_POSEDGE # ( 1 ) Slow_clock
(
.Clock(   Clock                ), 
.Reset(   Reset_clock ),
.Initial( 1'd0 ), 
.Enable(  1'b1                 ),
.Q(       wClock_counter             )
);
// Fin de la implementación del reloj lento 

// Instancia del controlador de VGA
VGA_controller VGA_controlador
(
	.Clock_lento(Clock_lento),
	.Reset(Reset),
	.iXRedCounter(wXRedCounter),
	.iYRedCounter(wYRedCounter),
	.iVGA_RGB({wVGA_R,wVGA_G,wVGA_B}),
	.iColorCuadro(HolyCow),
	.oVGA_RGB({VGA_RED, VGA_GREEN, VGA_BLUE}),
	.oHsync(VGA_HSYNC),
	.oVsync(VGA_VSYNC),
	.oVcounter(wV_counter),
	.oHcounter(wH_counter)
);
reg [7:0] Filter;
reg FClock;
always @ (posedge Clock_lento) begin
	Filter <= {PS2_CLK, Filter[7:1]};
	if (Filter == 8'hFF) FClock = 1'b1;
	if (Filter == 8'd0) FClock = 1'b0;
end

reg [7:0] FilterData;
reg FData;
always @ (posedge Clock_lento) begin
	FilterData <= {PS2_DATA, FilterData[7:1]};
	if (FilterData == 8'hFF) FData = 1'b1;
	if (FilterData == 8'd0) FData = 1'b0;
end


PS2_Controller PS2_Controller
(
	.Reset(Reset),
	.PS2_CLK(FClock),
	.PS2_DATA(FData),
	.ColorReg(HolyCow),
	.XRedCounter(wXRedCounter),
	.YRedCounter(wYRedCounter)
);

ROM InstructionRom 
(
	.iAddress(     wIP          ),
	.oInstruction( wInstruction )
);

// Instancia RAM de instrucciones y registros
RAM_DUAL_READ_PORT # (16, 3, 8) DataRam
(
	.Clock(         Clock        ),
	.iWriteEnable(  rWriteEnable ),
	.iReadAddress0( wInstruction[7:0] ),
	.iReadAddress1( wInstruction[15:8] ),
	.iWriteAddress( wDestination ),
	.iDataIn(       rResult      ),
	.oDataOut0(     wSourceData0 ),
	.oDataOut1(     wSourceData1 )
);

// Instancia RAM para contenido de pantalla
RAM_SINGLE_READ_PORT # (3,16,65535) VideoMemory
(
	.Clock(Clock),
	.iWriteEnable( rVGAWriteEnable ),
	.iReadAddress( {wH_read,wV_read} ), // Columna, fila
	.iWriteAddress( {wSourceData1[7:0],wSourceData0[7:0]} ), // Columna, fila
	.iDataIn(wDestination[2:0]),
	.oDataOut( {wVGA_R,wVGA_G,wVGA_B} )
);

always @ (posedge Clock)
begin
	if (wOperation == `CALL)
		rDirectionBuffer <= wIP_temp;
end

assign wIP = (rBranchTaken) ? wIPInitialValue : wIP_temp;
assign wIPInitialValue = (Reset) ? 8'b0 : wRetCall;
assign wRetCall = (rRetCall) ? rDirectionBuffer : wDestination;

UPCOUNTER_POSEDGE IP
(
.Clock(   Clock                ), 
.Reset(   Reset | rBranchTaken ),
.Initial( wIPInitialValue + 16'b1  ),
.Enable(  1'b1                 ),
.Q(       wIP_temp             )
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 4 ) FFD1 //FFs de Instrucción
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[27:24]),
	.Q(wOperation)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD2 //FFs de Source2
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[7:0]),
	.Q(wSourceAddr0)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD3 //FFs de Source1
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[15:8]),
	.Q(wSourceAddr1)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD4 //FFs de Destino
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[23:16]),
	.Q(wDestination)
);

assign wImmediateValue = {wSourceAddr1,wSourceAddr0};
	
always @ ( * )
begin
	case (wOperation)
	//-------------------------------------
	`BGE:
	begin
		rVGAWriteEnable <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rRetCall <= 1'b0;
		if (wSourceData1 >= wSourceData0 )
			rBranchTaken <= 1'b1;
		else
			rBranchTaken <= 1'b0;
	end
	//-------------------------------------
	`BLE:
	begin
		rVGAWriteEnable <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rRetCall <= 1'b0;
		if (wSourceData1 <= wSourceData0 )
			rBranchTaken <= 1'b1;
		else
			rBranchTaken <= 1'b0;
	end
	//-------------------------------------
	`JMP:
	begin
		rVGAWriteEnable <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rBranchTaken <= 1'b1;
		rRetCall <= 1'b0;
	end
	//-------------------------------------	
	`NOP:
	begin
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rVGAWriteEnable <= 1'b0;
		rRetCall <= 1'b0;
	end
	//-------------------------------------
	`STO:
	begin
		rWriteEnable <= 1'b1;
		rBranchTaken <= 1'b0;
		rResult      <= wImmediateValue;
		rVGAWriteEnable <= 1'b0;
		rRetCall <= 1'b0;
	end
	//-------------------------------------
	// Instrucción de sumar 1
	`INC:
	begin
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b1;
		rResult      <= wSourceData1 + 1;
		rVGAWriteEnable <= 1'b0;
		rRetCall <= 1'b0;
	end
	//-------------------------------------
		`ADD:
	begin
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b1;
		rResult      <= wSourceData1 + wSourceData0;
		rVGAWriteEnable <= 1'b0;
		rRetCall <= 1'b0;
	end
		//--------------------------------------
		`CALL:	//Nuevo
	begin
		rVGAWriteEnable <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rBranchTaken <= 1'b1;
		rRetCall <= 1'b0;
	end
	//--------------------------------------
		`RET:		//Nuevo
	begin
		rVGAWriteEnable <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rBranchTaken <= 1'b1;
		rRetCall <= 1'b1;
	end
	//-------------------------------------
	// Instrucción para escribir pixel a una posición específica	
	`VGA:
	begin
		rWriteEnable <= 1'b0;
		rBranchTaken <= 1'b0;
		rResult      <= 16'b0;
		rVGAWriteEnable <= 1'b1;
		rRetCall <= 1'b0;
	end
	//-------------------------------------
	default:
	begin
		rWriteEnable <= 1'b0;
		rResult      <= 16'b0;
		rBranchTaken <= 1'b0;
		rVGAWriteEnable <= 1'b0;
		rRetCall <= 1'b0;
	end	
	//-------------------------------------	
	endcase	
end

endmodule
