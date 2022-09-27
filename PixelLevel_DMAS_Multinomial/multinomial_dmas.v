`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Indian Institute of Technology Palakkad, India
// Engineer: Gayathri Malamal
// 
// Create Date:    21:21:01 10/15/2019 
// Design Name: 
// Module Name:    multinomial dmas beamformer
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: G. Malamal and M. R. Panicker, "VLSI architectures for Delay Multiply and Sum Beamforming in Ultrasound Medical Imaging," 
// 2020 International Conference on Signal Processing and Communications (SPCOM), 2020, pp. 1-5, doi: 10.1109/SPCOM50965.2020.9179510.
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module multinomial_dmas(clk,rst,rfdata,bf_out);
   
parameter channels=128;	//No. of channels
parameter channel_bits=8; //For channels=128
parameter pixels=1;	//No. of pixels
parameter datasize=channels;
parameter sqrt_ip_latency=5; //Optimal pipeline

input clk;	//clk
input rst;	//rst
input signed [15:0] rfdata;
output signed [16:0]bf_out;

//reg [1:0]clk_cnt;
reg signed [15:0] interp_data[0:datasize-1];
reg signed [1:0]sign;

//reg i;
reg [channel_bits-1:0]j,j_d,j_d2;
reg signed[15:0] chnl_din;

initial begin
	$readmemb("cl_interpdata_pixel1_128ch.txt",interp_data);// reading from a text file
end

always@(posedge clk) begin
   if(rst) 
			j<=0;
			
	else if(j<channels) begin
			j<=j+1;
	end
end		
		
always@(posedge clk) begin
            j_d<=j;
			j_d2<=j_d;
end

always@(posedge clk) begin
   if(rst) begin
		chnl_din<=0;
        sign<=2'b1;
	end
	
	else if(j_d2<channels) begin
		// if(~mode)	begin
			  if(rfdata<0) begin
					chnl_din<=(~rfdata) +1'd1; //Taking absolute of data for sqrt
					sign<=2'b11; //sign=-1
			  end
			  else begin
					chnl_din<=rfdata;
					sign<=2'b1;  //sign=+1
			  end
	//	 end
		 
end
	
	else  begin
			chnl_din<=0;
	end
end

multinomial_dmas_pixel_level #(channels,channel_bits,pixels,datasize,sqrt_ip_latency) uut_beamformer (clk,rst,chnl_din, sign, bf_out);

endmodule
