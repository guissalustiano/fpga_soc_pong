from migen import *
from litex.soc.interconnect.csr import CSRStorage, CSRStatus

from litex.soc.interconnect.csr import AutoCSR
from litex.soc.integration.doc import AutoDoc, ModuleDoc

class InterfaceHcsr04(Module, AutoCSR, AutoDoc):
    def __init__(self):
        self.clock = ClockSignal('low')
        self.reset = ResetSignal()
        self.medir = CSRStorage(1)
        self.echo = Signal(1)
        self.trigger = Signal(1)
        self.medida = CSRStatus(16)
        self.pronto = CSRStatus(1)
        # # #

        self.specials += Instance("interface_hcsr04",
            i_clock=self.clock,
            i_reset=self.reset,
            i_medir=self.medir.storage,
            i_echo=self.echo,
            o_trigger=self.trigger,
            o_medida=self.medida.status,
            o_pronto=self.pronto.status,
	    )
