module V_upper_bits_v2(
clk,
enable,
asyn_reset,
shift_in,
compare_frac,
rd_addr,
v_plus_int,
v_minus_int,
w_plus_int,
w_minus_int,
p_value
);
parameter ADDR_WIDTH=7;
parameter UPPER_WIDTH = 5;
input clk;
input enable;
input asyn_reset;
input compare_frac;
input[UPPER_WIDTH-1 :0] v_plus_int, v_minus_int;
input[1:0] shift_in;
input [ADDR_WIDTH-1:0] rd_addr;

output[UPPER_WIDTH-1 :0] w_plus_int, w_minus_int;
output [1:0] p_value;

reg [1:0] p_value;
reg [UPPER_WIDTH-1 :0] w_plus_int, w_minus_int;

wire [2:0] v_sample;
wire[UPPER_WIDTH-1 :0] v_upper_value;

assign v_upper_value = v_plus_int - v_minus_int - compare_frac;
assign v_sample = v_upper_value [UPPER_WIDTH-1:UPPER_WIDTH-3];
// M block
always @* begin
	case(v_sample)
		3'b011: p_value <= 2'b10;
		3'b010: p_value <= 2'b10;
		3'b001: p_value <= 2'b10;
		3'b000: p_value <= 2'b00;
		3'b111: p_value <= 2'b00;
		3'b110: p_value <= 2'b01;
		3'b101: p_value <= 2'b01;
		3'b100: p_value <= 2'b01;
	endcase
end
// M block done
// updating w_vec from v_vec
always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		w_plus_int <= 0;
		w_minus_int <= 0;
	end
	else begin
		if (rd_addr == 0) begin
			if (v_plus_int[UPPER_WIDTH-2] ^v_minus_int[UPPER_WIDTH-2] ^ p_value[1] ^ p_value[0]) begin
				w_plus_int[UPPER_WIDTH-1]= v_plus_int[UPPER_WIDTH-2]^ p_value[1];
				w_minus_int[UPPER_WIDTH-1] = v_minus_int[UPPER_WIDTH-2]^ p_value[0];
			end
			else begin
				w_plus_int[UPPER_WIDTH-1]= 0;
				w_minus_int[UPPER_WIDTH-1] = 0;	
			end
			w_plus_int[UPPER_WIDTH-2:0] = {v_plus_int[UPPER_WIDTH-3:0],shift_in[1]};
			w_minus_int[UPPER_WIDTH-2:0] = {v_minus_int[UPPER_WIDTH-3:0],shift_in[0]};
		end
	end
end
endmodule
