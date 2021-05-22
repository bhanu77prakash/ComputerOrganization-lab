module reg_16(in, clk, ld, reset, out);
	input wire [15:0] in;
	input clk, ld, reset;
	output reg [15:0] out;
	always @(posedge clk or  posedge reset )
		begin
			if(reset)
				out = 16'b0;
			else
				begin
					if(ld)
						out = in;
					else
						out = out;
				end	
		end
endmodule

module reg_16_1(in, clk, ld, reset, out);
	input wire [15:0] in;
	input clk, ld, reset;
	output reg [15:0] out;
	always @(posedge clk or  posedge reset )
		begin
			if(reset)
				out = 16'b1111111111111000;
			else
				begin
					if(ld)
						out = in;
					else
						out = out;
				end	
		end
endmodule