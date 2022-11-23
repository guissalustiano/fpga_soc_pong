from migen import *

from litex.gen import LiteXModule

from litex_boards.platforms import digilent_basys3

from litex.soc.cores.clock import *
from litex.soc.integration.soc import SoCRegion
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores.led import LedChaser

from status import Status
from pong_drawer import PongDrawer

# CRG ----------------------------------------------------------------------------------------------

class _CRG(LiteXModule):
    def __init__(self, platform, sys_clk_freq):
        self.rst    = Signal()
        self.cd_sys = ClockDomain()
        self.cd_vga = ClockDomain()

        self.pll = pll = S7MMCM(speedgrade=-1)
        self.comb += pll.reset.eq(platform.request("user_btnc") | self.rst)

        pll.register_clkin(platform.request("clk100"), 100e6)
        pll.create_clkout(self.cd_sys, sys_clk_freq)
        pll.create_clkout(self.cd_vga, 102.1e6)
        platform.add_false_path_constraints(self.cd_sys.clk, pll.clkin) # Ignore sys_clk to pll.clkin path created by SoC's rst.
        #platform.add_platform_command("set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk100_IBUF]")

# BaseSoC ------------------------------------------------------------------------------------------

class BaseSoC(SoCCore):
    def __init__(self, sys_clk_freq=int(75e6), **kwargs):
        platform = digilent_basys3.Platform()
        platform.add_source_dir('hardware/custom/')

        self.submodules.button_up = Status(platform.request('user_btnu'))
        self.submodules.button_down = Status(platform.request('user_btnd'))
        self.submodules.button_left = Status(platform.request('user_btnl'))
        self.submodules.button_right = Status(platform.request('user_btnr'))

        vga = platform.request("vga")
        drawer = PongDrawer()
        self.submodules.drawer = drawer
        self.comb += [
            vga.hsync_n.eq(drawer.Hsync),
            vga.vsync_n.eq(drawer.Vsync),
            vga.r.eq(drawer.vgaRed),
            vga.g.eq(drawer.vgaGreen),
            vga.b.eq(drawer.vgaBlue),
        ]


        # CRG --------------------------------------------------------------------------------------
        self.crg = _CRG(platform, sys_clk_freq)

        # SoCCore ----------------------------------_-----------------------------------------------
        SoCCore.__init__(self, platform, sys_clk_freq, ident="LiteX SoC on Basys3", **kwargs)

        self.leds = LedChaser(
            pads         = platform.request_all("user_led"),
            sys_clk_freq = sys_clk_freq)

# Build --------------------------------------------------------------------------------------------
def main():
    from litex.soc.integration.soc import LiteXSoCArgumentParser
    parser = LiteXSoCArgumentParser(description="LiteX SoC on Basys3")
    target_group = parser.add_argument_group(title="Target options")
    target_group.add_argument("--build",               action="store_true", help="Build design.", default=True)
    target_group.add_argument("--load",                action="store_true", help="Load bitstream.")
    target_group.add_argument("--sys-clk-freq",        default=75e6,        help="System clock frequency.")
    builder_args(parser)
    soc_core_args(parser)

    parser.set_defaults(gateware_dir='./gateware')
    parser.set_defaults(software_dir='./software')
    parser.set_defaults(integrated_main_ram_size=8192)

    args = parser.parse_args()

    soc = BaseSoC(
        sys_clk_freq           = int(float(args.sys_clk_freq)),
        **soc_core_argdict(args)
    )

    builder_kwargs = builder_argdict(args)
    # Don't build software
    # builder_kwargs["compile_software"] = False

    builder = Builder(soc, **builder_kwargs)
    if args.build:
        builder.build()

    if args.load:
        prog = soc.platform.create_programmer()
        prog.load_bitstream(builder.get_bitstream_filename(mode="sram"))

if __name__ == "__main__":
    main()
