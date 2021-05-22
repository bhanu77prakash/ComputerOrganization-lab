`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:05:52 08/11/2017 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module testbench(Go, regN, ans, clk, rst,tes);
	input regN;
	input Go,clk,rst;
	output ans;
	output tes;
	wire tes;
	assign tes = 1;
	 
  wire [1:0]Tx;
  wire [2:0]Ty;
  wire [4:0]ldr;
  wire [2:0]f_sel;
  wire bor;
  wire clk;
  wire rst;
  wire rstw;
  assign rstw=rst;
  wire [3:0] regN;
  wire [3:0] N;
  assign N = regN;
  wire Go;
  wire Gow;
  assign Gow = Go;
  wire [15:0] ans;
  wire [3:0] cstate;
  
  Control c(ldr,Tx,Ty,f_sel,cstate,bor,Gow,clk,rstw);
  Fibnogen d(N,ldr,Tx,Ty,bor,ans,f_sel);
  initial begin
	 clk=0;
    regN=10; 
    rst=1;
    #5
    rst=0;
    #5
    $display("%d %d",cstate,ans);
    Go=1;
    #100
    $display("%d %d",cstate,ans);
    #500
    $display("%d %d",cstate,ans);
  end
  
  always
    #2
    clk=~clk;
  
endmodule



module Control(ldr,Tx,Ty,fn_sel,curr_state, bo, Go, clk,rst);
  output [4:0] ldr;
  wire [4:0] ldr;
  output [1:0]Tx;
  reg [1:0]Tx;

  output [2:0] Ty;
  reg [2:0] Ty;

  output [3:0] curr_state;

  output [2:0] fn_sel;
  reg [2:0] fn_sel;

  input clk,rst;
  input bo,Go;
  wire bo, Go;

  reg[4:0] ldr_temp;
  reg[3:0] state, next_state;
  parameter SIZE = 4;
  parameter 
    S0 = 4'b0000,
    S1 = 4'b0001,  
    S2 = 4'b0010,
    S3 = 4'b0011,
    S4 = 4'b0100,
    S5 = 4'b0101, 
    S6 = 4'b0110, 
    S7 = 4'b0111,
    S8 = 4'b1000, 
    S9 = 4'b1001,
    S10 = 4'b1010, 
    S11 = 4'b1011, 
    S12 = 4'b1100, 
    S13 = 4'b1101;
  
  and a1(ldr[0],ldr_temp[0],(~clk));
  and a2(ldr[1],ldr_temp[1],(~clk));
  and a3(ldr[2],ldr_temp[2],(~clk));
  and a4(ldr[3],ldr_temp[3],(~clk));
  and a5(ldr[4],ldr_temp[4],(~clk));
  
  // defining state transitions
  always@(state or bo or Go)
    begin
      case(state)
        S0: next_state = S1;
        S1: next_state = S2;
        S2: next_state = S3;
        S3: next_state = S4;
        S4: next_state = S5;
        S5: next_state = S6;
        S6: begin  if(Go) next_state = S7;
          		else next_state = S1; end
        S7: next_state = S8;
        S8: next_state = S9;
        S9: next_state = S10;
        S10:next_state = S11;
        S11: begin if(bo) next_state = S7;
          		else next_state = S12; end
        S12: begin if(Go) next_state = S12;
          		else next_state = S13; end
        S13: next_state = S0;
        default: next_state = S0;
      endcase
    end	
	
  always@(posedge clk)
    begin
      if(rst)
        state = S0;
      else
        state = next_state;
    end

  
  always@(state)
    begin
      case(state)
        // n<= number
        S1:
          ldr_temp=5'b10000;
        // i<= 1
        S2:begin
          fn_sel = 3'b011;
          ldr_temp = 5'b00001;
        end
        S3:begin
        end
        S4:begin   // x<=1
          fn_sel =   3'b011;
          ldr_temp = 5'b01000;	
        end
        S5:begin    //y<=0
          fn_sel = 3'b010;
          ldr_temp = 5'b00100;
        end
        S6:begin   //z<=0
          fn_sel = 3'b010;	
          ldr_temp = 5'b00010;
        end	
        S7:begin  // z<= x + y  
          Tx = 2'b10;
          Ty = 3'b001;
          fn_sel = 3'b100;
          ldr_temp = 5'b00010;
        end
        S8:begin   // y<=x
          Tx = 2'b10;
          fn_sel = 3'b000;
          ldr_temp = 5'b00100;
        end
        S9: begin  // x<=z 
          Ty = 3'b010;
          fn_sel = 3'b001;
          ldr_temp = 5'b01000;
        end
        S10: 
          begin // i<= i + 1
          Ty = 3'b100;
          fn_sel = 3'b101;
          ldr_temp = 5'b00001;
        	end
        S11: begin // bo to check i<n or not
          //ldr_temp = 5'b00000;
          Tx = 2'b01;
          Ty = 3'b100;
          fn_sel = 3'b110;
          ldr_temp = 5'b00000;
        end
        S12:begin
          //over = 1;
			 end
      endcase
    end
  assign curr_state = state;
endmodule


module Fibnogen(n,ldr,Tx,Ty,bo,fib,fn_sel);
  input [3:0] n;
  input[2:0] fn_sel;
  input[4:0] ldr;
  input[2:0] Ty;
  input[1:0] Tx;
  output[15:0] fib;
  output bo;
  wire[15:0] x_bus,y_bus,z_bus;
  wire [15:0] fib;
  wire[15:0] n_tmp,x_tmp,y_tmp,i_tmp,ans_tmp;
  ALU fib_ALU(fn_sel, x_bus, y_bus, z_bus,bo);

  register N(1,{12'b000000000000,n},n_tmp,1'b0,ldr[4]);
  register x(1, z_bus, x_tmp, 1'b0,ldr[3]);
  register y(1, z_bus, y_tmp,1'b0,ldr[2]);
  register z(1, z_bus, ans_tmp, 1'b0,ldr[1]);
  register i(1, z_bus, i_tmp,1'b0, ldr[0]);

  tristate nt(Tx[0],n_tmp,x_bus);
  tristate xt(Tx[1],x_tmp,x_bus);
  tristate yt(Ty[0],y_tmp,y_bus);
  tristate zt(Ty[1],ans_tmp,y_bus);
  tristate it(Ty[2],i_tmp,y_bus);
  
  assign fib = ans_tmp;
  //always@ (ldr)
    //$display("%d",i_tmp);
endmodule



module ALU(fn_sel,x,y,z,bo);
  input[15:0] x;                           //input x
  input[15:0] y;									 //input y
  input[2:0] fn_sel;								 // select 	
  wire[2:0] fn_sel;
  output[15:0] z;									 // output z		
  output bo;										 // output borrow bo	
  wire bo;	
  reg[15:0]z;
  wire flag;										 // flag 		
  assign flag = ((~fn_sel[0])&&fn_sel[1]&&(fn_sel[2]));
  borrow bor(x,y,bo,flag);

  always @(x or y or fn_sel)
    begin
      case(fn_sel)
        3'b000:  z=x;
        3'b001:  z=y;
        3'b010:  z=0;
        3'b011:  z=1;
        3'b100:  z=x+y;
        3'b101:  z = y + 1;
        3'b110:  z = z; // for borrow, this is not loaded anywhere
      endcase
    end
endmodule


module borrow(x,y,bo,flag);
  input [15:0] x;
  input[15:0] y;
  //wire [15:0] x;
  //assign  x = x<<1;
  input flag;
  output bo;
  wire bo;
  //wire bo;
  wire [16:0]prevbo;
  wire [15:0]notx;
  wire [15:0] w2, w1, w0;
  wire negprevbo;
  assign prevbo[0]=1'b0;
  generate
    genvar i;
    for(i=0;i<16;i=i+1)
      begin: bhu
        not gate1(notx[i],x[i]);
        or gate2(w2[i],y[i],prevbo[i]);
        and gate3(w1[i],w2[i],notx[i]);
        and gate4(w0[i],y[i],prevbo[i]);
        or gate5(prevbo[i+1],w0[i],w1[i]);
      end
  endgenerate
  not notbo_gate(negprevbo,prevbo[16]);
  and final(bo,flag,negprevbo);
  
  /*always @( x or y or flag)
    begin
      if(flag && x < y)
        bo = 1'b1;
      else
        bo = 1'b0;
    end*/
endmodule



module register( load, in, out, rst, clk);

  input[15:0] in;
  output[15:0] out;
  input load,rst,clk;
  reg[15:0] out;

  always @( posedge rst or posedge clk)
		begin
          if( rst == 1)
			out = 0;
          else
              if(load == 1)
					out = in;
		end	
endmodule



module tristate(enable,in,out);

	input [15:0] in;
	output [15:0] out;
	input enable;
	wire [15:0] out;
	assign out = enable?in:'bz;
endmodule
