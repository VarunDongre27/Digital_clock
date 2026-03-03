`timescale 1ns / 1ps

module alarm(
    input clk,                   
    input alon,                       
    input hr_plus1,                      
    input min_plus1,  
    input [3:0] min_1s, min_10s,       
    input [3:0] hr_1s, hr_10s,                            
    output [3:0] min_1sa, min_10sa,       
    output [3:0] hr_1sa, hr_10sa,
    output minute_a,
    output hour_a,
    input reset_a
    );
    
	// signals for button debouncing
	reg a, b, c, d, e, f;
	wire db_hr, db_min;
	wire [5:0] minute_as_1;
	wire [4:0] hour_as_1;
	// debounce tick hour_a button input
	always @(posedge clk) begin
		a <= hr_plus1;
		b <= a;
		c <= b;
	end
	assign db_hr = c;
	
	// debounce tick minute_a button input
	always @(posedge clk) begin
		d <= min_plus1;
		e <= d;
		f <= e;
	end
	assign db_min = f;
	
    
    
   
    reg [5:0] min_counter = 6'b0;   
    reg [5:0] hrs_counter = 6'b0;   // Updated to BCD representation
	
reg [31:0] ctr_1Hz = 32'h0;
    reg r_1Hz = 1'b0;
    
    always @(posedge clk)
       if(alon)
       begin
            if(ctr_1Hz == 49_999_999) begin
                ctr_1Hz <= 32'h0;
                r_1Hz <= ~r_1Hz;
            end
            else
                ctr_1Hz <= ctr_1Hz + 1;
     end

            
   always @(posedge r_1Hz )
 if(alon==1)
 begin
     if(reset_a)
            min_counter <= 6'b0;
            if(db_min)
                if(min_counter == 59)
                    min_counter <= 6'b0;
                else
                    min_counter <= min_counter + 1;
                  
    end
    always @(posedge r_1Hz )
    if(alon==1)
    begin
     if(reset_a)
            hrs_counter <= 6'b0;
            if(db_hr | (min_counter == 59 ))
                if(hrs_counter == 23)
                    hrs_counter <= 6'b0;
                else
                    hrs_counter <= hrs_counter + 1;
           
    end
    //BINARY TO BCD conversion
    assign min_10sa = min_counter / 10;
    assign min_1sa  = min_counter % 10;
    assign hr_10sa  = hrs_counter / 10;
    assign hr_1sa   = hrs_counter % 10;     
    
    assign minute_a = min_counter;
    assign hour_a = hrs_counter;
    
   
//    reg [3:0] alarm_counter;

//always @(posedge r_1Hz) 
//if(alon==1)
//   begin
//begin
//    if (min_1s == min_1sa &&
//        min_10s == min_10sa &&
//        hr_1s == hr_1sa &&
//        hr_10s == hr_10sa)
//        ;
////    begin
////        if (alarm_counter < 8 & set == 1) 
////        begin
////            alarm_counter <= alarm_counter + 1;
////            alarm1 <= 1;
////            if (alarm_counter%2 == 1)
////                alarm1 <= 0;
////        end 
////        else 
////        begin
////            alarm_counter <= 0;
////            alarm1 <= 0;
////        end
////    end
////end 
//end  
//end 
endmodule


module seg_controlll(
    input clk_100MHz,
    input reset,
    input [3:0] min_1sa,
    input [3:0] min_10sa,
    input [3:0] hr_1sa,
    input [3:0] hr_10sa,
    output reg [6:0] seg1,
    output reg [3:0] an1
    );
    
    // Parameters for segment values
    parameter NULL  = 7'b111_1111;  // Turn off all segments
    parameter ZERO  = 7'b000_0001;  // 0
    parameter ONE   = 7'b100_1111;  // 1
    parameter TWO   = 7'b001_0010;  // 2 
    parameter THREE = 7'b000_0110;  // 3
    parameter FOUR  = 7'b100_1100;  // 4
    parameter FIVE  = 7'b010_0100;  // 5
    parameter SIX   = 7'b010_0000;  // 6
    parameter SEVEN = 7'b000_1111;  // 7
    parameter EIGHT = 7'b000_0000;  // 8
    parameter NINE  = 7'b000_0100;  // 9
    
    
    // To select each anode in turn
    reg [1:0] anode_select;
    reg [16:0] anode_timer;
        
    always @(posedge clk_100MHz or posedge reset) begin
        if(reset) begin
            anode_select <= 0;
            anode_timer <= 0; 
        end
        else
            if(anode_timer == 99_999) begin
                anode_timer <= 0;
                anode_select <=  anode_select + 1;
            end
            else
                anode_timer <=  anode_timer + 1;
    end
    
    always @(anode_select) begin
        case(anode_select) 
            2'b00 : an1 = 4'b0111;
            2'b01 : an1 = 4'b1011;
            2'b10 : an1 = 4'b1101;
            2'b11 : an1 = 4'b1110;
        endcase
    end
    
    // To drive the segments
    always @*
        case(anode_select)
            2'b00 : begin       // hour_aS TENS DIGIT
                        case(hr_10sa)
                            4'h0 : seg1 = NULL;
                            4'h1 : seg1 = ONE;
                            4'h2 : seg1 = TWO;
                        endcase
                    end
                    
            2'b01 : begin       // hour_aS ONES DIGIT
                        case(hr_1sa)
                            4'h0 : seg1 = ZERO;
                            4'h1 : seg1 = ONE;
                            4'h2 : seg1 = TWO;
                            4'h3 : seg1 = THREE;
                            4'h4 : seg1 = FOUR;
                            4'h5 : seg1 = FIVE;
                            4'h6 : seg1 = SIX;
                            4'h7 : seg1 = SEVEN;
                            4'h8 : seg1 = EIGHT;
                            4'h9 : seg1 = NINE;
                        endcase
                    end
                    
            2'b10 : begin       // minute_aS TENS DIGIT
                        case(min_10sa)
                            4'h0 : seg1 = ZERO;
                            4'h1 : seg1 = ONE;
                            4'h2 : seg1 = TWO;
                            4'h3 : seg1 = THREE;
                            4'h4 : seg1 = FOUR;
                            4'h5 : seg1 = FIVE;
                        endcase
                    end
                    
            2'b11 : begin       // minute_aS ONES DIGIT
                        case(min_1sa)
                            4'h0 : seg1 = ZERO;
                            4'h1 : seg1 = ONE;
                            4'h2 : seg1 = TWO;
                            4'h3 : seg1 = THREE;
                            4'h4 : seg1 = FOUR;
                            4'h5 : seg1 = FIVE;
                            4'h6 : seg1 = SIX;
                            4'h7 : seg1 = SEVEN;
                            4'h8 : seg1 = EIGHT;
                            4'h9 : seg1 = NINE;
                        endcase
                    end
        endcase
    
    
    
    
endmodule

module top2(
    input clk_100MHz,
    input alon,
    input hr_plus1,
    input min_plus1, 
    output [5:0] minute_a,
    output [4:0] hour_a,           
    output alarm1,
    output [6:0] seg1,  
    output [3:0] an1,
    input reset_a        
    );
 wire [3:0] min_1sa, min_10sa, hr_1sa,hr_10sa;
 wire minute_a ;
 wire hour_a;
 alarm al(.clk(clk_100MHz),                   
    .alon(alon),                       
    .hr_plus1(hr_plus1),                      
    .min_plus1(min_plus1),  
    .min_1s(min_1s), .min_10s(min_10s),       
    .hr_1s(hr_1s), .hr_10s(hr_10s),                            
    .min_1sa(min_1sa), .min_10sa(min_10sa),       
    .hr_1sa(hr_1sa), .hr_10sa(hr_10sa),.minute_a(minute_a),.hour_a(hour_a),.reset_a(reset_a));
    
     seg_controlll segu(
    .clk_100MHz(clk_100MHz),
    .min_1sa(min_1sa),
    .min_10sa(min_10sa),
    .hr_1sa(hr_1sa),
    .hr_10sa(hr_10sa),
    .seg1(seg1),
    .an1(an1)
    );
    
    endmodule