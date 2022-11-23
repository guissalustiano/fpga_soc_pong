module pong_drawer
#(
  parameter CURSOR_WIDTH = 20,
  parameter CURSOR_OFFSET = 20,
  parameter CURSOR_HEIGHT = 160,
  parameter BALL_SIDE = 30,
  parameter FRAME_WIDTH = 1280,
  parameter FRAME_HEIGHT = 960
) (
  input clk,
  input rst,
  input [15:0] cursor_left_py,
  input [15:0] cursor_right_py,
  input [15:0] ball_py,
  input [15:0] ball_px,
  output [3:0] vgaRed,
  output [3:0] vgaBlue,
  output [3:0] vgaGreen,
  output Hsync,
  output Vsync
);

wire [13:0] hCntr;
wire [13:0] vCntr;
wire [11:0] color = 12'hFFFFFF;

// Draw cursors
wire draw_left_cursor_x = hCntr > CURSOR_OFFSET && hCntr < CURSOR_OFFSET + CURSOR_WIDTH;
wire draw_left_cursor_y = vCntr + CURSOR_HEIGHT/2 > cursor_left_py && vCntr < cursor_left_py + CURSOR_HEIGHT/2;
wire draw_left_cursor = draw_left_cursor_x && draw_left_cursor_y;

wire draw_right_cursor_x = hCntr > FRAME_WIDTH - (CURSOR_OFFSET + CURSOR_WIDTH) && hCntr < FRAME_WIDTH - (CURSOR_OFFSET);
wire draw_right_cursor_y = vCntr + CURSOR_HEIGHT/2 > cursor_right_py && vCntr < cursor_right_py + CURSOR_HEIGHT/2;
wire draw_right_cursor = draw_right_cursor_x && draw_right_cursor_y;

wire draw_ball_x = hCntr + BALL_SIDE/2 > ball_px && hCntr < ball_px + BALL_SIDE/2;
wire draw_ball_y = vCntr + BALL_SIDE/2 > ball_py && vCntr < ball_py + BALL_SIDE/2;
wire draw_ball = draw_ball_x && draw_ball_y;

wire drawer = draw_left_cursor || draw_right_cursor || draw_ball;

vga_driver driver
(
  .pxlClk(clk),
  .reset(rst),
  .rgb_input(drawer ? color : 0),
  .vgaRed(vgaRed),
  .vgaBlue(vgaBlue),
  .vgaGreen(vgaGreen),
  .Hsync(Hsync),
  .Vsync(Vsync),
  .hCntr(hCntr),
  .vCntr(vCntr)
);

endmodule
