module generate_q_reg (
enable,
refresh,
asyn_reset,
clk,
q_value,
q_plus_rd,
q_minus_rd,
accum,
counter,
shift_cnt
);

parameter unrolling  = 64;
parameter online_delay = 3;
parameter ADDR_WIDTH=7;

input enable;
input asyn_reset;
input clk;
input [1:0] q_value;
input [(ADDR_WIDTH -1):0] accum;
input [10:0] counter;
input refresh;
input [10:0] shift_cnt;

output [unrolling -1 :0] q_plus_rd, q_minus_rd;

reg [unrolling -1 :0] q_plus_wr, q_minus_wr; 
reg [unrolling -1 :0] q_plus_wr_rev, q_minus_wr_rev;
reg [unrolling -1 :0] q_plus_ram [2**ADDR_WIDTH-1:0];
reg [unrolling -1 :0] q_minus_ram [2**ADDR_WIDTH-1:0];

reg [unrolling-1:0] q_plus_rd, q_minus_rd;
wire wr_enable;
wire [(ADDR_WIDTH-1):0] addr;

assign addr = accum;
assign wr_enable = enable;
initial begin
	q_plus_wr = 0;
	q_minus_wr = 0;
	q_plus_wr_rev = 0;
	q_minus_wr_rev = 0;
	q_plus_rd = 0;
	q_minus_rd = 0;
end

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		q_plus_wr = 0;
		q_minus_wr = 0;
		q_plus_wr_rev = 0;
		q_minus_wr_rev = 0;
	end
	else begin
		if (enable) begin
			if (refresh) begin
				q_plus_wr[unrolling-2:0] = 0;
				q_minus_wr[unrolling-2:0] = 0;
				q_plus_wr[unrolling -1] = q_value[1];
				q_minus_wr[unrolling -1] = q_value[0];
			end
			else begin
				q_plus_wr = {q_plus_wr[unrolling - 2:0],q_value[1]};
				q_minus_wr = {q_minus_wr[unrolling - 2:0],q_value[0]};
				q_plus_wr_rev = q_plus_wr << (shift_cnt+5);
				q_minus_wr_rev = q_minus_wr << (shift_cnt+5);
				q_plus_ram[addr] = q_plus_wr_rev;
				q_minus_ram[addr] = q_minus_wr_rev;
				q_plus_rd = q_plus_ram[addr];
				q_minus_rd = q_minus_ram[addr];
			end	
		end
	end
end

endmodule
