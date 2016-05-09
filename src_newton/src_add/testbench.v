`timescale 1ns/1ps  
module testbench();

reg clk;
wire[1:0] data_out;
reg[1:0] x_in,y_in;
reg asyn_reset;

integer data_in_file_x,data_in_file_y;
integer scan_file_x,scan_file_y;
integer control=0;
integer cnt=0;
/*
Online_adder_hd adder(
x_in,
y_in,
clk,
data_out,
asyn_reset,
handshake,
data_x_vld,
data_x_rdy,
data_y_vld,
data_y_rdy,
data_out_vld,
data_out_rdy);
*/
initial begin
	clk=1;
	while(1) begin
		#10 clk=~clk;
		cnt = cnt + 1;
	end
end
// clock module, 50Mhz clk

Online_adder_hd adder(
	x_in,
	y_in,
	clk,
	data_out,
	asyn_reset
);
initial begin
  data_in_file_x=$fopen("/home/aaron/verilog/Online_ver_two/add_hd/Online_adder_hd/x_value.txt","r");
  
  data_in_file_y=$fopen("/home/aaron/verilog/Online_ver_two/add_hd/Online_adder_hd/y_value.txt","r");
  asyn_reset <= 1;
end
initial begin 
	scan_file_x=$fscanf(data_in_file_x,"%b",x_in);
	scan_file_y=$fscanf(data_in_file_y,"%b",y_in);
end
always@(negedge clk) begin
	asyn_reset <= 0;
	scan_file_y=$fscanf(data_in_file_y,"%b",y_in);
	scan_file_x=$fscanf(data_in_file_x,"%b",x_in);
end

endmodule
