`timescale 1ns / 1ps
// Company: Indian Institute of Technology Palakkad, India
// Engineer: Gayathri Malamal
// 
// Create Date:    21:56:09 10/15/2019 
// Design Name: 
// Module Name:    DMAS beamformer based on factorization - pixel level 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: G. Malamal and M. R. Panicker, "VLSI architectures for Delay Multiply and Sum Beamforming in Ultrasound Medical Imaging," 
// 2020 International Conference on Signal Processing and Communications (SPCOM), 2020, pp. 1-5, doi: 10.1109/SPCOM50965.2020.9179510.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module factor_pixel_level( clk,rst,chnl_data,sign,bf_out);

parameter channels=128;	//No. of channels
parameter channel_bits=8; //For channels=128
parameter pixels=1;	//No. of pixels
parameter datasize=channels;
parameter sqrt_ip_latency=5;

input clk;
//input clk_dmas;

input rst;
input signed [1:0]sign;
input signed [15:0]chnl_data;

//DAS
reg signed [16:0]sigma;
//reg [channel_bits-1:0] ch_das_cnt,ch_das_cnt_d,ch_das_cnt_d2;

//DMAS
reg signed [1:0]sign_d1;
reg signed [1:0]sign_d2;
reg signed [1:0]sign_d3;
reg signed [1:0]sign_d4;    
reg signed [1:0]sign_d5;    
//reg signed [1:0]sign_d6;    

reg signed [15:0]sigma_sqrt;
reg signed [25:0]sigma_sum_sqr;
wire sqrt_out_valid; 

wire [15:0]chnl_dout_sqrt;
//wire  [8:0]chnl_dout_sqrt_sync;
wire signed [8:0]chnl_din_dmas;
//reg signed  [8:0]chnl_din_dmas_d;

reg [channel_bits-1:0]ch_dmas_cnt,ch_dmas_cnt_d;
reg [2:0]compensate_sqrt_latency;

output reg signed [16:0]bf_out;

//Synchronizing sign according to square root latency which is 2
always@(posedge clk) begin      
	if(rst) begin                       
		sign_d1<=2'b1;                     
		sign_d2<=2'b1;                     
		sign_d3<=2'b1;                     
		sign_d4<=2'b1;                     
		sign_d5<=2'b1;                     
	//	sign_d6<=2'b1;                     
	end                                 
	else begin                          
		sign_d1<=sign;                     
		sign_d2<=sign_d1;                  
		sign_d3<=sign_d2;                  
		sign_d4<=sign_d3;                  
		sign_d5<=sign_d4;                  
	//	sign_d6<=sign_d5;                  
	end                                 
end                                  

squareroot dut_squarerroot          (                                                                                                                             
                                                            .aclk(clk),                                        // input wire aclk                                                     
                                                            .s_axis_cartesian_tvalid(1'b1),  // input wire s_axis_cartesian_tvalid                                                        
                                                            .s_axis_cartesian_tdata(chnl_data),    // input wire [15 : 0] s_axis_cartesian_tdata                                           
                                                            .m_axis_dout_tvalid(sqrt_out_valid),            // output wire m_axis_dout_tvalid                                              
                                                            .m_axis_dout_tdata(chnl_dout_sqrt)              // output wire [8 : 0] m_axis_dout_tdata                                      
                                                            );                                                                                                                             
                                                                                                                                                                                           
assign chnl_din_dmas=(sign_d5==-1)? -chnl_dout_sqrt[8:0]:chnl_dout_sqrt[8:0]; //sign*abs(sqrt)

always @(posedge clk) 
begin
	if(rst) begin
		compensate_sqrt_latency<=0;
	end
	else if(compensate_sqrt_latency<sqrt_ip_latency+1'b1) 
		compensate_sqrt_latency<=compensate_sqrt_latency+1'b1;
	else
		compensate_sqrt_latency<=compensate_sqrt_latency;
end

always @(posedge clk)
begin
	if(rst) begin
		ch_dmas_cnt<=0;
		ch_dmas_cnt_d<=0;
	end
	else if(compensate_sqrt_latency==sqrt_ip_latency+1'b1) begin
		ch_dmas_cnt<=ch_dmas_cnt+1'b1;
		ch_dmas_cnt_d<=ch_dmas_cnt;
	end
	else begin
		ch_dmas_cnt<=ch_dmas_cnt;
		ch_dmas_cnt_d<=ch_dmas_cnt_d;
	end
end

always @(posedge clk)
begin
	if(rst) begin
			sigma<=0;
	end
	
		
	else begin
		//if(clk_cnt==sqrt_latency) begin
			sigma<=sigma+chnl_din_dmas;
		//end
	 end
end

always @(posedge clk) begin
   if(rst) begin
		sigma_sum_sqr<=0;
	end
	else begin
		if (ch_dmas_cnt_d>0)
			sigma_sum_sqr<=sigma_sum_sqr+(chnl_din_dmas*sigma);
	end
end 

always @(posedge clk) begin
	if(rst) begin
		bf_out<=0;
	end
	
	else begin
		if(ch_dmas_cnt_d==channels)
			bf_out<=sigma_sum_sqr[16:0];
	end
end
 
endmodule




