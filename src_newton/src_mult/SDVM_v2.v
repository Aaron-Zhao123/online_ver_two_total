module SDVM_v2
(
clk,
vec_in_plus,
vec_in_minus, 
digit_select, 
vec_out_plus,
vec_out_minus,
enable,
asyn_reset);

parameter unrolling=64;

input enable;
input clk;
input asyn_reset;
input [unrolling-1:0] vec_in_plus,vec_in_minus;
input[1:0] digit_select;
output [unrolling-1:0] vec_out_plus,vec_out_minus;

reg [unrolling-1:0] vec_out_plus,vec_out_minus;
wire [1:0] digit_sel_delay,select; 
//reg[2:0] detect;
//reg signal;


D_FF D1(
digit_select,
digit_sel_delay,
clk,
enable,
asyn_reset
);
defparam D1.delay = 1;

assign select = digit_sel_delay | 2'b00;
	
always@* begin
	if (asyn_reset) begin
		vec_out_plus <= 0;
		vec_out_minus <= 0;
	end
	else begin
		case(digit_sel_delay)
			2'b00: begin
				vec_out_plus<=0;
				vec_out_minus<=0;
			end
			2'b10: begin 
				vec_out_plus<=vec_in_plus;
				vec_out_minus<=vec_in_minus;//if digit is 1
			end
			2'b01: begin
				vec_out_plus<=~vec_in_plus;
				vec_out_minus<=~vec_in_minus;//if digit is -1
			end
			default: begin 
				vec_out_plus<=0;
				vec_out_minus<=0;
			end
		endcase
	end
end

endmodule
