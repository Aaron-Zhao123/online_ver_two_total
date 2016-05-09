module v_frac_logic(
clk,
enable,
asyn_reset,
q_plus_vec,
q_minus_vec,
w_plus_frac,
w_minus_frac,
x_value,
rd_addr,
shift_to_int_plus,
shift_to_int_minus,
v_plus_frac,
v_minus_frac,
compare_frac
);

parameter unrolling = 64;
parameter online_delay = 3;
parameter ADDR_WIDTH = 7;
parameter UPPER_WIDTH = 5;

input clk, enable, asyn_reset;
input [1:0] x_value;
input [unrolling - 1 :0] q_plus_vec, q_minus_vec, w_plus_frac, w_minus_frac;
input [ADDR_WIDTH-1:0] rd_addr;

output [1:0] shift_to_int_plus, shift_to_int_minus;
output [unrolling-1:0] v_plus_frac, v_minus_frac;
output compare_frac;

wire [1:0] cout_one;
wire [unrolling-1:0] tmp_plus_frac, tmp_minus_frac;
reg [1:0] cin_one;
reg [1:0] shift_to_int_plus, shift_to_int_minus;
reg [unrolling-1:0] v_plus_frac, v_minus_frac;

four_bits_adder add(
q_plus_vec,
q_minus_vec,
w_plus_frac,
w_minus_frac,
tmp_plus_frac,
tmp_minus_frac,
cin_one,
cout_one
);
defparam add.bits = unrolling;

assign compare_frac = (v_plus_frac >= v_minus_frac)? 1:0; 

initial begin
	cin_one <= 0;
	shift_to_int_plus  = 0;
	shift_to_int_minus = 0;
end

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		cin_one <= 0;
	end
	else begin
		if (enable) begin
			if (rd_addr == 0) begin
				cin_one <= 0;
			end
			else begin
				cin_one <= cout_one;
			end
		end
	end
end

always @ (*) begin
	if (rd_addr == 0) begin
		v_plus_frac[unrolling-2:0] = tmp_plus_frac[unrolling-2:0];
		v_minus_frac[unrolling-2:0] = tmp_minus_frac[unrolling-2:0];
		{shift_to_int_plus, v_plus_frac[unrolling-1]} = {cout_one[1],tmp_plus_frac[unrolling-1]} + x_value[1];
		{shift_to_int_minus, v_minus_frac[unrolling-1]} = {cout_one[0],tmp_minus_frac[unrolling-1]} + x_value[0];
	
	end
	else begin
		shift_to_int_plus = 0;
		shift_to_int_minus = 0;
		v_plus_frac = tmp_plus_frac;
		v_minus_frac = tmp_minus_frac;
	end
end

endmodule

module v_int_logic(
shift_to_int_plus,
shift_to_int_minus,
w_plus_int,
w_minus_int,
v_int_plus,
v_int_minus,
q_value,
compare_frac
);

parameter unrolling = 64;
parameter upper_width = 4; 
parameter online_delay = 3;
parameter ADDR_WIDTH = 7;
parameter UPPER_WIDTH = 5;

input [1:0] shift_to_int_plus, shift_to_int_minus;
input [UPPER_WIDTH-1:0] w_plus_int, w_minus_int;
input compare_frac;
output [UPPER_WIDTH-1:0] v_int_plus, v_int_minus;
output [1:0] q_value;
wire [UPPER_WIDTH-1:0] v_value;

reg [1:0] q_value;

assign v_int_plus = w_plus_int + shift_to_int_plus;
assign v_int_minus = w_minus_int + shift_to_int_minus;
assign v_value = v_int_plus - v_int_minus + compare_frac - 1;

always @ (*) begin
	case (v_value[UPPER_WIDTH-1:UPPER_WIDTH-4])
		4'b0111: q_value <= 2'b10;
		4'b0110: q_value <= 2'b10;
		4'b0101: q_value <= 2'b10;
		4'b0100: q_value <= 2'b10;
		4'b0011: q_value <= 2'b10;
		4'b0010: q_value <= 2'b10;
		4'b0001: q_value <= 2'b10;
		4'b0000: q_value <= 2'b00;
		4'b1111: q_value <= 2'b00;
		4'b1110: q_value <= 2'b01;
		4'b1101: q_value <= 2'b01;
		4'b1100: q_value <= 2'b01;
		4'b1011: q_value <= 2'b01;
		4'b1010: q_value <= 2'b01;
		4'b1001: q_value <= 2'b01;
		4'b1000: q_value <= 2'b01;
	endcase
end

endmodule
