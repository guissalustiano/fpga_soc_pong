from migen import *
from litex.soc.interconnect.csr import CSRStorage, CSRStatus

from litex.soc.interconnect.csr import AutoCSR
from litex.soc.integration.doc import AutoDoc, ModuleDoc


class Contador(Module, AutoCSR, AutoDoc):

    def __init__(self, width):
        self.intro = ModuleDoc("""Counter
    Provides a generic Counter core.
    """)
        self.width = width
        self.clock = ClockSignal()
        self.zera = ResetSignal()
        self.conta = CSRStorage()
        self.contagem = CSRStatus(self.width)
        self.fim = CSRStatus()

        # # #

        self.specials += Instance("contador",
            p_MODULO=2**self.width,
            i_clock=self.clock,
            i_zera=self.zera,
            i_conta=self.conta.storage,
            o_contagem=self.contagem.status,
            o_fim=self.fim.status,
        )

