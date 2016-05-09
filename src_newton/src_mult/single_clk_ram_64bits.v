module single_clk_ram_64bits(
data,
write_addr,
read_addr,
we,
async_clear,
clk,
q
);

parameter DATA_WIDTH=64;
parameter ADDR_WIDTH=7;
input[(DATA_WIDTH-1):0] data;
input[(ADDR_WIDTH-1):0] write_addr;
input[(ADDR_WIDTH-1):0] read_addr;
input we,clk;
input async_clear;
output[(DATA_WIDTH-1):0] q;
	


// this module creates a RAM of size (4*4)*128,with initially all zeros
reg[DATA_WIDTH-1:0] mem[2**ADDR_WIDTH-1:0];
reg[ADDR_WIDTH-1:0] addr_reg;

integer i;

initial begin
	for (i=0;i<2**ADDR_WIDTH;i=i+1) begin
		mem[i] = 0; // initial 0
	end
	addr_reg <= 0;	
end

always@(posedge clk or posedge async_clear)begin
	if (async_clear == 1) begin
		for (i=0;i<2**ADDR_WIDTH;i=i+1) begin
			mem[i] = 0; // initial 0
		end
		addr_reg <= 0;	
		mem[read_addr] <= 0;
	end
	else begin
		if(we)
			mem[write_addr] <=data;
		addr_reg<=read_addr;
	end
end
assign q = mem[addr_reg]; //q does not get d in this clock cycle if we is high


endmodule
