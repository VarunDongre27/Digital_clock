`timescale 1ns / 1ps


module binary_clock(
    input clk_100MHz,                   
    input reset,                        
    input hr_plus,                      
    input min_plus,                     
    output sec_plus,                    
    output [3:0] sec_1s, sec_10s,       
    output [3:0] min_1s, min_10s,       
    output [3:0] hr_1s, hr_10s, 
    output [5:0]minute,
    output[4:0]hour         
    );
    
	// signals for button debouncing
	reg a, b, c, d, e, f;
	wire db_hr, db_min;
	
	// debounce tick hour button input
	always @(posedge clk_100MHz) begin
		a <= hr_plus;
		b <= a;
		c <= b;
	end
	assign db_hr = c;
	
	// debounce tick minute button input
	always @(posedge clk_100MHz) begin
		d <= min_plus;
		e <= d;
		f <= e;
	end
	assign db_min = f;
	
    
    
    reg [31:0] ctr_1Hz = 32'h0;
    reg r_1Hz = 1'b0;
    
    always @(posedge clk_100MHz or posedge reset)
        if(reset)
            ctr_1Hz <= 32'h0;
        else
            if(ctr_1Hz == 49_999_999) begin
                ctr_1Hz <= 32'h0;
                r_1Hz <= ~r_1Hz;
            end
            else
                ctr_1Hz <= ctr_1Hz + 1;
     
    
   
    reg [5:0] sec_counter = 6'b0;   
    reg [5:0] min_counter = 6'b0;   
    reg [4:0] hrs_counter = 5'h0;   
	
	
    always @(posedge sec_plus or posedge reset)
        if(reset)
            sec_counter <= 6'b0;
        else
            if(sec_counter == 59)
                sec_counter <= 6'b0;
            else
                sec_counter <= sec_counter + 1;
            
   always @(posedge sec_plus or posedge reset)
        if(reset)
            min_counter <= 6'b0;
        else 
            if(db_min | (sec_counter == 59))
                if(min_counter == 59)
                    min_counter <= 6'b0;
                else
                    min_counter <= min_counter + 1;
                    
    
    always @(posedge sec_plus or posedge reset)
        if(reset)
            hrs_counter <= 5'b0;  
        else 
            if(db_hr | (min_counter == 59 && sec_counter == 59))
                if(hrs_counter == 23)
                    hrs_counter <= 5'b0;
                else
                    hrs_counter <= hrs_counter + 1;
                    
    
    //BINARY TO BCD
    assign sec_10s = sec_counter / 10;
    assign sec_1s  = sec_counter % 10;
    assign min_10s = min_counter / 10;
    assign min_1s  = min_counter % 10;
    assign hr_10s  = hrs_counter   / 10;
    assign hr_1s   = hrs_counter   % 10;     
    assign minute = min_counter;
    assign hour = hrs_counter;
     
    // 1Hz output            
    assign sec_plus = r_1Hz; 
            
endmodule


`timescale 1ns / 1ps

module seg_control(
    input clk_100MHz,
    input reset,
    input [3:0] min_1s,
    input [3:0] min_10s,
    input [3:0] hr_1s,
    input [3:0] hr_10s,
    output reg [0:6] seg,
    output reg [3:0] an
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
            2'b00 : an = 4'b0111;
            2'b01 : an = 4'b1011;
            2'b10 : an = 4'b1101;
            2'b11 : an = 4'b1110;
        endcase
    end
    
    // To drive the segments
    always @*
        case(anode_select)
            2'b00 : begin       // HOURS TENS DIGIT
                        case(hr_10s)
                            4'h0 : seg = NULL;
                            4'h1 : seg = ONE;
                            4'h2 : seg = TWO;
                        endcase
                    end
                    
            2'b01 : begin       // HOURS ONES DIGIT
                        case(hr_1s)
                            4'h0 : seg = ZERO;
                            4'h1 : seg = ONE;
                            4'h2 : seg = TWO;
                            4'h3 : seg = THREE;
                            4'h4 : seg = FOUR;
                            4'h5 : seg = FIVE;
                            4'h6 : seg = SIX;
                            4'h7 : seg = SEVEN;
                            4'h8 : seg = EIGHT;
                            4'h9 : seg = NINE;
                        endcase
                    end
                    
            2'b10 : begin       // MINUTES TENS DIGIT
                        case(min_10s)
                            4'h0 : seg = ZERO;
                            4'h1 : seg = ONE;
                            4'h2 : seg = TWO;
                            4'h3 : seg = THREE;
                            4'h4 : seg = FOUR;
                            4'h5 : seg = FIVE;
                        endcase
                    end
                    
            2'b11 : begin       // MINUTES ONES DIGIT
                        case(min_1s)
                            4'h0 : seg = ZERO;
                            4'h1 : seg = ONE;
                            4'h2 : seg = TWO;
                            4'h3 : seg = THREE;
                            4'h4 : seg = FOUR;
                            4'h5 : seg = FIVE;
                            4'h6 : seg = SIX;
                            4'h7 : seg = SEVEN;
                            4'h8 : seg = EIGHT;
                            4'h9 : seg = NINE;
                        endcase
                    end
        endcase
    
    
    
    
endmodule

module seg_controll(
    input clk_100MHz,
    input reset,
    input [3:0] min_1sa,
    input [3:0] min_10sa,
    input [3:0] hr_1sa,
    input [3:0] hr_10sa,
    output reg [0:6] seg,
    output reg [3:0] an
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
            2'b00 : an = 4'b0111;
            2'b01 : an = 4'b1011;
            2'b10 : an = 4'b1101;
            2'b11 : an = 4'b1110;
        endcase
    end
    
    // To drive the segments
    always @*
        case(anode_select)
            2'b00 : begin       // HOURS TENS DIGIT
                        case(hr_10sa)
                            4'h0 : seg = NULL;
                            4'h1 : seg = ONE;
                            4'h2 : seg = TWO;
                        endcase
                    end
                    
            2'b01 : begin       // HOURS ONES DIGIT
                        case(hr_1sa)
                            4'h0 : seg = ZERO;
                            4'h1 : seg = ONE;
                            4'h2 : seg = TWO;
                            4'h3 : seg = THREE;
                            4'h4 : seg = FOUR;
                            4'h5 : seg = FIVE;
                            4'h6 : seg = SIX;
                            4'h7 : seg = SEVEN;
                            4'h8 : seg = EIGHT;
                            4'h9 : seg = NINE;
                        endcase
                    end
                    
            2'b10 : begin       // MINUTES TENS DIGIT
                        case(min_10sa)
                            4'h0 : seg = ZERO;
                            4'h1 : seg = ONE;
                            4'h2 : seg = TWO;
                            4'h3 : seg = THREE;
                            4'h4 : seg = FOUR;
                            4'h5 : seg = FIVE;
                        endcase
                    end
                    
            2'b11 : begin       // MINUTES ONES DIGIT
                        case(min_1sa)
                            4'h0 : seg = ZERO;
                            4'h1 : seg = ONE;
                            4'h2 : seg = TWO;
                            4'h3 : seg = THREE;
                            4'h4 : seg = FOUR;
                            4'h5 : seg = FIVE;
                            4'h6 : seg = SIX;
                            4'h7 : seg = SEVEN;
                            4'h8 : seg = EIGHT;
                            4'h9 : seg = NINE;
                        endcase
                    end
        endcase
    
    
    
    
endmodule


`timescale 1ns / 1ps


module top(
    input clk_100MHz,           
    input reset,                
    input hr_plus,              
    input min_plus,             
    output blink,
    output [0:6] seg,  
    output [3:0] an,
    output [4:0] hours,
    output [5:0] minutes 
    );
   
    wire [3:0] min_1s, min_10s, hr_1s, hr_10s;
    
    
    
    wire [3:0] min_1sa, min_10sa, hr_1sa,hr_10sa;
//   assign segg = (alon) ? seg:seg;
//   assign ann  = (alon) ? an:an;
    binary_clock bc(
        .clk_100MHz(clk_100MHz),
        .reset(reset),
        .hr_plus(hr_plus),
        .min_plus(min_plus),
        .sec_plus(blink),
        .sec_10s(),         
        .sec_1s(),          
        .min_10s(min_10s),
        .min_1s(min_1s),
        .hr_10s(hr_10s),
        .hr_1s(hr_1s),.minute(minute),.hour(hour)
        );
    
    seg_control seg7(
        .clk_100MHz(clk_100MHz),
        .reset(reset),
        .min_1s(min_1s),
        .min_10s(min_10s),
        .hr_1s(hr_1s),
        .hr_10s(hr_10s),
        .seg(seg),
        .an(an)
        );

  assign minutes = minute;
    assign hours = hour;

    
   
endmodule