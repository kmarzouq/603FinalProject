module Controller(
	input i_load,
	input i_clk,
	input i_enable,
	input i_ped_ns, i_ped_ew,
	input [7:0] i_cars_ns, i_cars_ew,
	input i_bus_ns, i_bus_ew,
	output reg [2:0] o_light_ns = 0, o_light_ew = 0, // 2 = red, 1 = yellow, 0 = green
	output reg [1:0] o_ped_ns = 0, o_ped_ew = 0, // 1 = walk, 0 = don't
	output reg [3:0] o_state,
	output reg [5:0] o_cars_ns, o_cars_ew
	);

	localparam CPS = 2; // Cycles per second
	localparam PED_START = 5*CPS; // 5 second ped head start
	localparam MAX_PHASE = 20*CPS; // 30 second max cycle time

	localparam BLINK_TIME = CPS;
	localparam Y_TIME = 5*CPS;
	localparam R_TIME = 5*CPS;
	localparam PASS_TIME = 2*CPS;

	localparam BLINK = 4'd0;
	localparam NS_PED = 4'd1; 
	localparam NS_G = 4'd2;
	localparam NS_Y = 4'd3;
	localparam NS_R = 4'd4;
	localparam EW_PED = 4'd5;
	localparam EW_G = 4'd6;
	localparam EW_Y = 4'd7;
	localparam EW_R = 4'd8;

	reg [6:0] r_tmr1 = 0;
	reg [6:0] r_tmr2 = 0;
	reg [3:0] r_state = NS_G;
	reg r_change = 0;

	reg [5:0] r_cars_ns, r_cars_ew;

	// always @ (posedge i_clk) begin
		
	// 	// if (i_enable) begin
	// 	// 	if (r_state == BLINK) r_state <= NS_PED;
	// 	// 	if (i_load) begin
	// 			//r_cars_ns <= i_cars_ns;
	// 			//r_cars_ew <= i_cars_ew;
	// 			//r_tmr1 <= 0;
	// 			//r_tmr2 <= 0;
	// 			//r_change <= 0;
	// 		//end
	// 		// if (r_change) begin
	// 			// if (r_state == 4'd8) r_state <= NS_PED;
	// 			// else r_state <= r_state + 1;
	// 		// 	r_change <= 0;
	// 		// end
	// 	// end
	// 	// else begin
	// 	// 	r_state <= BLINK;
	// 	// end
		
	// 	o_cars_ns <= r_cars_ns;
	// 	o_cars_ew <= r_cars_ew;
	// end

	always @ (posedge i_clk) begin
		// r_tmr1 <= r_tmr1 + 1;
		o_state <= r_state;
		if (i_load) begin
			r_tmr1 <= 0;
		end
		
		else if (i_enable)  begin
		case (r_state)
			NS_PED, EW_PED:	begin
								if (r_tmr1 >= PED_START-1) begin
									r_tmr1 <= 0;
									if (r_state == 4'd8) r_state <= NS_PED;
									else r_state <= r_state + 1;
								end
								else begin
									r_tmr1 <= r_tmr1 + 1;
								end
							end
			NS_G:			begin
								if ((i_bus_ew && !i_bus_ns) || (!r_cars_ns && !i_ped_ns) || r_tmr1 >= MAX_PHASE-1) begin
									r_tmr1 <= 0; 
									if (!i_bus_ns && (r_cars_ew || i_ped_ew || i_bus_ew)) begin
										if (r_state == 4'd8) r_state <= NS_PED;
										else r_state <= r_state + 1;
									end;
								end
								else begin
									r_tmr1 <= r_tmr1 + 1;
								end
							end
			EW_G:			begin
								if ((i_bus_ns && !i_bus_ew) || (!r_cars_ew && !i_ped_ew) || r_tmr1 >= MAX_PHASE-1) begin
									r_tmr1 <= 0;
									if (!i_bus_ew && (r_cars_ns || i_ped_ns || i_bus_ns)) begin
										if (r_state == 4'd8) r_state <= NS_PED;
										else r_state <= r_state + 1;
									end;
								end
								else begin
									r_tmr1 <= r_tmr1 + 1;
								end
							end
			NS_Y, EW_Y:		begin
								if (r_tmr1 > Y_TIME-1) begin
									r_tmr1 <= 0;
									if (r_state == 4'd8) r_state <= NS_PED;
									else r_state <= r_state + 1;
								end
								else begin
									r_tmr1 <= r_tmr1 + 1;
								end
							end
			NS_R, EW_R:		begin
								if (r_tmr1 > R_TIME-1) begin
									r_tmr1 <= 0;
									if (r_state == 4'd8) r_state <= NS_PED;
									else r_state <= r_state + 1;
								end
								else begin
									r_tmr1 <= r_tmr1 + 1;
								end
							end
			BLINK: r_state <= NS_PED;
		endcase
		end
		else begin
			r_state <= BLINK;
		end
	end


	always @ (posedge i_clk) begin // decrementing car counter as green light is on.

		if (i_load) begin
			r_tmr2<=0;
			r_cars_ns <= i_cars_ns;
			r_cars_ew <= i_cars_ew;
		end
		else begin
		
		o_cars_ns <= r_cars_ns;
		o_cars_ew <= r_cars_ew;
		case (r_state)
			NS_G:	begin
						if (r_tmr2 >= PASS_TIME-1) begin
							r_tmr2 <= 0;
							if (r_cars_ns > 0) r_cars_ns <= r_cars_ns - 1;
						end 
						else begin
							r_tmr2 <= r_tmr2 + 1;
						end
					end
			EW_G:	begin
						if (r_tmr2 >= PASS_TIME-1) begin
							r_tmr2 <= 0;
							if (r_cars_ew > 0) r_cars_ew <= r_cars_ew - 1;
						end	
						else begin
							r_tmr2 <= r_tmr2 + 1;
						end
					end
			
		endcase
		end
	end

	always @ (posedge i_clk) begin
		case (r_state)
			BLINK:	begin
						o_light_ns[2] <= ~o_light_ns[2];
						o_light_ew[2] <= ~o_light_ew[2];
						o_ped_ns[0] <= ~o_ped_ns[0];
						o_ped_ew[0] <= ~o_ped_ew[0];			
					end
			NS_PED:	begin
						o_ped_ns[1] <= 1;
						o_ped_ns[0] <= 0;
					end
			NS_G:	begin
						o_light_ns[2] <= 0;
						o_light_ns[1] <= 0;
						o_light_ns[0] <= 1;
					end
			NS_Y:	begin
						o_light_ns[2] <= 0;
						o_light_ns[1] <= 1;
						o_light_ns[0] <= 0;
						o_ped_ns[1] <= 0;
						o_ped_ns[0] <= 1;
					end
			NS_R:	begin
						o_light_ns[2] <= 1;
						o_light_ns[1] <= 0;
						o_light_ns[0] <= 0;
					end
			EW_PED:	begin
						o_ped_ew[1] <= 1;
						o_ped_ew[0] <= 0;
					end
			EW_G:	begin
						o_light_ew[2] <= 0;
						o_light_ew[1] <= 0;
						o_light_ew[0] <= 1;
					end
			EW_Y:	begin
						o_light_ew[2] <= 0;
						o_light_ew[1] <= 1;
						o_light_ew[0] <= 0;
						o_ped_ew[1] <= 0;
						o_ped_ew[0] <= 1;
					end
			EW_R:	begin
						o_light_ew[2] <= 1;
						o_light_ew[1] <= 0;
						o_light_ew[0] <= 0;
					end
		endcase
	end
endmodule
