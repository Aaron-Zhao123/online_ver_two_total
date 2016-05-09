module V_frac_bits_v2(
clk,
enable, // a different enable
rd_addr,
wr_addr,
asyn_reset,
v_plus_frac,
v_minus_frac,
w_plus_frac,
w_minus_frac,
shift_out
);
parameter ADDR_WIDTH=7;
parameter UPPER_WIDTH = 5;
parameter UNROLLING = 64;
input clk;
input enable;
input asyn_reset;
input [ADDR_WIDTH-1:0] rd_addr, wr_addr;
input [UNROLLING-1:0] v_plus_frac,v_minus_frac;

output [UNROLLING-1:0] w_plus_frac, w_minus_frac;
output [1:0] shift_out;
reg [UNROLLING-1:0] w_plus_frac, w_minus_frac;
reg [UNROLLING-1 :0] residue_plus_reg [2**ADDR_WIDTH-1 :0];
reg [UNROLLING-1 :0] residue_minus_reg [2**ADDR_WIDTH-1 :0];
reg [1:0] local_shift_in, local_shift_out;

integer i;
initial begin
	for (i = 0; i< 2 ** ADDR_WIDTH-1; i = i+1) begin
		residue_plus_reg[i] = 0;
		residue_minus_reg[i] = 0;
	end
	w_plus_frac = 0;
	w_minus_frac = 0;
	local_shift_out = 0;
end

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		for (i = 0; i< 2 ** ADDR_WIDTH-1; i = i+1) begin
			residue_plus_reg[i] = 0;
			residue_minus_reg[i] = 0;
		end
	end
	else begin
		local_shift_in = 0;
		if (enable) begin
			if (wr_addr == 0) begin
				local_shift_in = 0;
				residue_plus_reg[wr_addr] = {v_plus_frac[UNROLLING-2:0],local_shift_in[1]};
		       		residue_minus_reg[wr_addr] = {v_minus_frac[UNROLLING-2:0],local_shift_in[0]};
				w_plus_frac = residue_plus_reg [rd_addr];
				w_minus_frac = residue_minus_reg [rd_addr];	
				local_shift_out = {v_plus_frac[UNROLLING-1],v_minus_frac[UNROLLING-1]};
			end
			else begin
				local_shift_in = local_shift_out;
				residue_plus_reg[wr_addr] = {v_plus_frac[UNROLLING-2:0],local_shift_in[1]};
		       		residue_minus_reg[wr_addr] = {v_minus_frac[UNROLLING-2:0],local_shift_in[0]};
				w_plus_frac = residue_plus_reg [rd_addr];
				w_minus_frac = residue_minus_reg [rd_addr];	
				local_shift_out = {v_plus_frac[UNROLLING-1],v_minus_frac[UNROLLING-1]};
			end
		end
	end
end
assign shift_out = {v_plus_frac[UNROLLING-1],v_minus_frac[UNROLLING-1]};
	
endmodule

