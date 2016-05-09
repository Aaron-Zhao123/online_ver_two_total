`timescale 1ns/1ps
module testbench_mult_hd();

reg clk;
reg asyn_reset;
reg[1:0] x_value, y_value;
reg enable;
wire [1:0] p_value;

integer data_value_file_x,data_value_file_y;
integer scan_file_x,scan_file_y;
integer control=0;
integer cnt=0;

initial begin
	clk=1;
	while(1) begin
		#10 clk=~clk;
		cnt = cnt + 1;
	end
end
initial begin
  data_value_file_x=$fopen("/home/aaron/verilog/Online_ver_two/mult_hd/mul_ver_two/x_value_th.txt","r");
  
  data_value_file_y=$fopen("/home/aaron/verilog/Online_ver_two/mult_hd/mul_ver_two/y_value_th.txt","r");
  asyn_reset <= 1;
  enable <= 1;
end
initial begin 
	scan_file_x=$fscanf(data_value_file_x,"%b",x_value);
	scan_file_y=$fscanf(data_value_file_y,"%b",y_value);
end

Multiplier_v2 mult(
	x_value,
	y_value,
	clk,
	asyn_reset,
	enable,
	p_value
);

always@(negedge clk) begin
	asyn_reset <= 0;
	scan_file_y=$fscanf(data_value_file_y,"%b",y_value);
	scan_file_x=$fscanf(data_value_file_x,"%b",x_value);
end


endmodule
