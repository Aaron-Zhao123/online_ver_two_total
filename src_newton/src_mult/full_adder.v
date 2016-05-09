module full_adder (a,b,cin,cout,sum);
	
	output cout,sum;
	input a,b,cin;
	
	assign {cout,sum}=a+b+cin;
	
endmodule
