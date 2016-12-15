//----------------------------------------------------------------------------------------------//
// driver multiplicador booth radix 4                 criador: Marlon Sigales                   //
// Nome do Design: driverclk                          orientador: Mateus Beck Fonseca           //
// Nome do arquivo: driverclk                                                                   //
// Funcao : chamar arquivos e fazer arvore de clk                                               //
// data da ultima modificacaoo: 17-08-2015                                                      //
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
//`include "BoothParalelo8b.vhd"
//`define boot_VHDL_name(count) BoothParalelo``count``b
module driverclk(
              A ,                                       // entrada multiplicando
              B ,                                       // entrada multiplcador
              Y ,                                         //saida com resultado final/parcial
              X ,
              W ,
              S ,
              clk
              );

//==============parametros==================================================================================================================================
parameter TAM = `TAM;

//-------------portas de entrada----------------------------------------------------------------------------------------------------------------------------
input  [TAM-1:0] A;
input  [TAM-1:0] B;
input wire  clk;
//-------------portas de saida------------------------------------------------------------------------------------------------------------------------------
output wire signed [TAM*2-1:0] Y;
output wire signed [TAM*2-1:0] X;
output wire signed [TAM*2-1:0] W;
output wire signed [TAM*2-1:0] S;



//------------comportamento logico--------------------------------------------------------------------------------------------------------------------------

       //nomemodulo nomelocal (.parametrolah(parametroaqui)) (conexoes)
		// if(TAM==8) BoothParalelo8b BoothVHDL_MODEL8 (// .nomelah (nomeaqui)
    //                                    .A           (A)  ,   //este booth paralelo esta dentro de um always
    //                                    .B           (B)  ,
    //                                    .S           (Y)/*,
		// 		       .clk         (clk)  */
    //                                    );
		// else if(TAM ==16)BoothParalelo16b BoothVHDL_MODEL16 (// .nomelah (nomeaqui)
    //                                    .A           (A)  ,   //este booth paralelo esta dentro de um always
    //                                    .B           (B)  ,
    //                                    .S           (Y)
    //                                    );
		// else if(TAM ==32)BoothParalelo32b BoothVHDL_MODEL32 (// .nomelah (nomeaqui)
    //                                    .A           (A)  ,   //este booth paralelo esta dentro de um always
    //                                    .B           (B)  ,
    //                                    .S           (Y)
    //                                    );
		// else if(TAM ==64)BoothParalelo64b BoothVHDL_MODEL64 (// .nomelah (nomeaqui)
    //                                    .A           (A)  ,   //este booth paralelo esta dentro de um always
    //                                    .B           (B)  ,
    //                                    .S           (Y)
    //                                    );
		// else booth4always    #(.TAM(TAM)) boothparaleloalways (// .nomelah (nomeaqui)
    //                                    .A           (A)  ,
    //                                    .B           (B)  ,    //este é a primeira idéia, com somas sucessivas
    //                                    .S           (Y)  ,
    //                                    .clk          (clk)
    //                                    );




		booth4assign_V2    #(.TAM(TAM)) booth_assign_modificado (// .nomelah (nomeaqui)
                                       .A           (A)  ,
                                       .B           (B)  ,    //este é a primeira idéia, com somas sucessivas
                                       .S           (W)  /*,
                                      // .clk          (clk)*/
                                       );

          	booth4assign  #(.TAM(TAM)) boothparaleloaassign (// .nomelah (nomeaqui)
                                       .A           (A)  ,   //este multiplicador eh todo paralelo
                                       .B           (B)  ,
                                       .S           (X)  /*,
                                       .clk          (clk) */
                                       );


		ferramenta #(.TAM(TAM)) ferramenta (// .nomelah (nomeaqui)
                                       .A           (A)  ,    //a*b
                                       .B           (B)  ,
                                       .S           (S)  /*,
                                       .clk          (clk)*/
                                       );


endmodule
