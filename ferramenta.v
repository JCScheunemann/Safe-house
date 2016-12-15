//----------------------------------------------------------------------------------------------//
// comparacao com descricoes                          criador: Marlon Sigales                   //
// Nome do Design: ferramenta                          orientador: Mateus Beck Fonseca           //
// Nome do arquivo: ferramenta                                                                   //
// Funcao : fazer comparativo com minhas descricoes de multiplicadores                         //
// data da ultima modificacao: 17-08-2015                                                      //
// Versao   date        coder    changes                                                        //
//    0.1  2/6/16       Marlon   file created                                                   //
//                                        //
//                                        //
//                                        //
//                                        //
//                                        //
//----------------------------------------------------------------------------------------------//
`timescale 1 ns / 1 ns
`include "const.v"
module ferramenta(
              A ,                                       // entrada multiplicando
              B ,                                       // entrada multiplcador
              S /*,                                        //saida com resultado final/parcial
              clk*/
              ); 

//==============parametros==================================================================================================================================
parameter TAM = `TAM;

//-------------portas de entrada----------------------------------------------------------------------------------------------------------------------------
input signed [TAM-1:0] A;
input signed [TAM-1:0] B;
//input clk;

//-------------portas de saida------------------------------------------------------------------------------------------------------------------------------
output /*reg*/ wire signed [TAM*2-1:0] S;

wire [TAM*2-1:0] Saida;

//------------comportamento logico--------------------------------------------------------------------------------------------------------------------------
/*always @(posedge clk)  S = Saida;                                        // multiplicacao da ferramenta  
assign Saida=A*B;*/
assign S=A*B;
            

     
endmodule 
