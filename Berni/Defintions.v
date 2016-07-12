//Mauricio José Valverde Monge A76674
//Francisco Andrés Vargas Piedra A76821
//Defintions.v Modificado para Laboratorio de Circuitos Digitales I

`timescale 1ns / 1ps
`ifndef DEFINTIONS_V
`define DEFINTIONS_V

`default_nettype none 

`define COLOR_BLACK 8'b00000000
`define COLOR_BLUE 8'b00000001
`define COLOR_GREEN 8'b00000010
`define COLOR_CYAN 8'b00000011
`define COLOR_RED 8'b00000100
`define COLOR_MAGENTA 8'b00000101
`define COLOR_YELLOW 8'b00000110
`define COLOR_WHITE 8'b00000111

// Se pueden implementar 16 instrucciones máximo
`define NOP   4'd0  
`define STO   4'd1
`define INC   4'd2 //Destination = Source + 1
`define VGA   4'd3
`define BGE   4'd4
`define JMP   4'd5
`define BLE   4'd6
`define ADD	  4'd7
`define CALL  4'd8
`define RET	  4'd9

// Definición de registros en memoria RAM
`define R0 8'd0
`define R1 8'd1
`define R2 8'd2
`define R3 8'd3
`define R4 8'd4
`define R5 8'd5
`define R6 8'd6
`define R7 8'd7
`define R8 8'd8
`define R9 8'd9
`define R10 8'd10
`define R11 8'd11
`define R12 8'd12
`define R13 8'd13
`define R14 8'd14
`define R15 8'd15

//Código PS2
`define W 8'h1D
`define A 8'h1C
`define S 8'h1B
`define D 8'h23
`define DER 8'h74
`define IZQ 8'h6B

`endif
