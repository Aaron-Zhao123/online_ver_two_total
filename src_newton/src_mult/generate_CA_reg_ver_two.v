module generate_CA_reg_v2 (
enable,
refresh,
asyn_reset,
clk,
x_in,
y_in,
x_plus_dis,
x_minus_dis,
y_plus_rd,
y_minus_rd,
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
input [1:0] x_in, y_in;
input [10:0] counter;
input refresh;
input [10:0] shift_cnt;
input [(ADDR_WIDTH-1):0] wr_addr,rd_addr;

output [unrolling -1 :0] x_plus_dis, x_minus_dis, y_plus_rd, y_minus_rd;

reg [unrolling-1:0] x_plus_rd, x_minus_rd;
reg [unrolling-1:0] x_plus_dis, x_minus_dis;
reg [unrolling -1 :0] x_plus_delay, x_minus_delay, y_plus_rd, y_minus_rd;
reg [unrolling -1 :0] x_plus_wr, x_minus_wr, y_plus_wr, y_minus_wr;
reg [unrolling -1 :0] x_plus_wr_rev, x_minus_wr_rev, y_plus_wr_rev, y_minus_wr_rev;
reg [1:0] x_value, y_value;
reg [unrolling -1 :0] x_plus_ram [2**ADDR_WIDTH-1:0];
reg [unrolling -1 :0] x_minus_ram [2**ADDR_WIDTH-1:0];
reg [unrolling -1 :0] y_plus_ram [2**ADDR_WIDTH-1:0];
reg [unrolling -1 :0] y_minus_ram [2**ADDR_WIDTH-1:0];
reg wr_enable;
//wire[10:0] shift_cnt;


//assign shift_cnt = 64 - counter -1;
always @ (*) begin
	wr_enable = enable;
end

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		x_value = 0;
		y_value = 0;
	end
	else begin
		if (enable) begin
			x_value = x_in;
			y_value = y_in;
		end
	end
end

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		x_plus_delay = 0;
		x_minus_delay = 0;
	end
	else begin
		if (wr_enable) begin
			x_plus_delay = x_plus_rd;
			x_minus_delay = x_minus_rd;
		end
	end
end
always @ (*) begin
	if (wr_enable) begin
		x_plus_dis = x_plus_delay;
		x_minus_dis = x_minus_delay;
	end
	else begin
		x_plus_dis = x_plus_rd;
		x_minus_dis = x_minus_rd;
	end
end
	
initial begin
	x_plus_wr = 0;
	x_minus_wr = 0;
	y_plus_wr = 0;
	y_minus_wr = 0;
	x_plus_wr_rev = 0;
	x_minus_wr_rev = 0;
	y_plus_wr_rev = 0;
	y_minus_wr_rev = 0;
	y_plus_rd = 0;
	y_minus_rd = 0;
end

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		x_plus_wr = 0;
		x_minus_wr = 0;
		y_plus_wr = 0;
		y_minus_wr = 0;
	end
	else begin
		if (enable) begin
			if (refresh && (rd_addr == 0)) begin
				x_plus_wr[unrolling-2:0] = 0;
				x_minus_wr[unrolling-2:0] = 0;
				y_plus_wr[unrolling-1:1]= 0;
				y_minus_wr[unrolling-1:1]= 0;
				x_plus_wr[0] = x_value[1];
				x_minus_wr[0] = x_value[0];
				y_plus_wr[0]= y_value[1];
				y_minus_wr[0]= y_value[0];
				x_plus_wr_rev = {63'b0,x_value[1]} << shift_cnt;
				x_minus_wr_rev = {63'b0,x_value[0]} << shift_cnt;
				y_plus_wr_rev = {63'b0,y_value[1]} << shift_cnt;
				y_minus_wr_rev = {63'b0,y_value[0]} << shift_cnt;
				x_plus_ram [wr_addr] = {63'b0,x_value[1]} << shift_cnt;
				x_minus_ram [wr_addr] = {63'b0,x_value[0]} << shift_cnt;
				y_plus_ram [wr_addr] = {63'b0,y_value[1]} << shift_cnt;
				y_minus_ram [wr_addr] = {63'b0,y_value[0]} << shift_cnt;
				x_plus_rd = x_plus_ram [rd_addr] ;
				x_minus_rd = x_minus_ram [rd_addr] ;
				y_plus_rd = y_plus_ram [rd_addr];
				y_minus_rd = y_minus_ram [rd_addr] ;

			end
			else begin
				x_plus_wr = {x_plus_wr[unrolling - 2:0],x_value[1]};
				x_minus_wr = {x_minus_wr[unrolling - 2:0],x_value[0]};
				y_plus_wr = {y_plus_wr[unrolling - 2:0],y_value[1]};
		        	y_minus_wr = {y_minus_wr[unrolling - 2:0],y_value [0]};
				x_plus_wr_rev = x_plus_wr << shift_cnt;
				x_minus_wr_rev = x_minus_wr << shift_cnt;
				y_plus_wr_rev = y_plus_wr << shift_cnt;
				y_minus_wr_rev = y_minus_wr << shift_cnt;
				x_plus_ram [wr_addr] = x_plus_wr_rev;
				x_minus_ram [wr_addr] = x_minus_wr_rev;
				y_plus_ram [wr_addr] = y_plus_wr_rev;
				y_minus_ram [wr_addr] = y_minus_wr_rev;
				if (refresh & rd_addr!=0) begin
					x_plus_rd = 0;
					x_minus_rd = 0;
					y_plus_rd = 0;
					y_minus_rd = 0;
				end
				else begin
					x_plus_rd = x_plus_ram [rd_addr] ;
					x_minus_rd = x_minus_ram [rd_addr] ;
					y_plus_rd = y_plus_ram [rd_addr];
					y_minus_rd = y_minus_ram [rd_addr] ;
				end
			end	
		end
		else begin
			x_plus_rd = x_plus_ram [rd_addr] ;
			x_minus_rd = x_minus_ram [rd_addr] ;
			y_plus_rd = y_plus_ram [rd_addr];
			y_minus_rd = y_minus_ram [rd_addr] ;
		end
	end
end

endmodule
