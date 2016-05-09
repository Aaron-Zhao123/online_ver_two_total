module on_line_adder_block(x_plus,x_minus,y_plus,y_minus,cin,cout,carry_out,sum_out);

input x_plus,x_minus,y_plus,y_minus,cin;
output cout,carry_out,sum_out;

wire temp;


full_adder FA1(x_plus,~x_minus,y_plus,cout,temp);
full_adder FA2(temp,~y_minus,cin,carry_out,sum_out);

endmodule
	