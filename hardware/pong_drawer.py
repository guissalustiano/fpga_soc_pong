from migen import *
from litex.soc.interconnect.csr import CSRStorage, CSRStatus

from litex.soc.interconnect.csr import AutoCSR
from litex.soc.integration.doc import AutoDoc, ModuleDoc

class PongDrawer(Module, AutoCSR, AutoDoc):
    def __init__(self):
        self.pxClk = ClockSignal("vga")
        self.rst = ResetSignal()
        self.cursor_left_py = CSRStorage(16)
        self.cursor_right_py = CSRStorage(16)
        self.ball_py = CSRStorage(16)
        self.ball_px = CSRStorage(16)
        self.hCntr = CSRStorage(16)
        self.vCntr = CSRStorage(16)
        self.vgaRed = Signal(4)
        self.vgaBlue = Signal(4)
        self.vgaGreen = Signal(4)
        self.Hsync = Signal(1)
        self.Vsync = Signal(1)

        # # #

        self.specials += Instance("pong_drawer",
            i_clk=self.pxClk,
            i_rst=self.rst,
            i_cursor_left_py=self.cursor_left_py.storage,
            i_cursor_right_py=self.cursor_right_py.storage,
            i_ball_py=self.ball_py.storage,
            i_ball_px=self.ball_px.storage,
            o_vgaRed=self.vgaRed,
            o_vgaBlue=self.vgaBlue,
            o_vgaGreen=self.vgaGreen,
            o_Hsync=self.Hsync,
            o_Vsync=self.Vsync,
        )

