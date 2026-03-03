module combine(
    input clk_100MHz,
    input reset,                
    input hr_plus,              
    input min_plus,             
    output blink,
    output reg [0:6] segg,  
    output reg [3:0] ann ,
    input reset_st,                
    input stop,                           
    input start,
    input alon,                       
    input hr_plus1,                      
    input min_plus1,                             
    output alarm1,
    input set,
    input timest,
    output reg check,
    input reset_a,
    input secplus,
    input minplus,
    input timeset,
    input timereset,
    output blink1

    );
    
    wire [5:0] minute;      
    wire [4:0] hour; 
    wire [5:0] minute_a;      
    wire [4:0] hour_a; 
    wire [0:6] seg1;
    wire[0:6] seg2;
    wire [0:6] seg;
    wire [0:3] an2;
    wire [0:3] an1;
    wire [0:3] an;
    wire [0:6] seg4;
    wire [0:3] an4;
    
   always@(posedge clk_100MHz)
    begin
       if (start==1)
       begin
         segg = seg2;
         ann = an2;
         end       
       else if(alon==1)
       begin
          segg = seg1;
          ann = an1;
          end 
        else if(timest==1)  
          begin 
          segg = seg4;
          ann=an4;
          end
        else  
        begin
         segg = seg;
         ann= an;
         end   
    end

    
    top cl(.clk_100MHz(clk_100MHz),.reset(reset),.hr_plus(hr_plus),.min_plus(min_plus),
        .blink(blink),.seg(seg),.an(an),.hours(hour),.minutes(minute));
    top1 stt(.clk_100MHz(clk_100MHz),.start(start),.stop(stop),.reset_st(reset_st),.seg2(seg2),.an2(an2));
    top2 all(.clk_100MHz(clk_100MHz),.hr_plus1(hr_plus1),.min_plus1(min_plus1),
        .alon(alon),.alarm1(alarm1),.seg1(seg1),.an1(an1),.minute_a(minute_a),.hour_a(hour_a),.reset_a(reset_a));
    top4(.clk_100MHz(clk_100MHz),.secplus(secplus),.minplus(minplus),.timeset(timeset),.timest(timest),
.timereset(timereset),.blink1(blink1),.seg4(seg4),.an4(an4));        

reg [31:0] ctr_1Hz = 32'h0;
    reg r_1Hz = 1'b0;
    
    always @(posedge clk_100MHz)
       begin
            if(ctr_1Hz == 49_999_999) begin
                ctr_1Hz <= 32'h0;
                r_1Hz <= ~r_1Hz;
            end
            else
                ctr_1Hz <= ctr_1Hz + 1;
     end

    assign ass = r_1Hz;
    always@(r_1Hz)
    begin
    if(set)
    begin
        if(minute == minute_a && hour == hour_a)begin
        check = r_1Hz;
    end
    end
    else 
    check = 0;
    end

endmodule

