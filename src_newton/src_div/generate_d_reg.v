module generate_d_reg (
enable,
refresh,
asyn_reset,
clk,
d_in,
d_plus_rd,
d_minus_rd,
wr_addr,
rd_addr,
counter,
shift_cnt
);

parameter unrolling  = 64;
parameter online_delay = 3;
parameter ADDR_WIDTH=7;

input enable;
input asyn_reset;
input clk;
input [1:0] d_in;
input [(ADDR_WIDTH -1):0] wr_addr, rd_addr;
input [10:0] counter;
input refresh;
input [10:0] shift_cnt;

output [unrolling -1 :0] d_plus_rd, d_minus_rd;

wire [unrolling-1:0] d_plus_rd, d_minus_rd;
reg [unrolling -1 :0] d_plus_wr, d_minus_wr; 
reg [unrolling -1 :0] d_plus_wr_rev, d_minus_wr_rev;
reg [1:0] d_value;


reg wr_enable;


always @ (*) begin
	if (refresh == 1 && wr_addr == 0) begin
		wr_enable = 0;
	end
	else begin
		wr_enable = enable;
	end
end

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		d_value <= 0;
	end
	else begin
		if (enable) begin
			d_value <= d_in;
		end
	end
end

initial begin
	d_plus_wr <= 0;
	d_minus_wr <= 0;
	d_plus_wr_rev <= 0;
	d_minus_wr_rev <= 0;
end

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		d_plus_wr = 0;
		d_minus_wr = 0;
		d_plus_wr_rev = 0;
		d_minus_wr_rev = 0;
	end
	else begin
		if (wr_enable) begin
			d_plus_wr = {d_plus_wr[unrolling - 2:0],d_value[1]};
			d_minus_wr = {d_minus_wr[unrolling - 2:0],d_value[0]};
			d_plus_wr_rev = d_plus_wr << shift_cnt;
			d_minus_wr_rev = d_minus_wr << shift_cnt;
		end
		if (refresh) begin
			d_plus_wr[unrolling-1:1] = 0;
			d_minus_wr[unrolling-1:1] = 0;
			if (wr_enable) begin
				d_plus_wr[0] = d_value[1];
				d_minus_wr[0] = d_value[0];
			end
			else begin
				d_plus_wr[0] = 0; 
				d_minus_wr[0] = 0;
			end
			d_plus_wr_rev = d_plus_wr << 63;
			d_minus_wr_rev = d_minus_wr << 63;
		end
			
	end
end

single_clk_ram_64bits ram1(
	d_plus_wr_rev,
	wr_addr,
	rd_addr,
	wr_enable,
	asyn_reset,
	clk,
	d_plus_rd
);
single_clk_ram_64bits ram2(
	d_minus_wr_rev,
	wr_addr,
	rd_addr,
	wr_enable,
	asyn_reset,
	clk,
	d_minus_rd
);

endmodule
