`timescale 1ns / 1ps

module change_count(c,load,out);
	input[1:0] load;
	input[2:0] c;  
	output[2:0] out;
	wire temp;
	wire[2:0] w;
	and gate(w[2],0,0);
	not nw1(w[0],c[0]); 
	xor ow1(temp,c[0],c[1]);
	not n11(w[1],temp);
	wire[6:0] s;
	and as1(s[0],~load[1],load[0],c[0]);
	and as2(s[1],~load[1],load[0],c[1]);
	and as3(s[2],~load[1],load[0],c[2]);
	and as4(s[3],~load[0],~load[1]);
	and as5(s[4],load[1],w[0]);
	and as6(s[5],load[1],w[1]);
	and as7(s[6],load[1],w[2]);
	or os1(out[0],s[0],s[4]);
	or os2(out[1],s[1],s[5]);
	or os3(out[2],s[2],s[3],s[6]);
endmodule
  
module MUX2to1(a0,a1,sel,out);
	input a0,a1;
	input sel;
	output out;
	wire t1,t2,t3;
	not muxn(t3,sel);
	and muxa(t1,a0,t3);
	and muxb(t2,a1,sel);
	or muxo(out,t1,t2);
endmodule

module val_or_2val(implicand2,select,t_2);
	input[7:0] implicand2;
	input select;
	output[8:0] t_2;
	MUX2to1 ms1(implicand2[0],0,select,t_2[0]);
	MUX2to1 ms2(implicand2[1],implicand2[0],select,t_2[1]);
	MUX2to1 ms3(implicand2[2],implicand2[1],select,t_2[2]);
	MUX2to1 ms4(implicand2[3],implicand2[2],select,t_2[3]);
	MUX2to1 ms5(implicand2[4],implicand2[3],select,t_2[4]);
	MUX2to1 ms6(implicand2[5],implicand2[4],select,t_2[5]);
	MUX2to1 ms7(implicand2[6],implicand2[5],select,t_2[6]);
	MUX2to1 ms8(implicand2[7],implicand2[6],select,t_2[7]);
	MUX2to1 ms9(implicand2[7],implicand2[7],select,t_2[8]);	
endmodule 

module next(product,n_prod,state,next_state,count,n_cnt,clk,reset); 
	output[17:0] product;
	output[1:0] state;
	output[2:0] count;
	input[17:0] n_prod;
	input[1:0] next_state;
	input[2:0] n_cnt;
	input clk,reset; 
	reg[17:0] product;
	reg[1:0] state;
	reg[2:0] count;
	always@(posedge clk)
	begin
		if(reset)begin
			state = 2'b00;
			count = 3'b100;
		end
		else begin
			state = next_state;
			product = n_prod;
			count = n_cnt;
		end
	end
endmodule

module ALU(X,Y,select,Z);
	input[8:0] X,Y;
	input select;
	output[8:0] Z;
	wire[8:0] sum,diff,dec;
	assign sum = X+Y+0;
	assign diff = X-Y;
	MUX2to1 mux1(sum[0],diff[0],select,Z[0]);
	MUX2to1 mux2(sum[1],diff[1],select,Z[1]);
	MUX2to1 mux3(sum[2],diff[2],select,Z[2]);
	MUX2to1 mux4(sum[3],diff[3],select,Z[3]);
	MUX2to1 mux5(sum[4],diff[4],select,Z[4]);
	MUX2to1 mux6(sum[5],diff[5],select,Z[5]);
	MUX2to1 mux7(sum[6],diff[6],select,Z[6]);
	MUX2to1 mux8(sum[7],diff[7],select,Z[7]);
	MUX2to1 mux9(sum[8],diff[8],select,Z[8]);
endmodule
module stat_det(count,status);
 	input[2:0] count;
	output status;
	wire w1;
	or os1(w1,count[0],count[1]);
	or os2(status,w1,count[2]);
endmodule

module controller(go,status,state,next_state,load_val,l3b,functionsel,over,check_state);
	input go,status;
	input[1:0] state;
	input[2:0] l3b;
	output[1:0] next_state,functionsel;
	output[3:0] load_val; 
	output over;
	output[1:0] check_state;
	assign check_state=state;
	wire[14:0] q;
	and an1(q[0],~state[1],state[0]);
	and aa2(q[1],state[1],~state[0]);
	and aa3(q[2],l3b[0],l3b[1],l3b[2]);
	and aa4(q[3],~l3b[0],~l3b[1],~l3b[2]);
	or oo1(q[4],q[3],q[2]);
	and aa5(q[6],q[4],q[1]);
	and aa6(q[5],state[0],state[1]);
	or oo2(load_val[0],q[0],q[5],q[6]);
	and aa7(load_val[1],state[1],~state[0]);	
	and aa8(load_val[2],state[0],state[0]);
	and aa9(load_val[3],state[1],~state[0]);
	xor gater(q[7], l3b[0],l3b[1]);
	not gater1(functionsel[0], q[7]);
	and aa12(functionsel[1],l3b[2],l3b[2]);
	and aa13(over,state[0],state[1]); 
	and aa14(q[11],~state[0],~state[1],go);
	and aa15(q[12],state[0],~state[1],~status);
	and aa16(q[13],state[0],state[1],~go);
	or oo4(q[14],q[11],q[12],q[13]);
	or oo5(next_state[0],q[14],q[1]);
	or oo6(next_state[1],q[13],q[0]);
endmodule

module shift_function(in0,in1,in2,in3,sel,out);
	input[17:0] in0,in1,in2,in3;
	input[1:0] sel;
	output[17:0] out;
	generate
		genvar i;
		for(i=0;i<18;i=i+1)begin : test
			assign out[i]=(((in0[i])&(~sel[0])&(~sel[1]))|((in1[i])&(sel[0])&(~sel[1]))|((in2[i])&(sel[1])&(~sel[0]))|((in3[i])&(sel[0])&(sel[1])));
		end
	endgenerate
endmodule

module booth_radix4(mplier,mpcand,go,clk,prod,over,reset,check_state); 
	input[7:0] mplier,mpcand;
	input go,clk,reset;
	output[15:0] prod;
	output over;
	wire[17:0] product,n_prod;
	wire[3:0] load;
	wire[2:0] count,n_cnt;
	wire[1:0] next_state,fnsel,state;
	wire status;	
	output[1:0] check_state;
	datapath dpath(load,fnsel,mplier,mpcand,product,n_prod,count,n_cnt,status,prod);
	controller control(go,status,state,next_state,load,product[2:0],fnsel,over,check_state); 
	next compute_next(product,n_prod,state,next_state,count,n_cnt,clk,reset);
endmodule

module datapath(load_val,sel,mplier,mpcand,product,n_prod,count,n_cnt,status,answer);
	input[3:0] load_val;
	input[1:0] sel;
	input[7:0] mplier,mpcand; 
	input[17:0] product;
	input[2:0] count;
	output[17:0] n_prod;
	output[2:0] n_cnt;
	output status;
	output[15:0] answer;
	wire[8:0] Z,t_2;
	val_or_2val check(mpcand,sel[0],t_2);
	ALU ari_log_unit(product[17:9],t_2,sel[1],Z);  
	shift_function loadprod({9'b000000000,mplier[7:0],1'b0},product[17:0],{Z[8],Z[8],Z[8:0],product[8:2]},{product[17],product[17],product[17:2]},load_val[1:0],n_prod); 
	change_count loadcount(count,load_val[3:2],n_cnt); 
	assign answer=product[16:1];
	stat_det stat_detect(count,status);
endmodule
