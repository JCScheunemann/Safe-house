/*************************************************************************
 *  Multiplier Testbench                                                 *
 *  This testbench tests multiplications with basics and randons values  *
 *                                                                       *
 *  Developer: Mateus Beck Fonseca 	               Oct, 13, 2009         *
 *             beckfonseca@gmail.com               V. 2                  *
 *  Corrector: Marlon Soares Sigales               Oct, 14, 2015         *
 *             msoaressigales928@gmail.com         V. 3                  *
 *             Jean Carlos Scheunemann             May, 04, 20196        *
*              jeancarsch@gmail.com                V. 4                  *
 *************************************************************************/
`timescale 1 ns / 1 ns
`include "const.v"
//irun -64 -gui	arquivos.v -linedebug -access rwc


module tb_multipliers;

// Defining parameters size
 localparam integer PERIOD   = 10;   //clk period
  parameter integer
        TAM       = `TAM  ,             // bits size of operators
        NULO      =  0 ,             // zero
        UM_POS    =  1 ,             // one
        UM_NEG    =  2 ,             // minus one
        ALEATORIO =  3 ,             // random numbers
        STIM_SIZE = 10;           // number of diferent stimulus in DUT default 10000
  integer   i ;                      // counter for loop

// Signal declarations
// inputs to the DUT
  reg signed [TAM-1:0] A ;
  reg signed [TAM-1:0] B ;

// outputs to the DUT
  wire signed [TAM*2-1:0] S;
  wire signed [TAM*2-1:0] Y;
  wire signed [TAM*2-1:0] W;
  wire signed [TAM*2-1:0] X;

// local internal signals
  reg           clk;
  reg           alow_random ;             // flag to alow or not random multiplication
  reg [45*8:1]  message ;                 // Define a vector with 8 bits for each ASCII character
  reg signed [TAM-1:0]
    value_A, value_B ;        			  // alocation for random values

  wire [TAM*2-1:0]                        //  basic values declarations need 2*TAM for tool calculations
        ZERO    = {(TAM*2-1){1'b0}},              //- zero -> 0...16'b0000
        POS_ONE = {ZERO,1'b1},              // 1 -> one ... 16'b0001
        NEG_ONE = {(TAM*2){1'b1}};               // -1 -> minus one...16'hFFFF
  reg signed [TAM*2-1:0] S_test ;                // result of multiplicaton test

// Multiplier instantiation
/*booth4*///booth4 #(.TAM(TAM))DUT  (                   // replace "array_m2_vector" by the entity name in VHDL
  driverclk #(.TAM(TAM)) DUV(
	  .A  ( A ) ,                             // .name_hear (name_instance)
	  .B  ( B ) ,
	  .Y ( Y ),                                         //saida com resultado final/parcial
	  .X ( X ),
	  .W ( W ),
	  .S  ( S ) ,
	  .clk ( clk )
	  );
// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// clk generation
  initial clk = 1'b0;
  always #(PERIOD/2) clk = ~clk;

// random value generation
  always @(negedge clk)                    // one diferent value ate each negative edge clock
    begin
      if ( alow_random )
        begin
         /*random comand sintax:
           min + {$random(seed)}%(max-min+1) or can use $dist_uniform(seed, min, max) */
          value_A <= 16'h1 + {$random}%(16'hFFFF) ;
          value_B <= 0 + {$random}%(65536) ;
        end
    end

// messages display
  always @(message)                        // every check have message
    begin
    $display (" %s ", message);
    //$stop;                               // this command may cause trouble in Mentor, just coment
    end

// ------------------------  Apply stimulus  ---------------------------------------------------------------
  initial begin
    $dumpfile ("multiplication.vcd"); //create a specific VCD filename, used for switching activity
    $dumpvars; // signal the output of the simulation values. With no args dump all variables
   // $dumpall;
    $dumplimit(100000000);
  end

  initial       //  sempre em um initial eh sequencial e nao acontecem ao mesmo tempo
    begin
    @(posedge clk) alow_random = 0;	      // disable ramdom values,

    calculate (POS_ONE, POS_ONE);         // 1 x 1 = 1!
    @(negedge clk) check_out (UM_POS);
    repeat(2) @(posedge clk);
    calculate (NEG_ONE, POS_ONE);         // -1 x 1 = -1!
    @(negedge clk) check_out (UM_NEG);
    repeat(2) @(posedge clk);
    calculate (POS_ONE, NEG_ONE);         // 1 x -1 = -1!
    @(negedge clk) check_out (UM_NEG);
    repeat(2) @(posedge clk);
    calculate (NEG_ONE, NEG_ONE);         // -1 x -1 = 1!
    @(negedge clk) check_out (UM_POS);
    repeat(2) @(posedge clk);
    calculate (ZERO, POS_ONE);            // 0 x 1 = 0!
    @(negedge clk) check_out (NULO);
    repeat(2) @(posedge clk);
    calculate (NEG_ONE, ZERO);            // -1 x 0 = 0!
    @(negedge clk) check_out (NULO);

    // random values
    @(posedge clk) alow_random = 1;       // alow random values
    for (i=0; i <= STIM_SIZE; i=i+1)
    begin
      repeat(2) @(posedge clk);           // wait for some clocks
      calculate (value_A, value_B);       // random inputs
      @(negedge clk) check_out (ALEATORIO);              // compare with tool calculation

      if ( (( i*10) % STIM_SIZE) == 0 ) // i % (STIM_SIZE/100) ) == 0 ) // prints percentual simulation completion, 10 in 10%
            $display (" %d %%", i*100/STIM_SIZE);
    end
    $finish;

  end   // --------------------end stimulus --------------------------------------------------------------------------


// tasks and functions -----------------------------------------------------------------------------------------------

  task calculate (input reg  [TAM*2-1:0] a, input reg  [TAM*2-1:0] b); 		// input values to calculate in the DUT
  begin
    A = a;                  // A[TAM] but a[TAM*2] so => truncate!
    B = b;

//  HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
    @(posedge clk) S_test =  a*b;          // need to improve this, tool don't use complement of two for 16 bits, only 32!!!-------------------
//  HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
  end
  endtask

 task check_out ( input integer expected );  // 0=ZERO; 1= ONE; 2= MINUS ONE; 3= random inputs in multiplicator, must compare.
   begin
    case (expected)

  NULO   :  if (W !== 0 || W !== S_test )
              begin
				message = "***** Expected zero ***** MULTIPLIER TEST FAILED ";
			   $display($time,S," | ",S_test);
				end
            else  begin
			  if( S === X && S===W && S===Y )
              message = " MULTIPLIER ZERO TEST PASSED ";
			  else
			  message = "***** Expected zero ***** alguem errou entre si e nao foi o S";
            end
  UM_POS :  if ( W !== 1 || W !== S_test ) begin
              message = "***** Expected  one ****** MULTIPLIER TEST FAILED ";
			  $display($time,S," | ",S_test);
			  end
            else begin
              if( S === X && S===W && S===Y )
              message = " MULTIPLIER one TEST PASSED ";
			  else
			  message = "***** Expected one ***** alguem errou entre si e nao foi o S";
            end
  UM_NEG  : if ( S !== {(TAM*2){1'b1}} || S !== S_test ) begin
              message = "***** Expected minus one ***** MULTIPLIER TEST FAILED";
			   $display($time,S," | ",S_test);
			   end
            else begin
              if( S === X && S===W && S===Y )
              message = " MULTIPLIER minus one TEST PASSED ";
			  else
			  message = "***** Expected minus one  alguem errou entre si e nao foi o S";
            end
  ALEATORIO : if ( S !== S_test ) begin
                message = "***** RANDOM NUMBERS ***** TEST FAILED ";
				 $display("xxxxxxxxxxxxxxxxxxxxx",$time," ",S," | ",S_test);
				 end
              else begin
                if( S === X && S===W && S===Y )
                 message = " MULTIPLIER random TEST PASSED ";
			     else begin
			     message = "***** Expected random ***** alguem errou entre si e nao foi o S";
				$display(">>>>>>>>>Error ",$time,"::::: ",A,"*",B," = ",S," | ",S_test);
				end
				end

  default: message = " MULTIPLIER BASIC TEST PASSED ";

    endcase
   end
 endtask


endmodule
