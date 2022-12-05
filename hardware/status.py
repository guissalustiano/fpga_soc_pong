from migen import *
from litex.soc.interconnect.csr import CSRStatus

from litex.soc.interconnect.csr import AutoCSR


class Status(Module, AutoCSR):

    def __init__(self, input_):
        self.output = CSRStatus()

        # # #

        self.comb += self.output.status.eq(input_)
