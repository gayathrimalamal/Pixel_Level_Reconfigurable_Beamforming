`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Indian Institute of Technology Palakkad, India
// Engineer: Gayathri Malamal
// 
// Create Date:    21:21:01 10/15/2019 
// Design Name: 
// Module Name:    MEBRA
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: G. Malamal and M. R. Panicker, "Towards A Pixel-Level Reconfigurable Digital Beamforming Core for Ultrasound Imaging,"
// in IEEE Transactions on Biomedical Circuits and Systems, vol. 14, no. 3, pp. 570-582, June 2020, doi: 10.1109/TBCAS.2020.2983759.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module MEBRA(clk,rst,mode,rfdata,bf_out);
   
parameter channels=128;	//No. of channels
parameter bit_size=8; //For 128 channels
parameter pixels=1;	//No. of pixels
parameter datasize=channels;
parameter sqrt_latency=5; //Optimal pipeline

input clk;	//clk
input rst;	//rst
input mode; //Control signal to select the beamforming mode das/dmas
input signed [15:0] rfdata;
output signed [16:0]bf_out;

//wire clk_dmas;
//reg [1:0]clk_cnt;
//reg signed [15:0] interp_data[0:datasize-1];
reg signed [1:0]sign;

//reg i;
//reg [6:0]j,j_d,j_d2; //for 64 channels
//reg [7:0]j,j_d,j_d2; //for 128 channels
reg [bit_size-1:0]j,j_d,j_d2; //for 256 channels
reg signed[15:0] chnl_din;

//assign clk_dmas=clk & (~mode);

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
		 if(~mode)	begin
			  if(rfdata<0) begin
					chnl_din<=(~rfdata) +1'd1; //Taking absolute of data for sqrt
					sign<=2'b11; //sign=-1
			  end
			  else begin
					chnl_din<=rfdata;
					sign<=2'b1;  //sign=+1
			  end
		 end
		 
		 else if(mode) 
				chnl_din<=rfdata;
	end
	
	else  begin
			chnl_din<=0;
	end
end

MEBRA_pixel_level#(channels,bit_size,pixels,datasize,sqrt_latency) uut_beamformer (clk,/*clk_dmas,*/rst,mode,chnl_din, sign, bf_out);

endmodule

