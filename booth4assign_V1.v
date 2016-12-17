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
module booth4assign_V1(
              A , // entrada multiplicando
              B , // entrada multiplcador
              S /*,  // saida com resultado final
              clk*/
              );

//==============parametros========================================================================
parameter TAM = `TAM;
//-------------portas de entrada------------------------------------------------------------------
input [TAM-1:0] A;
input [TAM-1:0] B;
//input clk;//teste
//-------------portas de saida--------------------------------------------------------------------
output [TAM+TAM-1:0] S;

//-------------fios-------------------------------------------------------------------------

wire [TAM+TAM-1:0] MD;                     // auxiliar entrada A
wire [TAM:0] MR;                           // auxiliar entrada B

wire [TAM:0] menosMD;                // auxiliar complemento de 2 de A
wire [TAM:0] doisMD;                 // auxiliar 2*A
wire [TAM:0] menos2MD;               // auxiliar complemento de 2 de 2*A
//
// wire [TAM-1  :0]   zero;                   // auxiliar zero
// wire [TAM-1  :0]   um;                     // auxiliar um


wire [TAM-1:0]     A;
wire [TAM-1:0]     B;
/*reg*/ wire [TAM+TAM-1:0] S;                      // saida, parciais somados

wire [(TAM>>1)-1:0] flag ;          // se bit em questao sao iguais saida tera 0
wire [(TAM>>1)-1:0] xor1 ;    // selecionarah se eh +-md ou +-2md
wire [TAM:0] beta   [0:(TAM>>1)-1];  // MD ou menosMD
wire [TAM:0] beta0  [0:(TAM>>1)-1];  // doisMD ou menos2MD
wire [TAM:0] beta1  [0:(TAM>>1)-1];  // atraves de xor1 escolhe 2A ou A
wire [TAM:0] beta2  [0:(TAM>>1)-1];  // atraves da flag escolhe beta1 e 0
wire [TAM+TAM-1:0] beta3  [0:(TAM>>1)-1];  // desloca beta2

wire [TAM+TAM-1:0] Spar   [0:(TAM>>1)-1];  // somas de parciais
wire [TAM+TAM-1:0] P      [0:(TAM>>1)-1];  // auxiliar somas parciais TAM/2 numero de somas

//------------comportamento logico----------------------------------------------------------
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH fios da operacao HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
// assign zero = {TAM{1'b0}};                 // informacao zeros
// assign um   = {TAM{1'b1}};                 // informacao um's

assign MR = {B, 1'b0};                     // multiplicador  + 'bit lsb do algoritmo booth'
assign MD = { A[TAM-1], A };        // multiplicando preenchido com um ou zero
assign menosMD = -(MD);                // complemento de 2 de MD
// assign doisMD ={MD,1'b0};                     // duas vezes MD
// assign menos2MD = {menosMD,1'b0};           // comp2 de 2MD


assign Spar[0] = P[0];          // informacao zeros, primeira soma
/*always @(posedge clk)*/ assign S       = Spar[(TAM>>1)-1];            //saida eh ultima soma de parciais
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH algoritmo booth HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
genvar I;
generate
  for (I=1; I<TAM+1 ; I=I+2) begin: booth      //radix 2, soma TAM/2 vezes; 0, 2, 4,8...
    assign flag [(I>>1)] = (~(MR[I] & MR[I-1] & MR[I+1])&(MR[I] | MR[I-1] | MR[I+1]));//flag de igualdade
    assign xor1 [(I>>1)] = (MR[I] ^ MR[I-1]);             //selecionarah se eh +-md ou +-2md
    assign beta [(I>>1)] = MR[I+1] ?  menosMD  : MD ;     //verifica se +-md
    //assign beta0[(I>>1)] = MR[I+1] ?  menos2MD : doisMD ; //verifica se +-2md
    assign beta1[(I>>1)] = xor1[I>>1] ? beta[(I>>1)] : {beta [(I>>1)],1'b0}; //seleciona se eh +-md ou +-2md
    assign beta2[(I>>1)] = {(TAM+TAM){flag[I>>1]}}  & beta1[(I>>1)] ;           //se todos iguais zera a parcial
    case(I)
      1:
        assign beta3[(I>>1)] = { {(TAM-I){beta2[I>>1][TAM]}}  , beta2[I>>1] }  ;
      default:
        assign beta3[(I>>1)] = { {(TAM-I){beta2[I>>1][TAM]}}  , beta2[I>>1] ,  {(I-1){1'b0}} }  ;   //TODO trocar deslocamento por concatenacao    //rotaciona i-1 vezes, segundo logica booth modificado,

    endcase
    assign P  [(I>>1)] = beta3[I>>1];  // atualiza valor da soma parcial no vetor P [1->1],[3->2],[5->3],...[15->8]
  end
endgenerate // final da geracao de parciais
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH somas parciais HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
genvar J;
generate //soma as parciais
	for (J=1; J<=(TAM>>1)-1; J=J+1) begin: sums //numero de operandos sempre e' metade do tamanho de bits
		//inicio somador parametrizados
		somador #(.TAM(TAM+TAM)) soma(
						.A(Spar[J-1]),
						.B(P[J]),
						.S(Spar[J] )
					);

		//fim somador parametrizado
	end
endgenerate
endmodule
