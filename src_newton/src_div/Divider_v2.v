module Divider_v2(
x_value,
d_value,
clk,
asyn_reset,
enable_all,
q_value
);

input [1:0] x_value, d_value;
input clk;
input asyn_reset;
input enable_all;

output [1:0] q_value;

parameter unrolling = 64;
parameter online_delay = 3;
parameter ADDR_WIDTH = 7;
parameter UPPER_WIDTH = 5;

wire [1:0] x_value_comp, d_value_comp;
wire refresh;
wire [10:0] counter, shift_cnt;
wire enable;
wire [unrolling-1:0] d_plus_vec, d_minus_vec;
wire [unrolling-1:0] d_plus_sel, d_minus_sel;
wire [unrolling-1:0] q_plus_vec, q_minus_vec;
wire [unrolling-1:0] q_plus_sel, q_minus_sel;
wire [unrolling-1:0] v_plus_frac, v_minus_frac, w_plus_frac, w_minus_frac;
wire [unrolling-1:0] tmp_plus, tmp_minus;
wire [UPPER_WIDTH-1:0] v_plus_int, v_minus_int, w_plus_int, w_minus_int;
wire [ADDR_WIDTH-1:0] wr_addr, rd_addr;
wire [1:0] q_value_comp;
wire [1:0] shift_to_int_plus, shift_to_int_minus;
wire comp_frac;
wire [1:0] q_value; 
wire [1:0] x_delay;

assign q_value = q_value_comp;
computation_control_v2_div comp(
clk,
x_value,
d_value,
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
d_value_comp
);

D_FF D_X(
x_value_comp,
x_delay,
clk,
enable,
asyn_reset
);
defparam D_X.delay=3;

generate_d_reg CA_d_reg(
enable,
refresh,
asyn_reset,
clk,
d_value_comp,
d_plus_vec,
d_minus_vec,
wr_addr,
rd_addr,
counter,
shift_cnt
);

generate_q_reg CA_q_reg(
enable,
refresh,
asyn_reset,
clk,
q_value_comp,
q_plus_vec,
q_minus_vec,
wr_addr,
counter,
shift_cnt
);

SDVM_v2_d SDVM_d(
d_plus_vec,
d_minus_vec, 
~q_value_comp, 
d_plus_sel,
d_minus_sel,
);

SDVM_v2_q SDVM_q(
clk,
q_plus_vec,
q_minus_vec, 
~d_value_comp, 
q_plus_sel,
q_minus_sel,
enable,
asyn_reset
);
defparam SDVM_q.DELAY= 3;

v_frac_logic frac_loigc(
clk,
enable,
asyn_reset,
q_plus_sel,
q_minus_sel,
w_plus_frac,
w_minus_frac,
x_delay,
rd_addr,
shift_to_int_plus,
shift_to_int_minus,
v_plus_frac,
v_minus_frac,
comp_frac
);

v_int_logic int_logic(
shift_to_int_plus,
shift_to_int_minus,
w_plus_int,
w_minus_int,
v_plus_int,
v_minus_int,
q_value_comp,
comp_frac
);

w_value_logic w_logic(
clk,
enable,
asyn_reset,
d_plus_sel,
d_minus_sel,
v_plus_frac,
v_minus_frac,
v_plus_int,
v_minus_int,
w_plus_frac,
w_minus_frac,
w_plus_int,
w_minus_int,
rd_addr,
wr_addr,
refresh
);

endmodule
