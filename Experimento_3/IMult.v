`timescale 1ns / 1ps
`include "Defintions.v"

module ADDER(
 input wire wiSourceData1, 
 input wire wiSourceData2, 
 input wire wiSourceData3,
 output wire woCarry, 
 output wire woPartialResult
);

assign {woCarry, woPartialResult} = wiSourceData1 + wiSourceData2 + wiSourceData3;

endmodule

module MULTIPLIER(
 input wire [15:0] wA, wB,
 output wire [15:0] woResult
); 

wire [3:0] wCarry [2:0];


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

