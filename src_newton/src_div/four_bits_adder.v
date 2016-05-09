module four_bits_adder(x_plus,x_minus,y_plus,y_minus,z_plus,z_minus,cin,cout);

parameter bits=64;


input[bits-1:0] x_plus,x_minus,y_plus,y_minus;
input[1:0] cin;

output[bits-1:0] z_plus,z_minus;
output[1:0] cout;

genvar i;

wire[bits-1:0] carry_out,sum_out,cin_vec,cout_vec;


assign cout[1]=cout_vec[bits-1];
assign z_plus[bits-1:0]=sum_out;

assign cout[0]=~carry_out[bits-1];
assign z_minus[bits-1:1]=~carry_out[bits-2:0];
assign z_minus[0]=cin[0];

assign cin_vec[0]=cin[1];
assign cin_vec[bits-1:1]=cout_vec[bits-2:0];

generate
	for(i=0;i<bits;i=i+1) begin:adder_chain
			on_line_adder_block Block(x_plus[i],x_minus[i],y_plus[i],y_minus[i],cin_vec[i],cout_vec[i],carry_out[i],sum_out[i]);
			
	end
endgenerate

endmodule
