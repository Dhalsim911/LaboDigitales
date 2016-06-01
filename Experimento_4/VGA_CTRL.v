`timescale 1ns / 1ps

module VGA_CONTROLLER
(
input wire Clock,
input wire Reset,
output wire oHS, oVS, oVmemAddress
);


UPCOUNTER_POSEDGE CurrentCol
(
.Clock(   Clock2               ), 
.Reset(   Reset | rBranchTaken ),
.Initial( wIPInitialValue + 1  ),
.Enable(  1'b1                 ),
.Q(       wIP_temp             )
);

endmodule 