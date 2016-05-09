module add_control (
	clk,
	add_enable,
	asyn_reset,
	cin_one_frac,
	cin_two_frac,
	cout_one_frac,
	cout_two_frac
);

input clk;
input add_enable;
input asyn_reset;
input[1:0] cout_two_frac, cout_one_frac;
output [1:0] cin_one_frac, cin_two_frac;
reg [1:0] cin_one_frac, cin_two_frac; 


always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		cin_one_frac <= 0;
		cin_two_frac <= 0;
	end
	else begin
		if (add_enable) begin
			cin_one_frac <= cout_one_frac;
			cin_two_frac <= cout_two_frac;
		end
		else begin
			cin_one_frac <= 0;
			cin_two_frac <= 0;
		end
	end
end

endmodule
