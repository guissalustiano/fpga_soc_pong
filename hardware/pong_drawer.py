from migen import *
from litex.soc.interconnect.csr import CSRStorage, CSRStatus

from litex.soc.interconnect.csr import AutoCSR
from litex.soc.integration.doc import AutoDoc, ModuleDoc

class PongDrawer(Module, AutoCSR, AutoDoc):
    def __init__(self):
        self.pxClk = ClockSignal("vga")
        self.rst = ResetSignal()
        self.sw = CSRStorage(16)
        self.color = CSRStorage(12)
        self.cursor_left_py = CSRStorage(12)
        self.cursor_right_py = CSRStorage(12)
        self.ball_py = CSRStorage(12)
        self.ball_px = CSRStorage(12)
        self.vgaRed = Signal(4)
        self.vgaBlue = Signal(4)
        self.vgaGreen = Signal(4)
        self.Hsync = Signal(1)
        self.Vsync = Signal(1)
        self.busy = CSRStatus(1)

        # # #

        self.specials += Instance("pong_drawer",
            i_pxClk=self.pxClk,
            i_rst=self.rst,
            i_sw=self.sw.storage,
            i_color=self.color.storage,
            i_cursor_left_py=self.cursor_left_py.storage,
            i_cursor_right_py=self.cursor_right_py.storage,
            i_ball_py=self.ball_py.storage,
            i_ball_px=self.ball_px.storage,
            o_vgaRed=self.vgaRed,
            o_vgaBlue=self.vgaBlue,
            o_vgaGreen=self.vgaGreen,
            o_Hsync=self.Hsync,
            o_Vsync=self.Vsync,
            o_busy=self.busy.status,
        )

