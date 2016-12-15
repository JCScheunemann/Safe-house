
`timescale 1 ns / 1 ns
`include "const.v"
module somador( A, B, S);
	parameter TAM= `TAM;
	`ifdef NO_ARRAY
	  //input Cin;
		input [TAM-1:0] A;
		input [TAM-1:0] B;
		output [TAM:0] S;
		//$display("xxxxxxxxxxxxxxxxxxxxxxxxxxarray===============");
	`else
	  //input Cin;
		input [TAM-1:0] A;
		input [TAM-1:0] B;
		output [TAM-1:0] S;
		//$display("xxxxxxxxxxxxxxxxxxxxxxxxNo array===============");
	`endif

	`ifdef s1
		//descricao somador 1
	`elsif s2
		//Descricao somador 2
	`elsif s3
		//descricao somador 3
		//...
	`else
		//wire [TAM-1:0] A,B,S;
		assign S=A+B ;//+ Cin;
	`endif
endmodule
