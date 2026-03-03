`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2024 23:21:59
// Design Name: 
// Module Name: stopwatch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module stopwatch(
input clk,
input start,
input stop,
input reset_st,
output [3:0] sec_1s,
output [3:0] sec_10s,
output [3:0] min_1s,
output [3:0] min_10s,
output [3:0] milsec_1s
    );
    
    reg [31:0] ctr_1Hz = 32'h0;
    reg r_1Hz = 1'b0;
    
    always @(posedge clk)
       if(~stop)
       begin
            if(ctr_1Hz == 4_999_999) begin
                ctr_1Hz <= 32'h0;
                r_1Hz <= ~r_1Hz;
            end
            else
                ctr_1Hz <= ctr_1Hz + 1;
     end
    reg [3:0] milsec_counter = 4'b0;
    reg [5:0] sec_counter = 6'b0;   
    reg [5:0] min_counter = 6'b0;
    
    always@(posedge r_1Hz or posedge reset_st )
    if (reset_st==1)
    begin
    milsec_counter <= 0;
    end
    else if(start)
    begin
    if(milsec_counter == 9)
    milsec_counter <= 4'b0;
    else
    milsec_counter <= milsec_counter + 1;
    end
    
    
    always@(posedge r_1Hz or posedge reset_st )
    if (reset_st==1)
    begin
    sec_counter <= 0;
    end
    else if(start)
    begin
    if(milsec_counter==9)begin
    if(sec_counter == 59)
    sec_counter <= 6'b0;
    else
    sec_counter <= sec_counter + 1;
    end
    end
    
    always@(posedge r_1Hz or posedge reset_st)
    if (reset_st==1)
    begin
    min_counter <= 0;
    end
    else if(start)
    begin     
    if(sec_counter == 59&&milsec_counter==9)
    if(min_counter == 9)
    min_counter = 6'b0;
    else
    min_counter = min_counter + 1;
    end
    
    assign milsec_1s = milsec_counter;
    assign sec_10s = sec_counter / 10;
    assign sec_1s  = sec_counter % 10;
    assign min_10s = min_counter / 10;
    assign min_1s  = min_counter % 10;
    
endmodule

module seg_controll(
    input clk_100MHz,
    input reset_st,
    input [3:0] min_1s,
    input [3:0] min_10s,
    input [3:0] sec_1s,
    input [3:0] sec_10s,
    input [3:0] milsec_1s,
    output reg [0:6] seg2,
    output reg [3:0] an2
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
            2'b00 : an2 = 4'b0111;
            2'b01 : an2 = 4'b1011;
            2'b10 : an2 = 4'b1101;
            2'b11 : an2 = 4'b1110;
        endcase
    end
    
    // To drive the segments
    always @*
        case(anode_select)
            2'b00 : begin       // HOURS TENS DIGIT
                        case(min_1s)
                            4'h0 : seg2 = NULL;
                            4'h1 : seg2 = ONE;
                            4'h2 : seg2 = TWO;
                            4'h3 : seg2 = THREE;
                            4'h4 : seg2 = FOUR;
                            4'h5 : seg2 = FIVE;
                            4'h6 : seg2 = SIX;
                            4'h7 : seg2 = SEVEN;
                            4'h8 : seg2 = EIGHT;
                            4'h9 : seg2 = NINE;
                        endcase
                    end
                    
            2'b01 : begin       // HOURS ONES DIGIT
                        case(sec_10s)
                            4'h0 : seg2 = ZERO;
                            4'h1 : seg2 = ONE;
                            4'h2 : seg2 = TWO;
                            4'h3 : seg2 = THREE;
                            4'h4 : seg2 = FOUR;
                            4'h5 : seg2 = FIVE;
                            4'h6 : seg2 = SIX;
                            4'h7 : seg2 = SEVEN;
                            4'h8 : seg2 = EIGHT;
                            4'h9 : seg2 = NINE;
                        endcase
                    end
                    
            2'b10 : begin       // MINUTES TENS DIGIT
                        case(sec_1s)
                            4'h0 : seg2 = ZERO;
                            4'h1 : seg2 = ONE;
                            4'h2 : seg2 = TWO;
                            4'h3 : seg2 = THREE;
                            4'h4 : seg2 = FOUR;
                            4'h5 : seg2 = FIVE;
                            4'h6 : seg2 = SIX;
                            4'h7 : seg2 = SEVEN;
                            4'h8 : seg2 = EIGHT;
                            4'h9 : seg2 = NINE;
                        endcase
                    end
                    
            2'b11 : begin       // MINUTES ONES DIGIT
                        case(milsec_1s)
                            4'h0 : seg2 = ZERO;
                            4'h1 : seg2 = ONE;
                            4'h2 : seg2 = TWO;
                            4'h3 : seg2 = THREE;
                            4'h4 : seg2 = FOUR;
                            4'h5 : seg2 = FIVE;
                            4'h6 : seg2 = SIX;
                            4'h7 : seg2 = SEVEN;
                            4'h8 : seg2 = EIGHT;
                            4'h9 : seg2 = NINE;
                        endcase
                    end
        endcase
    
    
    
    
endmodule

module top1(
    input clk_100MHz,           
    input reset_st,                
    input stop,                           
    input start,
    output [6:0] seg2,  
    output [3:0] an2           
    );
 wire [3:0] min_1s, min_10s, sec_1s,sec_10s,milsec_1s;
 
 stopwatch st(.clk(clk_100MHz),                   
    .start(start),                       
    .stop(stop),                      
    .reset_st(reset_st),
    .min_1s(min_1s), .min_10s(min_10s),       
    .sec_1s(sec_1s), .sec_10s(sec_10s),.milsec_1s(milsec_1s)                    
    );
    
     seg_controll segu(
    .clk_100MHz(clk_100MHz),
    .reset_st(reset_st),
    .min_1s(min_1s),
    .min_10s(min_10s),
    .sec_1s(sec_1s),
    .sec_10s(sec_10s),
    .milsec_1s(milsec_1s),
    .seg2(seg2),
    .an2(an2)
    );
    
    endmodule
