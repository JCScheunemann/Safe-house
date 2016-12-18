//----------------------------------------------------------------------------------------------//
// multiplicador booth radix 4                        criador: Marlon Sigales                   //
// Nome do Design: booth4                             orientador: Mateus Beck Fonseca           //
// Nome do arquivo: booth4.v                                                                    //
// Funcao : multiplicador utilizando algoritmos de booth base 4                                 //
// data da ultima modificacaoo: 17-08-2015                                                      //
// Versao   date        coder       changes                                                     //
//    0.1  aug 17 2015  Marlon      file created                                                //
//    0.2  aug 26 2015  Marlon      muxes implementation                                        //
//    0.2  aug 28 2015  Marlon      comentarios de linha                                        //
//    0.2  aug 31 2015  Marlon      comentarios de linha, revisao                               //
//    0.2  set 02 2015  Raphael     verificacao de erro                                         //
//    0.2  set 02 2015  Marlon      revisao                                                     //
//    1.0  set 10 2015  Marlon      estado final, comentarios e revisoes                        //
//    1.1  jan 26 2016  Marlon      retirando somador do generate for;                          //
//    1.1  jan 29 2016  Marlon      gerando soma                                                //
//    1.2  feb 03 2016  Marlon      consertando erros que ficaram pra traz, versao quase full   //
//    1.2  apr 07 2016  Mateus      debug e sugestoes                                           //
//    1.2  apr 08 2016  Marlon      correcoes                                                   //
//    2.0  may 04 2016  Jean        debug e correcoes em index, estado final                    //
//    3.0  may 05 2016  Marlon,Jean parelizado sem always, comentarios   , estado final         //
//                                  somas variando largura de bits                              //
//    3.1  sep 22 2016  Jean        parametrizacao das somas
//----------------------------------------------------------------------------------------------//

`timescale 1 ns / 1 ns
`include "const.v"
module booth4assign_V2(
              A , // entrada multiplicando
              B , // entrada multiplcador
              S /*,  // saida com resultado final
              clk*/
              );

	//==============parametros========================================================================
	parameter TAM = `TAM;
	//-------------portas de entrada------------------------------------------------------------------
	input wire [TAM-1:0] A;
	input wire [TAM-1:0] B;
	//input clk;//teste
	//-------------portas de saida--------------------------------------------------------------------
	output wire [TAM+TAM-1:0] S; // saida, parciais somados

	//-------------fios-------------------------------------------------------------------------------
	/*
	*	Sinais auxiliares
	*/
	//wire [TAM:0] MD;                     // auxiliar entrada A
	wire [TAM:0] MR;                     // auxiliar entrada B
	wire [TAM-1:0] menosMD;                // auxiliar complemento de 2 de A		
	/*
	*	Seletores
	*/
	wire [(TAM>>1)-1:0] flag ;          // se bit em questao sao iguais saida tera 0
	wire [(TAM>>1)-1:0] xor1 ;    		// selecionarah se eh +-md ou +-2md
	/*
	*	Saidas parciais
	*/
	
	wire [TAM-1:0] beta  [0:(TAM>>1)-1];  				// MD ou menosMD
	wire [TAM:0] beta1 [0:(TAM>>1)-1];  				// atraves de xor1 escolhe 2A ou A

	wire [TAM+1:0] Spar[0:(TAM>>1)-1];  				// somas de parciaiss
	wire [TAM:0]   P   [0:(TAM>>1)-1];  				// auxiliar somas parciais TAM/2 numero de somas

	//=======================================Declaracao da logica Booth===============================

	//======================================= fios da operacao =======================================

	assign MR = {B, 1'b0};                  // multiplicador  + 'bit lsb do algoritmo booth'
	//assign MD = { A[TAM-1], A };        	// multiplicando preenchido com um ou zero
	assign menosMD = -(A);                	// complemento de 2 de MD

	//======================================= algoritmo booth ========================================
	genvar I;
	generate        
	  for (I=1; I<TAM+1 ; I=I+2) begin: booth //radix 2, soma TAM/2 vezes; 0, 2, 4,8...
		assign flag [(I>>1)] = (~(MR[I] & MR[I-1] & MR[I+1])&(MR[I] | MR[I-1] | MR[I+1]));//flag de igualdade
		assign xor1 [(I>>1)] = (MR[I] ^ MR[I-1]);             //selecionarah se eh +-md ou +-2md
		assign beta [(I>>1)] = {(TAM){flag[I>>1]}}  & (MR[I+1] ?  menosMD  : A );     //verifica se +-md
		assign beta1[(I>>1)] = xor1[I>>1] ? {beta[(I>>1)][TAM-1],beta[(I>>1)]} : {beta [(I>>1)],1'b0}; //seleciona se eh +-md ou +-2md
		
		assign P  [(I>>1)] = beta1[I>>1];  // atualiza valor da soma parcial no vetor P [1->1],[3->2],[5->3],...[15->8]
	  end
	endgenerate // final da geracao de parciais


	//======================================= somas parciais =========================================

	assign Spar[0]={P[0][TAM],P[0]};
	assign S[TAM+TAM-1:TAM-2]=Spar[(TAM>>1)-1];
	genvar J;
	generate //soma as parciais
		for (J=1; J<=(TAM>>1)-1; J=J+1) begin: sums //numero de operandos sempre e' metade do tamanho de bits
			//inicio somador parametrizados
			somador #(.TAM(TAM+2)) soma(
							.A({{2{Spar[J-1][TAM+1]}},Spar[J-1][TAM+1:2]}),
							.B({P[J][TAM],P[J]}),
							.S(Spar[J] )
						);
			assign S[2*J-1:2*J-2]=Spar[J-1][1:0];
			//fim somador parametrizado
		end
	endgenerate
endmodule

