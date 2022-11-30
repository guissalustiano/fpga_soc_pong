--------------------------------------------------------------------
-- Arquivo   : contador_bcd_3digitos.vhd
-- Projeto   : Experiencia 4 - Interface com Sensor de Distancia
--------------------------------------------------------------------
-- Descricao : contador bcd com 3 digitos - modulo 1000
--             (descricao VHDL comportamental)
--
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     26/09/2020  1.2     Edson Midorikawa  revisao
--     09/09/2022  2.0     Edson Midorikawa  revisao
--------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador is
    port (
        clock   : in  std_logic;
        zera    : in  std_logic;
        conta   : in  std_logic;
        contagem : out std_logic_vector(11 downto 0);
        fim     : out std_logic
    );
end entity;

architecture comportamental of contador is

    signal s_contagem : unsigned(11 downto 0);

begin

    process (clock)
    begin
        if (clock'event and clock = '1') then
            if (zera = '1') then  -- reset sincrono
                s_contagem <= (others => '0');
            elsif ( conta = '1' ) then
                s_contagem <= s_contagem + 1;
            end if;
        end if;
    end process;

    -- fim de contagem (comando VHDL when else)
    fim <= '1' when s_contagem = "111111111111" else
           '0';

    contagem <= std_logic_vector(s_contagem);

end architecture comportamental;

------------------------------------------------------
------------------------------------------------------
------------------------------------------------------

------------------------------------------------------------------
-- Arquivo   : analisa_m.vhd
-- Projeto   : Experiencia 4 - Interface com Sensor de Distancia
------------------------------------------------------------------
-- Descricao : analisa valor binario de entrada
--             > parametro M: modulo
--
--             saidas zera, meio, fim e metade_superior
--
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2022  1.0     Edson Midorikawa  versao inicial
------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity analisa_m is
    generic (
        constant M : integer := 50;  
        constant N : integer := 6 
    );
    port (
        valor            : in  std_logic_vector (N-1 downto 0);
        zero             : out std_logic;
        meio             : out std_logic;
        fim              : out std_logic;
        metade_superior  : out std_logic
    );
end entity analisa_m;

architecture comportamental of analisa_m is
    signal v: integer range 0 to M-1;
begin
  
    v <= to_integer(unsigned(valor));

    zero            <= '1' when v=0 else '0';
    meio            <= '1' when v=M/2 else '0';
    fim             <= '1' when v=M-1 else '0';
    metade_superior <= '1' when v>=M/2 else '0';

end architecture;

------------------------------------------------------
------------------------------------------------------
------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity contador_cm_fd is
	generic (
		constant R : integer; -- Ciclos contados para 1 cm
		constant N : integer  -- Tamanho em bits do contador de 1 cm
	);
	port (
		clock      : in  std_logic;
		
		-- Entradas de controle
		conta_bcd  : in  std_logic;
		zera_bcd   : in  std_logic;
		conta_tick : in  std_logic;
		zera_tick  : in  std_logic;
		
		-- Saidas de controle
		fim       : out std_logic;
		arredonda : out std_logic;
		tick      : out std_logic;

		-- Saida da contagem
        contagem : out std_logic_vector(11 downto 0)
	);
end entity;

architecture arch of contador_cm_fd is
component contador is 
    port ( 
        clock   : in  std_logic;
        zera    : in  std_logic;
        conta   : in  std_logic;
        contagem : out std_logic_vector(11 downto 0);
        fim     : out std_logic
    );
end component;

component analisa_m is
    generic (
        constant M : integer := 50;  
        constant N : integer := 6 
    );
    port (
        valor            : in  std_logic_vector (N-1 downto 0);
        zero             : out std_logic;
        meio             : out std_logic;
        fim              : out std_logic;
        metade_superior  : out std_logic
    );
end component;

component contador_m is
    generic (
        constant M : integer := 50;  
        constant N : integer := 6 
    );
    port (
        clock : in  std_logic;
        zera  : in  std_logic;
        conta : in  std_logic;
        Q     : out std_logic_vector (N-1 downto 0);
        fim   : out std_logic;
        meio  : out std_logic
    );
end component;

signal s_contagem_tick: std_logic_vector(N-1 downto 0);

begin
	-- Conta a cada centimetro (tick de cm), se for necessario arrendondar para cima recebe mais um
	cont_bcd: contador port map(
		clock => clock,
		zera => zera_bcd,
		conta => conta_bcd,
		contagem => contagem,
		fim => fim
	);
	
	-- Decide se deve arredondar antes de devolver o resultado
	comp_arredonda: analisa_m generic map(
		M => R,
		N => N
	) 
	port map(
		valor => s_contagem_tick,
      zero => open,
      meio => open,
      fim  => open,
      metade_superior => arredonda
	);
	
	-- Gera os ticks a cada cm
	cont_tick: contador_m generic map(
		M => R,
		N => N
	)
	port map(
		clock => clock,
      zera => zera_tick,
      conta => conta_tick,
      Q => s_contagem_tick,
      fim => tick,
      meio => open
	);
end architecture;

------------------------------------------------------
------------------------------------------------------
------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity contador_cm_uc is 
	port ( 
		clock      : in std_logic;
		reset      : in std_logic;

		pulso		  : in std_logic;
		fim        : in std_logic;
		arredonda  : in std_logic;
		tick       : in std_logic;
		
		conta_bcd  : out std_logic;
		zera_bcd   : out std_logic;
		conta_tick : out std_logic;
		zera_tick  : out std_logic;
		pronto 	  : out std_logic
	);
end contador_cm_uc;

architecture fsm_arch of contador_cm_uc is
    type tipo_estado is (espera, prepara, incrementa_tk, incrementa_cm, final);
    signal Eatual, Eprox: tipo_estado;
begin

    -- estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= espera;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox;
        end if;
    end process;

    -- logica de proximo estado
    process (pulso, fim, arredonda, tick, Eatual) 
    begin
      case Eatual is
        when espera =>          if pulso='1' then Eprox <= prepara;
                                else              Eprox <= espera;
                                end if;
										  
		  when prepara =>             Eprox <= incrementa_tk;
										  
        when incrementa_tk =>   if pulso='0' and arredonda='0' then Eprox <= final;
										  elsif pulso='0' and arredonda='1' then Eprox <= incrementa_cm; -- Precisa contar mais 1 para arredondar
										  elsif fim='1' then Eprox <= final; -- Acabou contagem do BCD, finaliza retornando valor maximo
										  elsif tick='1' then Eprox <= incrementa_cm; -- Recebeu tick para incrementar 1 cm
                                else              Eprox <= incrementa_tk;
                                end if;
										  
        when incrementa_cm =>   if pulso='0' then Eprox <= final;
                                else              Eprox <= incrementa_tk;
                                end if;

        when final =>             Eprox <= espera;
		  
        when others =>          Eprox <= espera;
      end case;
    end process;

  -- saidas de controle
  with Eatual select 
      zera_bcd <= '1' when prepara, '0' when others;
  with Eatual select 
      zera_tick <= '1' when prepara, '0' when others;
  with Eatual select 
      conta_bcd <= '1' when incrementa_cm, '0' when others;
  with Eatual select 
      conta_tick <= '1' when incrementa_tk, '0' when others;
  with Eatual select 
      pronto <= '1' when final, '0' when others;
		
end architecture fsm_arch;

------------------------------------------------------
------------------------------------------------------
------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity contador_cm is
	generic (
		constant R : integer;
		constant N : integer
	);
	port (
		clock   : in  std_logic;
		reset   : in  std_logic;
		pulso   : in  std_logic;
		contagem : out std_logic_vector(11 downto 0);
		pronto  : out std_logic
	);
end entity;

architecture arch of contador_cm is

component contador_cm_uc is 
	port ( 
		clock      : in std_logic;
		reset      : in std_logic;

		pulso		  : in std_logic;
		fim        : in std_logic;
		arredonda  : in std_logic;
		tick       : in std_logic;
		
		conta_bcd  : out std_logic;
		zera_bcd   : out std_logic;
		conta_tick : out std_logic;
		zera_tick  : out std_logic;
		pronto 	  : out std_logic
	);
end component;

component contador_cm_fd is
	generic (
		constant R : integer; -- Ciclos contados para 1 cm
		constant N : integer  -- Tamanho em bits do contador de 1 cm
	);
	port (
		clock      : in  std_logic;
		
		-- Entradas de controle
		conta_bcd  : in  std_logic;
		zera_bcd   : in  std_logic;
		conta_tick : in  std_logic;
		zera_tick  : in  std_logic;
		
		-- Saidas de controle
		fim       : out std_logic;
		arredonda : out std_logic;
		tick      : out std_logic;

		-- Saida da contagem
		contagem   : out std_logic_vector(11 downto 0)
	);
end component;

signal s_fim_cont_bcd, s_arredonda, s_tick, s_conta_bcd,
s_zera_bcd, s_conta_tick, s_zera_tick : std_logic;

begin

	-- Conta a cada centimetro (tick de cm), se for necessario arrendondar para cima recebe mais um
	uc: contador_cm_uc port map(
		clock => clock,
		reset => reset,

		pulso	=> pulso,
		fim => s_fim_cont_bcd,
		arredonda => s_arredonda,
		tick => s_tick,
		
		conta_bcd => s_conta_bcd,
		zera_bcd => s_zera_bcd,
		conta_tick => s_conta_tick,
		zera_tick => s_zera_tick,
		pronto => pronto
	);
	
	fd: contador_cm_fd generic map(R => R, N => N) port map(
		clock => clock,
		conta_bcd => s_conta_bcd,
		zera_bcd => s_zera_bcd,
		conta_tick => s_conta_tick,
		zera_tick => s_zera_tick,
		fim => s_fim_cont_bcd,
		arredonda => s_arredonda,
		tick => s_tick,

		-- Saida da contagem
		contagem => contagem
	);
	

end architecture;

--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------

-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : registrador_n.vhd
-- Projeto   : Experiencia 4 - Interface com sensor de distancia
-------------------------------------------------------------------------
-- Descricao : gera pulso de saida com largura pulsos de clock
--             
--             parametro generic: largura
--             
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2019  1.0     Edson Midorikawa  criacao 
--     12/09/2022  1.1     Edson Midorikawa  revisao do codigo
-------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gerador_pulso is
   generic (
        largura: integer:= 25
   );
   port(
        clock  : in  std_logic;
        reset  : in  std_logic;
        gera   : in  std_logic;
        para   : in  std_logic;
        pulso  : out std_logic;
        pronto : out std_logic
   );
end entity gerador_pulso;

architecture fsm_arch of gerador_pulso is

   type tipo_estado is (parado, contagem, final);
   signal reg_estado, prox_estado: tipo_estado;
   signal reg_cont, prox_cont: integer range 0 to largura-1;

begin

   -- logica de estado e contagem
   process(clock,reset)
   begin
      if (reset='1') then
         reg_estado <= parado;
         reg_cont <= 0;
      elsif (clock'event and clock='1') then
         reg_estado <= prox_estado;
         reg_cont <= prox_cont;
      end if;
   end process;

   -- logica de proximo estado e contagem
   process(reg_estado, gera, para, reg_cont)
   begin
      pulso <= '0';
      pronto <= '0';
      prox_cont <= reg_cont;

      case reg_estado is

         when parado =>
            if gera='1' then
               prox_estado <= contagem;
            else
               prox_estado <= parado;
            end if;
            prox_cont <= 0;

         when contagem =>
            if para='1' then
               prox_estado <= parado;
            else
               if (reg_cont=largura-1) then
                  prox_estado <= final;
               else
                  prox_estado <= contagem;
                  prox_cont <= reg_cont + 1;
               end if;
            end if;
            pulso <= '1';

         when final =>
            prox_estado <= parado;
            pronto <= '1';
      end case;
   end process;

end architecture fsm_arch;

-------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity interface_hcrs04_fd is
	port (
		clock      : in std_logic;
		pulso      : in std_logic;
		zera       : in std_logic;
		registra   : in std_logic;
		gera       : in std_logic;
		reset      : in std_logic;
		
		fim        : out std_logic;
		fim_medida : out std_logic;
		trigger    : out std_logic;
		
		distancia : out std_logic_vector(11 downto 0)
	);
end entity;

architecture arch of interface_hcrs04_fd is

component contador_cm is
	generic (
		constant R : integer;
		constant N : integer
	);
	port (
		clock   : in  std_logic;
		reset   : in  std_logic;
		pulso   : in  std_logic;
		contagem : out std_logic_vector(11 downto 0);
		pronto  : out std_logic
	);
end component;

component registrador_n is
    generic (
       constant N: integer := 8 
    );
    port (
       clock  : in  std_logic;
       clear  : in  std_logic;
       enable : in  std_logic;
       D      : in  std_logic_vector (N-1 downto 0);
       Q      : out std_logic_vector (N-1 downto 0) 
    );
end component;

component gerador_pulso is
   generic (
        largura: integer:= 25
   );
   port(
        clock  : in  std_logic;
        reset  : in  std_logic;
        gera   : in  std_logic;
        para   : in  std_logic;
        pulso  : out std_logic;
        pronto : out std_logic
   );
end component;

signal s_contagem: std_logic_vector(11 downto 0);
signal s_limpa_reg: std_logic;

begin

	cont_cm: contador_cm generic map(R=>2941, N=>12) port map(
		clock   => clock,
		reset   => zera,
		pulso   => pulso,   
		contagem => s_contagem,
		pronto  => fim_medida
	);
	
	reg_saida: registrador_n generic map(12) port map(
		clock => clock,
		clear => s_limpa_reg,
		enable => registra,
		D => s_contagem,
		Q => distancia
	);
	
	gen_pulso: gerador_pulso generic map(500) port map(
      clock => clock,
      reset => zera,
      gera => gera,
      para => '0',
      pulso => trigger,
      pronto => open
	);
	
	s_limpa_reg <= zera or reset;

end architecture;

-------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------

--------------------------------------------------------------------
-- Arquivo   : interface_hcsr04_uc.vhd
-- Projeto   : Experiencia 4 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : unidade de controle do circuito de interface com
--             sensor de distancia
--             
--             implementa arredondamento da medida
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     03/09/2022  1.1     Edson Midorikawa  revisao
--------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;

entity interface_hcsr04_uc is 
    port ( 
        clock      : in  std_logic;
        reset      : in  std_logic;
        medir      : in  std_logic;
        echo       : in  std_logic;
        fim_medida : in  std_logic;
        zera       : out std_logic;
        gera       : out std_logic;
        registra   : out std_logic;
        pronto     : out std_logic;
        db_estado  : out std_logic_vector(3 downto 0) 
    );
end interface_hcsr04_uc;

architecture fsm_arch of interface_hcsr04_uc is
    type tipo_estado is (inicial, preparacao, envia_trigger, 
                         espera_echo, medida, armazenamento, final);
    signal Eatual, Eprox: tipo_estado;
begin

    -- estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    process (medir, echo, fim_medida, Eatual) 
    begin
      case Eatual is
        when inicial =>         if medir='1' then Eprox <= preparacao;
                                else              Eprox <= inicial;
                                end if;
        when preparacao =>      Eprox <= envia_trigger;
        when envia_trigger =>   Eprox <= espera_echo;
        when espera_echo =>     if echo='0' then Eprox <= espera_echo;
                                else             Eprox <= medida;
                                end if;
        when medida =>          if fim_medida='1' then Eprox <= armazenamento;
                                else                   Eprox <= medida;
                                end if;
        when armazenamento =>   Eprox <= final;
        when final =>           Eprox <= inicial;
        when others =>          Eprox <= inicial;
      end case;
    end process;

  -- saidas de controle
  with Eatual select 
      zera <= '1' when preparacao, '0' when others;
  with Eatual select
      gera <= '1' when envia_trigger, '0' when others;
  with Eatual select
      registra <= '1' when armazenamento, '0' when others;
  with Eatual select
      pronto <= '1' when final, '0' when others;

  with Eatual select
      db_estado <= "0000" when inicial, 
                   "0001" when preparacao, 
                   "0010" when envia_trigger, 
                   "0011" when espera_echo,
                   "0100" when medida, 
                   "0101" when armazenamento, 
                   "1111" when final, 
                   "1110" when others;

end architecture fsm_arch;

------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity interface_hcsr04 is
	port (
		clock : in std_logic;
		reset : in std_logic;
		medir : in std_logic;
		echo : in std_logic;
		trigger : out std_logic;
		medida : out std_logic_vector(11 downto 0); -- 3 digitos BCD
		pronto : out std_logic;
	); 
end entity interface_hcsr04;

architecture arch of interface_hcsr04 is

component interface_hcrs04_fd is
	port (
		clock      : in std_logic;
		pulso      : in std_logic;
		zera       : in std_logic;
		registra   : in std_logic;
		gera       : in std_logic;
		reset      : in std_logic;
		
		fim        : out std_logic;
		fim_medida : out std_logic;
		trigger    : out std_logic;
		
		distancia : out std_logic_vector(11 downto 0)
	);
end component;

component interface_hcsr04_uc is 
    port ( 
        clock      : in  std_logic;
        reset      : in  std_logic;
        medir      : in  std_logic;
        echo       : in  std_logic;
        fim_medida : in  std_logic;
        zera       : out std_logic;
        gera       : out std_logic;
        registra   : out std_logic;
        pronto     : out std_logic;
        db_estado  : out std_logic_vector(3 downto 0) 
    );
end component;

signal s_zera, s_registra, s_gera, s_fim_medida: std_logic;

begin
	fd: interface_hcrs04_fd port map(
		clock => clock,
		pulso => echo,
		zera => s_zera,
		registra => s_registra,
		gera => s_gera,
		reset => reset,
		
		fim => open,
		fim_medida => s_fim_medida,
		trigger => trigger,
		
		distancia => medida
	);
	
	uc: interface_hcsr04_uc port map(
		clock => clock,
		reset => reset,
		medir => medir,
		echo => echo,
		fim_medida => s_fim_medida,
		zera => s_zera,
		gera => s_gera,
		registra => s_registra,
		pronto => pronto,
	);

end architecture;
