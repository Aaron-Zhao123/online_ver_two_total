module Multiplier_v2(
	x_value,
	y_value,
	clk,
	asyn_reset,
	enable_all,
	p_value
);

parameter unrolling = 64;
parameter ADDR_WIDTH=7;
parameter UPPER_WIDTH = 5;

input [1:0] x_value;
input [1:0] y_value;
input clk;
input asyn_reset;
input enable_all;
output [1:0] p_value;

wire[1:0] x_value_comp,y_value_comp;
wire[1:0] x_value_delay,y_value_delay;
wire [10:0] counter, shift_cnt;
wire [(ADDR_WIDTH-1):0] wr_addr,rd_addr;
wire enable;
wire refresh;
wire [unrolling-1 :0] x_plus_vec, x_minus_vec, y_plus_vec, y_minus_vec; 
wire [unrolling-1 :0] x_plus_vec_sel, x_minus_vec_sel, y_plus_vec_sel, y_minus_vec_sel; 
wire [unrolling-1 :0] w_plus, w_minus, v_plus, v_minus;
wire [1:0] cin_one_frac, cin_two_frac, cout_one_frac, cout_two_frac;

wire [1:0] cin_one_int, cin_two_int, cout_one_int, cout_two_int;
wire [UPPER_WIDTH - 1 :0] x_plus_int, x_minus_int, y_plus_int, y_minus_int; 
wire [UPPER_WIDTH - 1 :0] w_plus_int, w_minus_int, v_plus_int, v_minus_int;
wire compare_frac, compare_int;
wire add_enable;
wire res_enable;
wire [1:0] shift_in;

computation_control_v2 comp(
clk,
x_value,
y_value,
enable_all,
counter,
shift_cnt,
wr_addr,
rd_addr,
asyn_reset,
enable,
add_enable,
res_enable,
refresh,
x_value_comp,
y_value_comp
);

generate_CA_reg_v2 CA_reg(
enable,
refresh,
asyn_reset,
clk,
x_value_comp,
y_value_comp,
x_plus_vec,
x_minus_vec,
y_plus_vec,
y_minus_vec,
wr_addr,
rd_addr,
counter,
shift_cnt
);

/*
D_FF D1(
x_value_comp,
x_value_delay,
clk,
enable,
asyn_reset
);
defparam D1.delay = 4;

D_FF D2(
y_value_comp,
y_value_delay,
clk,
enable,
asyn_reset
);
defparam D2.delay = 4;
*/


SDVM_v2 SDVM_x_vec(
clk,
x_plus_vec,
x_minus_vec, 
y_value_comp, 
x_plus_vec_sel,
x_minus_vec_sel,
enable,
asyn_reset);

SDVM_v2 SDVM_y_vec(
clk,
y_plus_vec,
y_minus_vec, 
x_value_comp, 
y_plus_vec_sel,
y_minus_vec_sel,
enable,
asyn_reset);


assign cin_one_frac = 0;
assign cin_two_frac = 0;
assign cin_one_int = cout_one_frac;
assign cin_two_int = cout_two_frac;
assign x_plus_int = 0;
assign x_minus_int = 0;
assign y_plus_int = 0;
assign y_minus_int = 0;

four_bits_parallel_adder adder(
x_plus_vec_sel,
x_minus_vec_sel,
y_plus_vec_sel,
y_minus_vec_sel,
w_plus,
w_minus,
v_plus,
v_minus,
cin_one_frac,
cin_two_frac,
cout_one_frac,
cout_two_frac,
compare_frac
);

add_control add_control(
clk,
add_enable,
asyn_reset,
cin_one_frac,
cin_two_frac,
cout_one_frac,
cout_two_frac
);


four_bits_parallel_adder adder_int (
x_plus_int,
x_minus_int,
y_plus_int,
y_minus_int,
w_plus_int,
w_minus_int,
v_plus_int,
v_minus_int,
cin_one_int,
cin_two_int,
cout_one_int,
cout_two_int,
compare_int
);
defparam adder_int.bits = UPPER_WIDTH;

V_upper_bits_v2 V_block(
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

V_frac_bits_v2 V_block_frac( 
clk,
res_enable, // a different enable
rd_addr,
wr_addr,
asyn_reset,
v_plus,
v_minus,
w_plus,
w_minus,
shift_in
);
endmodule

