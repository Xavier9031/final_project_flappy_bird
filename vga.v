module vga(
   input iCLK, // 25 MHz clock
   input iRST_N,
   input [3:0] iRed,
   input [3:0] iGreen,
   input [3:0] iBlue,
   // pixel coordinates
   output [9:0] px,
   output [9:0] py,
   // VGA Side
   output  [3:0] VGA_R,
   output  [3:0] VGA_G,
   output  [3:0] VGA_B,
   output reg VGA_H_SYNC,
   output reg VGA_V_SYNC,
   output VGA_SYNC,
   output VGA_BLANK
);

assign	VGA_BLANK	=	VGA_H_SYNC & VGA_V_SYNC;
assign	VGA_SYNC	=	1'b0;

reg [9:0] h_count, v_count;
assign px = h_count;
assign py = v_count;


// Horizontal sync

/* Generate Horizontal and Vertical Timing Signals for Video Signal
* h_count counts pixels (640 + extra time for sync signals)
* 
*  horiz_sync  ------------------------------------__________--------
*  h_count       0                640             659       755    799
*/
parameter H_SYNC_TOTAL = 1040;
parameter H_PIXELS =     800;
parameter H_SYNC_START = 0;
parameter H_SYNC_WIDTH =  128;

always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		h_count <= 10'h000;
		VGA_H_SYNC <= 1'b0;
	end
	else
	begin
		// H_Sync Counter
		if (h_count < H_SYNC_TOTAL-1) 
			h_count <= h_count + 1'b1;
		else 
			h_count <= 10'h0000;

		if (h_count >= H_SYNC_START && h_count < H_SYNC_START+H_SYNC_WIDTH) 
			VGA_H_SYNC = 1'b0;
		else
			VGA_H_SYNC <= 1'b1;
	end
end
/*  
*  vertical_sync      -----------------------------------------------_______------------
*  v_count             0                                      480    493-494          524
*/
parameter V_SYNC_TOTAL = 666;
parameter V_PIXELS     = 600;
parameter V_SYNC_START = 0;
parameter V_SYNC_WIDTH =   4;
parameter H_START = 0;

always @(posedge iCLK or negedge iRST_N)
begin
	if (!iRST_N)
	begin
		v_count <= 10'h0000;
		VGA_V_SYNC <= 1'b0;
	end
	else if (h_count == H_START)
	begin
		// V_Sync Counter
		if (v_count < V_SYNC_TOTAL-1) 
			v_count <= v_count + 1'b1;
		else 
			v_count <= 10'h0000;

		if (v_count >= V_SYNC_START && v_count < V_SYNC_START+V_SYNC_WIDTH) 
			VGA_V_SYNC = 1'b0;
		else 
			VGA_V_SYNC <= 1'b1;
	end
end
   


// Put all video signals through DFFs to elminate any delays that cause a blurry image

	wire video_h_on = (h_count<H_PIXELS);
	wire video_v_on = (v_count<V_PIXELS);
	wire video_on = video_h_on & video_v_on;

	assign VGA_R = (video_on? iRed: 4'b0000);
	assign VGA_G = (video_on? iGreen: 4'b0000);
	assign VGA_B = (video_on? iBlue: 4'b0000);

endmodule

