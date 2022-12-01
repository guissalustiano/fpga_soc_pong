from migen import *
from litex.soc.interconnect.csr import CSRStatus

from litex.soc.interconnect.csr import AutoCSR

class DistanceSensor(Module, AutoCSR):
    def __init__(self):
        self.clock = ClockSignal('low')
        self.reset = ResetSignal()
        self.echo = Signal(1)
        self.trigger = Signal(1)
        self.medida = CSRStatus(16)
        self.pronto = CSRStatus(1)

        # # #

        self.specials += Instance("continuous_measure",
            i_clock=self.clock,
            i_reset=self.reset,
            i_echo=self.echo,
            o_trigger=self.trigger,
            o_medida=self.medida.status,
            o_pronto=self.pronto.status,
	    )
