
`timescale 1ns / 1ps
`include "Defintions.v"


module MiniAlu
(
 input wire Clock,
 input wire Reset,
 output wire [7:0] oLed
);

module ADDER(
 input wire wiSourceDawta1, wiSourceData2, wiSourceData3,
 output wire woCarry, woPartialResult
);
assign {woCarry, woPartialResult}=wiSourceData1 + wiSourceData2 + wiSourceData3;
endmodule

module MULTIPLIER(
input wire [15:0] wA, wB,
output wire [15:0] woResult
); 
wire [3:0] wCarry [2:0];
wire [3:0] wFirstSum;
assign woResult[0] = wA[0]&wB[0]; 
//First level of sums
wire [3:0] wFirstSum;
ADDER bit1FirstSum(wA[1]&wB[0], wA[0]&wB[1], 0, wCarry[0][0], wFirstSum[0]);
ADDER bit2FirstSum(wA[1]&wB[1], wA[0]&wB[2], wCarry[0][0], wCarry[0][1], wFirstSum[1]);
ADDER bit3FirstSum(wA[1]&wB[2], wA[0]&wB[3], wCarry[0][1], wCarry[0][2], wFirstSum[2]);
ADDER bit4FirstSum(wA[1]&wB[3], 0, wCarry[0][2], wCarry[0][3], wFirstSum[3]);

//Second level of sums
wire [3:0] wSndSum;
ADDER bit1SndSum(wA[2]&wB[0], wFirstSum[1], 0, wCarry[1][0], wSndSum[0]);
ADDER bit2SndSum(wA[2]&wB[1], wFirstSum[2], wCarry[1][0], wCarry[1][1], wSndSum[1]);
ADDER bit3SndSum(wA[2]&wB[2], wFirstSum[3], wCarry[1][1], wCarry[1][2], wSndSum[2]);
ADDER bit4SndSum(wA[2]&wB[3], 0, wCarry[1][2], wCarry[1][3], wSndSum[3]);

//Third level of sums
wire [3:0] wTrdSum;
ADDER bit1TrdSum(wA[3]&wB[0], wSndSum[1], 0,  wCarry[2][0], wTrdSum[0]);
ADDER bit2TrdSum(wA[3]&wB[1], wSndSum[2], wCarry[2][0], wCarry[2][1], wTrdSum[1]);
ADDER bit3TrdSum(wA[3]&wB[2], wSndSum[3], wCarry[2][1], wCarry[2][2], wTrdSum[2]);
ADDER bit4TrdSum(wA[3]&wB[3], wCarry[1][3], wCarry[2][2], wCarry[2][3], wTrdSum[3]);

wire [7:0] Zero;
assign Zero = 7'd0;
assign woResult[15:1] = {Zero, wCarry[2][3], wTrdSum, wSndSum[0], wFirstSum[0]};
endmodule

wire [15:0]  wIP,wIP_temp;
reg         rWriteEnable,rBranchTaken, rWriteEnable32;
wire [27:0] wInstruction;
wire [3:0]  wOperation;
reg [15:0] rResult16;
reg [31:0] rResult32;
wire [7:0]  wSourceAddr0,wSourceAddr1,wDestination, wDestinationOld;
wire [15:0] wPreSourceData0,wPreSourceData1;
reg [7:0] rIMULResult;
wire [15:0] wIPInitialValue,wImmediateValue,wResult16Old;
wire [15:0] wSourceData0_16, wSourceData1_16;
wire [31:0] wSourceData0,wSourceData1;
wire [31:0] wPreSourceData0_32, wPreSourceData1_32, wSourceData0_32, wSourceData1_32, wResult32Old;
wire signed[15:0] wsSourceData0,wsSourceData1; 


assign wsSourceData0 = wSourceData0;
assign wsSourceData1 = wSourceData1;


ROM InstructionRom 
(
	.iAddress(      wIP         ),
	.oInstruction( wInstruction )
);

RAM_DUAL_READ_PORT DataRam
(
	.Clock(         Clock        ),
	.iWriteEnable(  rWriteEnable ),
	.iReadAddress0( wInstruction[7:0] ),
	.iReadAddress1( wInstruction[15:8] ),
	.iWriteAddress( wDestination ),
	.iDataIn(       rResult16      ),
	.oDataOut0(     wPreSourceData0 ),
	.oDataOut1(     wPreSourceData1 )
);

RAM_DUAL_READ_PORT_32 DataRam32
(
	.Clock(         Clock        ),
	.iWriteEnable(  rWriteEnable32 ),
	.iReadAddress0( 8'b00000111 & wInstruction[7:0] ),
	.iReadAddress1( 8'b00000111 & wInstruction[15:8] ),
	.iWriteAddress( (8'b00000111 & wDestination)<< 3 ),
	.iDataIn(       rResult32      ),
	.oDataOut0(     wPreSourceData0_32 ),
	.oDataOut1(     wPreSourceData1_32 )
);




assign wIPInitialValue = (Reset) ? 8'b0 : wDestination;
UPCOUNTER_POSEDGE IP
(
.Clock(   Clock                ), 
.Reset(   Reset | rBranchTaken ),
.Initial( wIPInitialValue + 1  ),
.Enable(  1'b1                 ),
.Q(       wIP_temp             )
);
assign wIP = (rBranchTaken) ? wIPInitialValue : wIP_temp;

FFD_POSEDGE_SYNCRONOUS_RESET # ( 4 ) FFD1 
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[27:24]),
	.Q(wOperation)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD2
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[7:0]),
	.Q(wSourceAddr0)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD3
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[15:8]),
	.Q(wSourceAddr1)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD4
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[23:16]),
	.Q(wDestination)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD5
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wDestination),
	.Q(wDestinationOld)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 16 ) FFD6
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(rResult16),
	.Q(wResult16Old)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 32 ) FFD7
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(rResult32),
	.Q(wResult32Old)
);

reg rFFLedEN;
FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FF_LEDS
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable( rFFLedEN ),
	.D( wSourceData1 ),
	.Q( oLed    )
);

assign wImmediateValue = {wSourceAddr1,wSourceAddr0};

assign wSourceData0_16 = (wSourceAddr0 == wDestinationOld) ? wResult16Old : wPreSourceData0;
assign wSourceData1_16 = (wSourceAddr1 == wDestinationOld) ? wResult16Old : wPreSourceData1;

assign wSourceData0_32 = (wSourceAddr0 == wDestinationOld) ? wResult32Old : wPreSourceData0_32;
assign wSourceData1_32 = (wSourceAddr1 == wDestinationOld) ? wResult32Old : wPreSourceData1_32;

assign wSourceData0 = (wSourceAddr0[3] == 1) ? wSourceData0_32 : wSourceData0_16;
assign wSourceData1 = (wSourceAddr1[3] == 1) ? wSourceData1_32 : wSourceData1_16;

always @ ( * )
begin

	case (wOperation)
	//-------------------------------------
	`NOP:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b0;
		rWriteEnable32 <= 1'b0;
		rResult16      <= 0;
		rResult32      <= 0;
	end
	//-------------------------------------
	`ADD:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b1;
		rWriteEnable32 <= 1'b0;
		rResult16      <= wSourceData1 + wSourceData0;
		rResult32      <= 0;
	end
	//-------------------------------------
	`STO:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b1;
		rWriteEnable32 <= 1'b0;
		rResult16      <= wImmediateValue;
		rResult32      <= 0;
	end
	//-------------------------------------
	`BLE:
	begin
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rWriteEnable32 <= 1'b0;
		rResult16      <= 0;
		rResult32      <= 0;
		if (wSourceData1 <= wSourceData0 )
			rBranchTaken <= 1'b1;
		else
			rBranchTaken <= 1'b0;
		
	end
	//-------------------------------------	
	`JMP:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b1;
		rWriteEnable <= 1'b0;
		rWriteEnable32 <= 1'b0;
		rResult16      <= 0;
		rResult32      <= 0;
	end
	//-------------------------------------	
	`LED:
	begin
		rFFLedEN     <= 1'b1;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b0;
		rWriteEnable32 <= 1'b0;
		rResult16      <= 0;
		rResult32      <= 0;
	end
	//-------------------------------------
	`SUB:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b1;
		rWriteEnable32 <= 1'b0;
		rResult16      <= wSourceData1 - wSourceData0;
		rResult32      <= 0;
	end
	//-------------------------------------
	`MUL:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b0;
		rWriteEnable32 <= 1'b1;
		rResult16      <= 0;	//Multiplicacion sin signo
		rResult32      <= wSourceData1 * wSourceData0;
	end
	//-------------------------------------
	`SMUL:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b0;
		rWriteEnable32 <= 1'b1;
		rResult16      <= 0;
		rResult32     <= wsSourceData1 * wsSourceData0;	//Multiplicacion con signo
		
	end
	//-------------------------------------
	`ADD32:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b0;
		rWriteEnable32 <= 1'b1;
		rResult16      <= 0;
		rResult32      <= wSourceData1 + wSourceData0;
	end
	//-------------------------------------
	`SUB32:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b0;
		rWriteEnable32 <= 1'b1;
		rResult16      <= 0;
		rResult32      <= wSourceData1 - wSourceData0;
	end
	//-------------------------------------
	`IMUL:
	begin
	
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b1;
		rWriteEnable32 <= 1'b0;
		rResult16      <= 0;
		MULTIPLIER Imul
		(
		.wA(wSourceData0),
		.wB(wSourceData1),
		.woResult(rResult16)
		);
		
	end	
	//-------------------------------------	
	default:
	begin
		rFFLedEN     <= 1'b1;
		rWriteEnable <= 1'b0;
		rWriteEnable32 <= 1'b0;
		rResult16      <= 0;
		rResult32      <= 0;
		rBranchTaken <= 1'b0;
	end	
	//-------------------------------------	
	endcase	
end


endmodule
