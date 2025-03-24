module tb();

	reg r_clk;

	initial begin
		r_clk = 1'b0;
		forever begin
			#1 r_clk = ~r_clk;
		end
	end

	reg r_load, r_enable, r_ped_ns, r_ped_ew, r_bus_ns, r_bus_ew;
	reg [7:0] r_cars_ns, r_cars_ew;
	wire [2:0] w_light_ns, w_light_ew;
	wire [1:0] w_ped_ns, w_ped_ew;
	wire [3:0] w_state;
	wire [5:0] w_cars_ns, w_cars_ew;

	Controller uut(
					.i_load(r_load),
					.i_clk(r_clk),
					.i_enable(r_enable),
					.i_ped_ns(r_ped_ns),
					.i_ped_ew(r_ped_ew),
					.i_cars_ns(r_cars_ns),
					.i_cars_ew(r_cars_ew),
					.i_bus_ns(r_bus_ns),
					.i_bus_ew(r_bus_ew),
					.o_light_ns(w_light_ns),
					.o_light_ew(w_light_ew),
					.o_ped_ns(w_ped_ns),
					.o_ped_ew(w_ped_ew),
					.o_state(w_state),
					.o_cars_ns(w_cars_ns),
					.o_cars_ew(w_cars_ew)
					);

	initial begin
		$display("Traffic Controller Test");
		$display("Emergency test");
		r_enable = 0;
		#1000;

		$display("20 cars going NS, 10 cars going EW");
		r_load = 1;
		r_enable = 1;
		r_cars_ns = 20;
		r_cars_ew = 10;
		r_ped_ns = 0;
		r_ped_ew = 0;
		r_bus_ns = 0;
		r_bus_ew = 0;
		#4
		r_load = 0;
		#996;

		$display("20 cars going NS, 1 bus going EW");
		r_load = 1;
		r_cars_ns = 20;
		r_cars_ew = 0;
		r_ped_ns = 0;
		r_ped_ew = 0;
		r_bus_ns = 0;
		r_bus_ew = 1;
		#4
		r_load = 0;
		#200
		r_bus_ew = 0;		
		#796;

		$display("40 cars going NS, 10 cars going EW, ");
		r_load = 1;
		r_cars_ns = 80;
		r_cars_ew = 10;
		r_ped_ns = 0;
		r_ped_ew = 0;
		r_bus_ns = 0;
		r_bus_ew = 0;
		#4
		r_load = 0;
		#996;

		$display("40 cars going NS, Ped going EW");
		r_load = 1;
		r_cars_ns = 20;
		r_cars_ew = 10;
		r_ped_ns = 0;
		r_ped_ew = 1;
		r_bus_ns = 0;
		r_bus_ew = 0;
		#4
		r_load = 0;
		#100
		r_ped_ew = 0;
		#896;

		$display("End of test");
		$finish;
	end

endmodule
