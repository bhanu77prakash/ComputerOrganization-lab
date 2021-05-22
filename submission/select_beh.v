module selection ( dsel, zin, zin1, cin, cin1, vin, vin1, sin, sin1, out);
	input zin, zin1, cin, cin1, vin, vin1, sin, sin1;
	input [3:0] dsel;
	wire uncond;
	output out;
	assign uncond = 1;
	mux_921 select(uncond, zin, zin1, cin, cin1, vin, vin1, sin, sin1, out);
endmodule

module mux_921(uncond, zin, zin1, cin, cin1, vin, vin1, sin, sin1, out, dsel);
	input [3:0] dsel;
	input zin, zin1, cin, cin1, vin, vin1, sin, sin1, uncond;
	output reg out;
	always @*
		begin
			case (dsel)
				2:
					begin
						out = uncond;
					end
				3:
					begin
						out  = cin;
					end
				4:
					begin
						out = cin1;
					end
				5:
					begin
						out = zin;
					end
				6:
					begin
						out = zin1;
					end
				7:
					begin
						out = vin;
					end
				8:
					begin
						out = vin1;
					end
				9:
					begin
						out = sin;
					end
				10:
					begin
						out = sin1;
					end
			endcase
		end
endmodule