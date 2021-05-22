module ALU(XYBUS, Y, check, ZBUS, fsel, cin, zin, vin, sin);
	input [15:0] XYBUS, Y;
	input [2:0] fsel;
	output [15:0]check;
	output reg [15:0] ZBUS;
	//assign check = Y;
	output cin, zin, vin, sin;
	reg  ci, ci_1;
	reg [16:0] temp;
	reg [15:0] temp1;
	assign cin = ci;
	wire cin_1;
	assign cin_1 = ci_1;
	assign sin = ZBUS[15];
	//wire zout, zout1, vout, vout1, cout, cout1, sout, sout1;
	always @*
		begin
			case (fsel)
				3'b001: 
							begin
							temp = XYBUS + Y;
							temp1 = XYBUS[14:0] + Y[14:0];
							ci_1 = temp1[15];
							ZBUS  = XYBUS+Y;
							ci = temp[16];
							end
				3'b010: 
							begin
							ZBUS = XYBUS - Y;
							end
				3'b011: 
							begin
							ZBUS = (Y^16'b1111111111111111) + 1;
							ci = 0;
							end
				3'b100: 
							begin
							ZBUS = ~Y;
							ci = 0;
							end
				3'b101: 
							begin
							ZBUS = XYBUS|Y;
							ci = 0;
							end
				3'b110: 
							begin
							ZBUS = XYBUS;
							end
				3'b111:
							begin
							ZBUS = Y;
							end
			endcase
		end
	//status_det status(ZBUS, ci, ci_1, clk ,reset, vin ,zin);
	nor zero_det(zin,ZBUS[0],ZBUS[1],ZBUS[2],ZBUS[3],ZBUS[4],ZBUS[5],ZBUS[6],ZBUS[7],ZBUS[8],ZBUS[9],ZBUS[10],ZBUS[11],ZBUS[12],ZBUS[13],ZBUS[14],ZBUS[15]); 
	xor over_flow(vin, cin, cin_1);
endmodule