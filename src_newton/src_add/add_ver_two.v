module Online_adder_hd (
x_in,
y_in,
clk,
z,
asyn_reset,
enable
);

	input [1:0] x_in, y_in;
	input clk;
	input asyn_reset;
	input enable;
	output [1:0] z;

	parameter unrolling = 64;
	parameter online_delay = 3;

	reg [1:0] STATE;
	parameter IDLE = 2'b00;
	parameter COMP = 2'b01;
	parameter REST = 2'b10;

	// find each wire
	wire x_plus, x_minus, y_plus, y_minus;
	wire x_minus_tmp;
	wire [1:0] g_in, g_out;
	wire g_in_tmp;
       	wire [1:0] g_out_tmp;
	wire t_tmp, w_out;

	reg x_plus_reg, x_minus_reg, y_plus_reg, y_minus_reg; 
	reg [31:0] counter; // this counter is large enough for the operations
	reg [10:0] accum, rest_cycle;
	reg enable_all;

	assign x_plus = x_in[1];
	assign x_minus = x_in[0];
	assign y_plus = y_in[1];
	assign y_minus = y_in[0];



// STATE behaviors
	initial begin
		STATE <= IDLE;
		counter <= 0;
		accum <= 0;
		x_plus_reg <= 0;
		x_minus_reg <= 0;
		y_plus_reg <= 0;
		y_minus_reg <= 0;
	end

	always @ (posedge clk or posedge asyn_reset) begin
		if (asyn_reset == 1) begin
			STATE <= IDLE;
			counter <= 0;
			accum <= 0;
			x_plus_reg <= x_plus;
			x_minus_reg <= x_minus;
			y_plus_reg <= y_plus;
			y_minus_reg <= y_minus;
			rest_cycle <= 0;
		end
		else begin
			if (enable) begin
				case (STATE)
					IDLE: begin
						if (counter >= unrolling + online_delay) begin
							STATE <= COMP;
							accum <= accum + 1;
							counter <= 0;
						end
						else begin
							STATE <= IDLE;
							x_plus_reg <= x_plus;
							x_minus_reg <= x_minus;
							y_plus_reg <= y_plus;
							y_minus_reg <= y_minus;
							counter <= counter + 1'b1;
						end
					end
					COMP: begin
						counter <= counter + 1;
						STATE <= REST;
						x_plus_reg <= x_plus;
						x_minus_reg <= x_minus;
						y_plus_reg <= y_plus;
						y_minus_reg <= y_minus;
						rest_cycle <= accum;
						if (counter >= unrolling) begin
							accum <= accum + 1;
							counter <= 0;
						end
					end
					REST: begin
						rest_cycle = rest_cycle - 1;
						if (rest_cycle == 0) begin
							STATE <= COMP;
						end
					end
				endcase
			end
			else begin
				STATE <= IDLE;
				counter <= 0;
				accum <= 0;
				x_plus_reg <= 0;
				x_minus_reg <= 0;
				y_plus_reg <= 0;
				y_minus_reg <= 0;
			end
		end
	end

	always @ (*) begin
		case (STATE)
			IDLE: begin
				enable_all <= 1;
			end
	
			COMP: begin
				enable_all <= 1;
			end
			REST: begin
				enable_all <= 0;
			end
		endcase
	end



 //this part of code follows diagram of RADIX_2 ON-line ADDER
 // This is a SERIAL adder
	assign x_minus_tmp=~x_minus_reg;
	full_adder FA1(x_plus_reg,x_minus_tmp,y_plus_reg,h,g_in[1]);
	
	
	assign g_in[0]=y_minus_reg;
	assign g_in_tmp=~g_in[1];
	D_flipflop D1(enable&enable_all,clk,g_in_tmp,g_out[1]);
	D_flipflop D2(enable&enable_all,clk,g_in[0],g_out[0]);
		
	assign g_out_tmp=~g_out;
	full_adder FA2 (g_out_tmp[1],g_out_tmp[0],h,t,w_in);
	
	D_flipflop D3(enable&enable_all,clk,w_in,w_out);
	assign t_tmp=~t;
	D_flipflop D4(enable&enable_all,clk,t_tmp,z[0]);
	D_flipflop D5(enable&enable_all,clk,w_out,z[1]);
	
endmodule
	
