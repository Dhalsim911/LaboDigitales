`timescale 1ns / 1ps
//------------------------------------------------
module UPCOUNTER_POSEDGE # (parameter SIZE=16)
(
input wire Clock, Reset,
input wire [SIZE-1:0] Initial,
input wire Enable,
output reg [SIZE-1:0] Q
);


  always @(posedge Clock )
  begin
      if (Reset)
        Q = Initial;
      else
		begin
		if (Enable)
			Q = Q + 1;
			
		end			
  end

endmodule
//----------------------------------------------------
module FFD_POSEDGE_SYNCRONOUS_RESET # ( parameter SIZE=8 )
(
	input wire				Clock,
	input wire				Reset,
	input wire				Enable,
	input wire [SIZE-1:0]	D,
	output reg [SIZE-1:0]	Q
);
	

always @ (posedge Clock) 
begin
	if ( Reset )
		Q <= 0;
	else
	begin	
		if (Enable) 
			Q <= D; 
	end	
 
end//always

endmodule


//----------------------------------------------------------------------

module FULL_ADDER # ( parameter SIZE=8 )
(
	input wire				Ci,
	input wire [SIZE-1:0]	A,
	input wire [SIZE-1:0]	B,
	output wire [SIZE-1:0]	SUM,
	output wire 		Co
);
	
assign {Co,SUM} = A + B + Ci;
/*always @ (*) 
begin
		{Co,SUM} <= A + B + Ci; 
	 
end//always*/

endmodule


//----------------------------------------------------------------------


module IMUL_GENE # ( parameter size=16 )
(
	//input wire				Clock,
	input wire [size-1:0]	MulA,
	input wire [size-1:0]	MulB,
	output wire [(size*2)-1:0]	wPro
);
wire [size-2:0] wCarry[size-1:0];
wire [size-1:0] wSuma[size-1:0];

parameter MAX_COLS = size-1;
parameter MAX_ROWS = size-2;

assign wPro[0] = MulA[0]&MulB[0];
assign wSuma[0][size-1] = 0;

FULL_ADDER # (1) MyAdder5(
						.A(MulA[size-1]& MulB[MAX_ROWS+1]),
						.B(wSuma[MAX_ROWS][size-1]),
						.Ci(wCarry[ MAX_ROWS ][ size-1 ]),
						.Co(wPro[2*size-1]),
						.SUM(wPro[2*size-2])				
						);
						
genvar CurrentRow, CurrentCol;
generate 

for (CurrentCol = 0; CurrentCol <= (MAX_COLS-1); CurrentCol = CurrentCol + 1) //La primer fila de sum no recibe resultado previo
	begin: FIRST_ROW
		assign wSuma[ 0 ][ CurrentCol ] = MulA[CurrentCol+1]&MulB[0];	
	end
	
for (CurrentRow = 0; CurrentRow <= MAX_ROWS; CurrentRow = CurrentRow + 1)  //Los carrier entrada de los sumadores de la derecha son cero y 
		begin: COL_ZERO													 // su resultado se guarda en rPro
		assign wCarry[ CurrentRow ][ 0 ] = 0;	
		FULL_ADDER # (1) MyAdder1(
						.A(MulA[0]&MulB[CurrentRow+1]),
						.B(wSuma[CurrentRow][0]),
						.Ci(wCarry[ CurrentRow ][ 0 ]),
						.Co(wCarry[ CurrentRow ][ 1]),
						.SUM(wPro[CurrentRow+1])				
						);		
		end
		
for (CurrentRow = 0; CurrentRow <= MAX_ROWS-1; CurrentRow = CurrentRow + 1)  //Los carrier salida de la ultima col se guarda en wSuma
	begin: CARRY_OUT
		FULL_ADDER # (1) MyAdder4(
						.A(MulA[size-1]&MulB[CurrentRow+1]),
						.B(wSuma[CurrentRow][size-1]),
						.Ci(wCarry[ CurrentRow ][ size-1 ]),
						.Co(wSuma[ CurrentRow+1 ][ size-1]),
						.SUM(wSuma[CurrentRow+1][size-2])				
						);	
	end		
	
for (CurrentCol = 1; CurrentCol <= MAX_COLS-1; CurrentCol = CurrentCol + 1)
	begin: MUL_COL
		for (CurrentRow = 0; CurrentRow <= MAX_ROWS; CurrentRow = CurrentRow + 1)
			begin			
				if (CurrentRow == (size-2))
						FULL_ADDER # (1) MyAdder2(
						.A(MulA[CurrentCol]&MulB[size-1]),
						.B(wSuma[CurrentRow][CurrentCol]),
						.Ci(wCarry[ CurrentRow ][ CurrentCol ]),
						.Co(wCarry[ CurrentRow ][ CurrentCol + 1]),
						.SUM(wPro[CurrentCol + size - 1])				
						);	
				else
						FULL_ADDER # (1) MyAdder3(
							.A(MulA[CurrentCol]&MulB[CurrentRow+1]),
							.B(wSuma[CurrentRow][CurrentCol]),
							.Ci(wCarry[ CurrentRow ][ CurrentCol ]),
							.Co(wCarry[ CurrentRow ][ CurrentCol + 1]),
							.SUM(wSuma[CurrentRow+1][CurrentCol-1])				
							);	
			end							
	end
											
endgenerate
endmodule
