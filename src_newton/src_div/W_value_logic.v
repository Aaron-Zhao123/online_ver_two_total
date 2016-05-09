module w_value_logic(
clk,
enable,
asyn_reset,
d_plus_vec,
d_minus_vec,
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

parameter UNROLLING = 64;
parameter online_delay = 3;
parameter ADDR_WIDTH = 7;
parameter UPPER_WIDTH = 5;

input clk;
input enable;
input asyn_reset;
input refresh;
input [UNROLLING-1:0] d_plus_vec, d_minus_vec;
input [UNROLLING-1:0] v_plus_frac, v_minus_frac;
input [ADDR_WIDTH-1:0] rd_addr, wr_addr;
input [UPPER_WIDTH-1:0]  v_plus_int, v_minus_int;

output [UNROLLING-1:0] w_plus_frac, w_minus_frac;
output [UPPER_WIDTH-1:0] w_plus_int, w_minus_int;

wire [1:0] cout_one;
wire [UNROLLING-1:0] tmp_plus_frac, tmp_minus_frac;
wire [UNROLLING-1:0] w_plus_store, w_minus_store;
wire [1:0] local_shift_out;

reg [UPPER_WIDTH-1:0] w_plus_int, w_minus_int;
reg [UNROLLING-1:0] w_plus_frac, w_minus_frac;
reg [UNROLLING-1 :0] residue_plus_reg [0:2**ADDR_WIDTH-1];
reg [UNROLLING-1 :0] residue_minus_reg [0:2**ADDR_WIDTH-1];
reg [2:0] d_plus_append, d_minus_append;
reg [1:0] local_shift_in, shift_int_plus, shift_int_minus;
reg [1:0] cin_one;
reg wr_enable;
reg refresh_delay;

always @ (posedge clk) begin
	refresh_delay = refresh;
end

always @ (*) begin
	if (enable) begin
		if (refresh) begin
			wr_enable = 0;	
		end
		else begin
			wr_enable = 1;
		end
	end
	else begin
		if (refresh_delay) begin
			wr_enable = 0;
		end
		else begin
			wr_enable = 1;
		end
	end
end


// Frac part
integer i;
initial begin
	//$readmemh("mem.list",residue_plus_reg);
	//$readmemh("mem.list",residue_minus_reg);	
	for (i = 0; i< 2 ** ADDR_WIDTH-1; i = i+1) begin
		residue_plus_reg[i] = 0;
		residue_minus_reg[i] = 0;
	end	

	residue_plus_reg[0] = 0;
	residue_minus_reg[0] = 0;

end

four_bits_adder add(
v_plus_frac,
v_minus_frac,
tmp_plus_frac,
tmp_minus_frac,
w_plus_store,
w_minus_store,
cin_one,
cout_one
);
defparam add.bits = UNROLLING;

assign tmp_plus_frac = {d_plus_vec[UNROLLING-1-3:0],d_plus_append};
assign tmp_minus_frac = {d_minus_vec[UNROLLING-1-3:0],d_minus_append};

initial begin
	d_plus_append = 0;
	d_minus_append = 0;
	w_plus_frac = 0;
	w_minus_frac = 0;
	local_shift_in = 0;
	shift_int_plus = 0;
	shift_int_minus = 0;
end

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		cin_one = 0; 
	end
	else begin
		if (wr_enable) begin
			if (rd_addr == 0) begin
				cin_one = 0;
			end
			else begin
				cin_one = cout_one;	
			end
		end
	end
end

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		d_plus_append = 0;
		d_minus_append = 0;
		residue_plus_reg[0] = 0;
		residue_minus_reg[0] = 0;
	end
	else begin
		if (rd_addr == 0) begin
			d_plus_append = 0;
			d_minus_append = 0;
		end
		else begin
			d_plus_append = d_plus_vec[UNROLLING-1:UNROLLING-3];
			d_minus_append = d_minus_vec[UNROLLING-1:UNROLLING-3];
		end
	end
end

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		w_plus_frac = 0;
		w_minus_frac = 0;
	end
	else begin
		if (wr_enable) begin
			if (wr_addr == 0) begin
				local_shift_in = 0;
			end
			else begin
				local_shift_in = local_shift_out;
			end
			residue_plus_reg[wr_addr] = {w_plus_store[UNROLLING-2:0],local_shift_in[1]};      
			residue_minus_reg[wr_addr] = {w_minus_store[UNROLLING-2:0],local_shift_in[0]};

			w_plus_frac = residue_plus_reg [rd_addr];
			w_minus_frac = residue_minus_reg[rd_addr];
			
		end
	end
end

assign local_shift_out[1] = w_plus_store[UNROLLING-1];
assign local_shift_out[0] = w_minus_store[UNROLLING-1];

// INT part
always @ (*) begin
	if (wr_addr == 0) begin
		shift_int_plus = local_shift_out[1] + {cout_one[1],1'b0};
		shift_int_minus = local_shift_out[0] + {cout_one[0],1'b0};
	end
	else begin
		shift_int_plus = 0;
		shift_int_minus = 0;
	end
end

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		w_plus_int = 0;
		w_minus_int = 0;
	end
	else begin
		if (wr_enable) begin
			if (wr_addr == 0) begin
				w_plus_int = v_plus_int + {2'b0,d_plus_vec[UNROLLING-1:UNROLLING-3]};
				w_plus_int = {w_plus_int[UPPER_WIDTH-2:0],1'b0}+ shift_int_plus;
				w_minus_int = v_minus_int + {2'b0,d_minus_vec[UNROLLING-1:UNROLLING-3]};
				w_minus_int = {w_minus_int[UPPER_WIDTH-2:0],1'b0}+shift_int_minus;
			end
		end
	end
end


endmodule
