//Mauricio José Valverde Monge A76674
//Francisco Andrés Vargas Piedra A76821
//Module_ROM.v Modificado para Laboratorio de Circuitos Digitales I

`timescale 1ns / 1ps
`include "Defintions.v"

`define SaveWhite 8'd50
`define WhiteWhite 8'd52
`define WhiteBlack 8'd57

`define SaveBlack 8'd70
`define BlackBlack 8'd72
`define BlackWhite 8'd77

`define SALTO_1 8'd5
`define SALTO_2 8'd13
`define SALTO_3 8'd21
`define SALTO_4 8'd29

module ROM
(
	input  wire[15:0]  		iAddress,
	output reg [27:0] 		oInstruction
);
	
always @ ( iAddress )
begin
	case (iAddress)

	0: oInstruction = { `NOP ,24'd4000       }; 
	1: oInstruction = { `STO ,`R1, 16'd0 };	//R1 => Col
	2: oInstruction = { `STO ,`R2, 16'd0 };	//R2 => Fil
	3: oInstruction = { `STO ,`R7, 16'd30 };	//R7 => ADD
	4: oInstruction = { `STO ,`R6, 16'd299 };	//End
	
	5: oInstruction = { `STO ,`R4, 16'd29 };	//R4 => Límite Fil
	6: oInstruction = { `CALL ,`SaveWhite, 16'd0 };	
	7: oInstruction = { `ADD ,`R4, `R4, `R7  };
	8: oInstruction = { `CALL ,`SaveBlack, 16'd0 };	
	9: oInstruction = { `BGE , 8'b0, `R4, `R6  };
	10: oInstruction = { `ADD ,`R4, `R4, `R7  };
	11: oInstruction = { `JMP ,8'd6, 16'b0  };
	
		//TAG SaveWhite
	50: oInstruction = { `STO ,`R1, 16'd0 };	//R1 => Col
	51: oInstruction = { `STO ,`R3, 16'd29 };	//R3 => Límite Col
		//TAG WhiteWhite
	52: oInstruction = { `VGA ,`COLOR_WHITE, `R1, `R2  };
	53: oInstruction = { `INC ,`R1, `R1, 8'd0  };
	54: oInstruction = { `NOP ,24'd4000       }; 
	55: oInstruction = { `BLE ,`WhiteWhite, `R1, `R3  };
	56: oInstruction = { `ADD ,`R3, `R3, `R7  };
		//TAG WhiteBlack
	57: oInstruction = { `VGA ,`COLOR_BLACK, `R1, `R2  };
	58: oInstruction = { `INC ,`R1, `R1, 8'd0  };
	59: oInstruction = { `NOP ,24'd4000       }; 
	60: oInstruction = { `BLE ,`WhiteBlack, `R1, `R3  };
	61: oInstruction = { `ADD ,`R3, `R3, `R7  };
	62: oInstruction = { `BLE ,`WhiteWhite, `R1, `R6  };
	63: oInstruction = { `INC ,`R2, `R2, 8'd0  };
	64: oInstruction = { `NOP ,24'd4000       }; 
	65: oInstruction = { `BLE ,`SaveWhite, `R2, `R4  };	
	66: oInstruction = { `RET ,24'd0 };	

		//TAG SaveBlack
	70: oInstruction = { `STO ,`R1, 16'd0 };	//R1 => Col
	71: oInstruction = { `STO ,`R3, 16'd29 };	//R3 => Límite Col
		//TAG BlackBlack
	72: oInstruction = { `VGA ,`COLOR_BLACK, `R1, `R2  };
	73: oInstruction = { `INC ,`R1, `R1, 8'd0  };
	74: oInstruction = { `NOP ,24'd4000       }; 
	75: oInstruction = { `BLE ,`BlackBlack, `R1, `R3  };
	76: oInstruction = { `ADD ,`R3, `R3, `R7  };
		//TAG BlackWhite
	77: oInstruction = { `VGA ,`COLOR_WHITE, `R1, `R2  };
	78: oInstruction = { `INC ,`R1, `R1, 8'd0  };
	79: oInstruction = { `NOP ,24'd4000       }; 
	80: oInstruction = { `BLE ,`BlackWhite, `R1, `R3  };
	81: oInstruction = { `ADD ,`R3, `R3, `R7  };
	82: oInstruction = { `BLE ,`BlackBlack, `R1, `R6  };
	83: oInstruction = { `INC ,`R2, `R2, 8'd0  };
	84: oInstruction = { `NOP ,24'd4000       }; 
	85: oInstruction = { `BLE ,`SaveBlack, `R2, `R4  };	
	86: oInstruction = { `RET ,24'd0 };	

/*Rutina para imprimir 4 franjas en pantalla

	0: oInstruction = { `NOP ,24'd4000       }; 
	1: oInstruction = { `STO ,`R4, 16'd63 };	//R4 => Limite Col
	2: oInstruction = { `STO ,`R5, 16'd255 };	//R5 => Limite Fil

	3: oInstruction = { `STO ,`R7, 16'd0 };	//R7 => Fil 	Registros en donde se elige donde escribir en RAM, y la posición en pantalla.
	4: oInstruction = { `STO ,`R6, 16'd0 };	//R8 => Col
	// Salto_1
	5: oInstruction = { `VGA ,`COLOR_BLUE, `R7, `R6  };
	6: oInstruction = { `INC, `R7, `R7, 8'd0 };
	7: oInstruction = { `BLE, `SALTO_1, `R7, `R5 };	
	8: oInstruction = { `STO ,`R7, 16'd0 };	
	9: oInstruction = { `INC, `R6, `R6, 8'd0 };
	10: oInstruction = { `BLE, `SALTO_1, `R6, `R4 };

	11: oInstruction = { `STO ,`R7, 16'd0 };	//R7 => Fil
	12: oInstruction = { `STO ,`R4, 16'd127 };	//R4 => Limite Col
	// Salto_2
	13: oInstruction = { `VGA ,`COLOR_RED, `R7, `R6  };
	14: oInstruction = { `INC, `R7, `R7, 8'd0 };
	15: oInstruction = { `BLE, `SALTO_2, `R7, `R5 };	
	16: oInstruction = { `STO ,`R7, 16'd0 };	
	17: oInstruction = { `INC, `R6, `R6, 8'd0 };
	18: oInstruction = { `BLE, `SALTO_2, `R6, `R4 };	
	
	19: oInstruction = { `STO ,`R7, 16'd0 };	//R7 => Fil
	20: oInstruction = { `STO ,`R4, 16'd191 };	//R4 => Limite Col
	// Salto_3
	21: oInstruction = { `VGA ,`COLOR_MAGENTA, `R7, `R6  };
	22: oInstruction = { `INC, `R7, `R7, 8'd0 };
	23: oInstruction = { `BLE, `SALTO_3, `R7, `R5 };	
	24: oInstruction = { `STO ,`R7, 16'd0 };	
	25: oInstruction = { `INC, `R6, `R6, 8'd0 };
	26: oInstruction = { `BLE, `SALTO_3, `R6, `R4 };	
	
	27: oInstruction = { `STO ,`R7, 16'd0 };	//R7 => Fil
	28: oInstruction = { `STO ,`R4, 16'd255 };	//R4 => Limite Col
	// Salto_4
	29: oInstruction = { `VGA, `COLOR_WHITE, `R7, `R6  };
	30: oInstruction = { `INC, `R7, `R7, 8'd0 };
	31: oInstruction = { `BLE, `SALTO_4, `R7, `R5 };	
	32: oInstruction = { `STO ,`R7, 16'd0 };	
	33: oInstruction = { `INC, `R6, `R6, 8'd0 };
	34: oInstruction = { `BLE, `SALTO_4, `R6, `R5 };		
	35: oInstruction = { `JMP, 8'd35, 16'b0 };

	
	
	50: oInstruction = { `INC, `R7, `R7, 8'd0 };
	51: oInstruction = { `NOP ,24'd4000       }; 
	52: oInstruction = { `VGA ,`COLOR_BLUE, `R7, `R7  };	
	53: oInstruction = { `NOP ,24'd4000       };
*/

	default:
		oInstruction = { `NOP ,24'd4000       };		//NOP
	endcase	
end
	
endmodule
