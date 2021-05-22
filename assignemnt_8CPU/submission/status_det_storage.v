module dflipflop ( in, qout, qout1, clk, reset);
	output reg qout, qout1;
	input in;
	input clk, reset;
	always @(posedge clk or posedge reset)
		begin
			if(reset)
				begin
					qout=0;
					qout1 = 1;
				end
			else
				begin
					qout= in;
					qout1 = ~in;
				end
		end
endmodule

module status_det(ZBUS, ci, ci_1, clk, reset, vin, zin, sin, cin);
	input ci, ci_1, clk, reset;
	input [15:0] ZBUS;
	output wire zin, vin, sin, cin ;
	//output zout, zout1, cout, cout1, vout, vout1,sout, sout1; 
	nor zero_det(zin,ZBUS[0],ZBUS[1],ZBUS[2],ZBUS[3],ZBUS[4],ZBUS[5],ZBUS[6],ZBUS[7],ZBUS[8],ZBUS[9],ZBUS[10],ZBUS[11],ZBUS[12],ZBUS[13],ZBUS[14],ZBUS[15]);
	xor over_flow(vin, ci, ci_1);
	assign sin = ZBUS[15];
	assign cin = ci;
endmodule