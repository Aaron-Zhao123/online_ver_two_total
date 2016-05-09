module D_flipflop (enable,clk,in,out);
	input in,clk;
	input enable;
	output out;
	reg out;
	
	initial begin
		out<=1'b0;
	end

	
	always@(posedge clk) begin
		if (enable == 1) begin
			out<=in;
		end
	end
	
	
	endmodule
	
	