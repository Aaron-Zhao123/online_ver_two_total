module computation_control_v2(
clk,
x_in,
y_in,
enable_comp,
counter,
shift_cnt,
rest_cycle,
rd_addr,
asyn_reset,
enable,
add_enable,
res_enable,
finish_vec,
x_value,
y_value
);

parameter unrolling = 64;
parameter online_delay = 2;
parameter IDLE = 2'b00;
parameter COMP = 2'b01;
parameter REST = 2'b10;
parameter ADDR_WIDTH=7;

input enable_comp;
input [1:0] x_in, y_in;
input asyn_reset;
input clk;

output [1:0] x_value, y_value;
output enable;
output add_enable;
output [10:0] counter;
output [10:0] shift_cnt;
output res_enable;

output [(ADDR_WIDTH-1):0] rest_cycle;
output [(ADDR_WIDTH-1):0] rd_addr;
output finish_vec;

reg finish_vec;
reg enable;
reg add_enable;
reg res_enable;
reg [1:0] x_value, y_value;
reg [10:0] counter;
reg [(ADDR_WIDTH-1):0] accum;
reg [(ADDR_WIDTH-1):0] rest_cycle;
reg [1:0] STATE;
reg [10:0] shift_cnt;
reg [(ADDR_WIDTH-1):0] rd_addr;

initial begin
	counter <= 0;
	accum <= 0;	
	STATE <= IDLE;
	x_value <= 0;
	y_value <= 0;
	rest_cycle = 0;
	rd_addr = 0;
	res_enable = 0;
end

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		counter <= 0;
		accum <= 0;
		rest_cycle = 0;
		finish_vec = 0;
	end
	else begin
		if (enable_comp) begin
			case (STATE) 
				IDLE: begin
					if (counter >= unrolling + online_delay) begin
						STATE <= COMP;
						accum <= accum + 1;
						counter <= 0;
						rest_cycle = 1;
					end
					else begin
						counter <= counter + 1;
						x_value <= x_in;
						y_value <= y_in;
						finish_vec = 0;
					end
					if (counter >= unrolling + online_delay - 1) begin
						finish_vec = 1;
					end
					else begin
						finish_vec = 0;
					end
				end
				COMP: begin
					STATE <= REST; 
					x_value <= x_in;
					y_value <= y_in;
					if (counter >= unrolling) begin
						accum <= accum + 1;
						counter <= 0;
						finish_vec = 1;	
					end
					else begin
						finish_vec = 0;
					end
					rest_cycle = rest_cycle - 1;
				end
				REST: begin
					counter <= counter + 1;
					if (rest_cycle == 0) begin
						STATE <= COMP; 
						rest_cycle = accum;
					end
					else begin
						rest_cycle = rest_cycle - 1;
					end
				end
			endcase
		end
	end
end

always @ (*)begin
	case (STATE) 
		IDLE: begin
			add_enable <= 0;
			enable <= 1;
			shift_cnt <= 64 - counter;
			if (finish_vec) begin
				rd_addr <= 1;
			end
			else begin
				rd_addr <= 0;
			end
			res_enable = 1;
		end
		COMP: begin
			add_enable <= 1;
			enable <= 1;
			shift_cnt <= 63 - counter;
			rd_addr <= rest_cycle - 1;
			res_enable = 1;
		end
		REST: begin
			enable <= 0;
			shift_cnt <= 63 - counter;
			if (rest_cycle == 0) begin
				add_enable <= 1;
				if (finish_vec) begin
					rd_addr <= accum;
				end
				else begin
					rd_addr <= accum;
				end
			end
			else begin
				add_enable <= 0;
				rd_addr <= rest_cycle - 1;
			end
			res_enable = 1;
		end
	endcase
end

endmodule

