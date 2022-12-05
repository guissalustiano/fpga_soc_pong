from migen import *
from litex.soc.interconnect.csr import CSRStorage, CSRStatus

from litex.soc.interconnect.csr import AutoCSR
from litex.soc.integration.doc import AutoDoc, ModuleDoc

class ServoControl(Module, AutoCSR, AutoDoc):
    def __init__(self):
        self.clock = ClockSignal('low')
        self.reset = ResetSignal()
        self.posicao = CSRStorage(1)
        self.controle = Signal(1)
        # # #

        self.specials += Instance("controle_servo",
            i_clock=self.clock,
            i_reset=self.reset,
            i_posicao=self.posicao.storage,
            o_controle=self.controle,
        )

