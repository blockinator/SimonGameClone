module seven_seg (
  output [7:0] segments_n,
  input  [3:0] hex
);
 
 reg [7:0] seg;
    always @* begin
      case(hex)
        4'b0000: seg = 8'b00111111; // 0  
        4'b0001: seg = 8'b00000110; // 1  
        4'b0010: seg = 8'b01011011; // 2  
        4'b0011: seg = 8'b01001111; // 3  
        4'b0100: seg = 8'b01100110; // 4  
        4'b0101: seg = 8'b01101101; // 5  
        4'b0110: seg = 8'b01111101; // 6  
        4'b0111: seg = 8'b00000111; // 7  
        4'b1000: seg = 8'b01111111; // 8  
        4'b1001: seg = 8'b01101111; // 9  
        4'b1010: seg = 8'b01110111; // A  
        4'b1011: seg = 8'b01111100; // B  
        4'b1100: seg = 8'b00111001; // C  
        4'b1101: seg = 8'b01011110; // D  
        4'b1110: seg = 8'b01111001; // E  
        4'b1111: seg = 8'b01110001; // F  
        default: seg = 8'b01000000; // -  
      endcase
	end
	assign segments_n = ~seg;
endmodule
