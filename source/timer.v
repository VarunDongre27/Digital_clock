`timescale 1ns / 1ps

module timer(
input clk,
input secplus,
input minplus,
input timeset,
input timest,
input timereset,
output reg blink1,
output [3:0]min_1t,
output [3:0]min_10t,
output [3:0]sec_1t,
output [3:0]sec_10t

    );

  reg [5:0] min_counter = 6'b0;   
  reg [5:0] sec_counter = 6'b0;   
	
reg [31:0] ctr_1Hz = 32'h0;
    reg r_1Hz = 1'b0;
    
    always @(posedge clk )
   
       begin
            if(ctr_1Hz == 49_999_999)
            begin
                ctr_1Hz <= 32'h0;
                r_1Hz <= ~r_1Hz;
            end
            else
                ctr_1Hz <= ctr_1Hz + 1;
          end
        
          
    
    reg [5:0] minutes_t=0;
    reg [5:0] seconds_t=0;
                

     always @(posedge(r_1Hz))
     begin
     if(timereset)begin
     minutes_t<=0;
     seconds_t<=0;
     end
           if(minplus==1'b1)
                if (minutes_t==6'd59)
                minutes_t=0;
                else minutes_t=minutes_t+1'd1;
            else if(secplus== 1'b1)
                if (seconds_t==6'd59)
                seconds_t=0;
            else seconds_t=seconds_t+1'd1;
            
     end
always @(posedge r_1Hz) begin
if(timereset)begin
     min_counter<=0;
     sec_counter<=0;
     end
    if (timeset == 1'b0) begin
        min_counter <= minutes_t;
        sec_counter <= seconds_t;
        blink1=0;
    end
    else begin
        if (sec_counter == 0 && min_counter == 0) begin
            min_counter <= 0;
            sec_counter <= 0;
            blink1=1;
        end
        else if (sec_counter == 0) begin
            min_counter <= min_counter - 1; 
            sec_counter <= 59;
        end
        else
        begin
            sec_counter <= sec_counter - 1;
            end
    end
end
                    
                  
    
   
       
 assign min_10t = min_counter / 10;
 assign min_1t  = min_counter % 10;
 assign sec_10t  = sec_counter / 10;
 assign sec_1t   = sec_counter % 10;     
    
   
            
    
    
endmodule


module seg_controler(
    input clk_100MHz,
    input reset_st,
    input [3:0] min_1s,
    input [3:0] min_10s,
    input [3:0] sec_1s,
    input [3:0] sec_10s,
    output reg [0:6] seg4,
    output reg [3:0] an4
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
        
    always @(posedge clk_100MHz or posedge reset_st) begin
        if(reset_st) begin
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
            2'b00 : an4 = 4'b0111;
            2'b01 : an4 = 4'b1011;
            2'b10 : an4 = 4'b1101;
            2'b11 : an4 = 4'b1110;
        endcase
    end
    
    // To drive the segments
    always @*
        case(anode_select)
            2'b00 : begin       // HOURS TENS DIGIT
                        case(min_10s)
                            4'h0 : seg4 = NULL;
                            4'h1 : seg4 = ONE;
                            4'h2 : seg4 = TWO;
                            4'h3 : seg4 = THREE;
                            4'h4 : seg4 = FOUR;
                            4'h5 : seg4 = FIVE;
                            4'h6 : seg4 = SIX;
                            4'h7 : seg4 = SEVEN;
                            4'h8 : seg4 = EIGHT;
                            4'h9 : seg4 = NINE;
                        endcase
                    end
                    
            2'b01 : begin       // HOURS ONES DIGIT
                        case(min_1s)
                            4'h0 : seg4 = ZERO;
                            4'h1 : seg4 = ONE;
                            4'h2 : seg4 = TWO;
                            4'h3 : seg4 = THREE;
                            4'h4 : seg4 = FOUR;
                            4'h5 : seg4 = FIVE;
                            4'h6 : seg4 = SIX;
                            4'h7 : seg4 = SEVEN;
                            4'h8 : seg4 = EIGHT;
                            4'h9 : seg4 = NINE;
                        endcase
                    end
                    
            2'b10 : begin       // MINUTES TENS DIGIT
                        case(sec_10s)
                            4'h0 : seg4 = ZERO;
                            4'h1 : seg4 = ONE;
                            4'h2 : seg4 = TWO;
                            4'h3 : seg4 = THREE;
                            4'h4 : seg4 = FOUR;
                            4'h5 : seg4 = FIVE;
                        endcase
                    end
                    
            2'b11 : begin       // MINUTES ONES DIGIT
                        case(sec_1s)
                            4'h0 : seg4 = ZERO;
                            4'h1 : seg4 = ONE;
                            4'h2 : seg4 = TWO;
                            4'h3 : seg4 = THREE;
                            4'h4 : seg4 = FOUR;
                            4'h5 : seg4 = FIVE;
                            4'h6 : seg4 = SIX;
                            4'h7 : seg4 = SEVEN;
                            4'h8 : seg4 = EIGHT;
                            4'h9 : seg4 = NINE;
                        endcase
                    end
        endcase
    
endmodule



`timescale 1ns / 1ps

module top4(
input clk_100MHz,
input secplus,
input minplus,
input timeset,
input timest,
input timereset,
output blink1,
output [6:0] seg4,  
output [3:0] an4   
);

wire [3:0] min_1t, min_10t, sec_1t,sec_10t;

timer tm(
.clk(clk_100MHz),
.secplus(secplus),
.minplus(minplus),
.timeset(timeset),
.timereset(timereset),
.timest(timest),
.min_1t(min_1t),
.min_10t(min_10t),
.sec_1t(sec_1t),
.sec_10t(sec_10t),
.blink1(blink1)
);

wire[3:0] min_1t,min_10t,hr_10t,hr_1t;

 seg_controler segt(
    .clk_100MHz(clk_100MHz),
    .reset_st(reset_st),
    .min_1s(min_1t),
    .min_10s(min_10t),
    .sec_1s(sec_1t),
    .sec_10s(sec_10t),
    .seg4(seg4),
    .an4(an4)
    );



endmodule