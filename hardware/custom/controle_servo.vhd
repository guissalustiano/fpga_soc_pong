library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
  port (
      clock    : in  std_logic;
      reset    : in  std_logic;
      posicao  : in  std_logic;  
      controle      : out std_logic 
  );
end controle_servo;

architecture rtl of controle_servo is

  constant CONTAGEM_MAXIMA : integer := 200_000;
  signal contagem     : integer range 0 to CONTAGEM_MAXIMA-1;
  signal largura_pwm  : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_largura    : integer range 0 to CONTAGEM_MAXIMA-1;
  
  signal s_controle   : std_logic;
  
begin
  controle <= s_controle;


  process(clock,reset,s_largura)
  begin
    -- inicia contagem e largura
    if(reset='1' and s_controle='0') then
      contagem    <= 0;
      s_controle  <= '0';
      largura_pwm <= s_largura;
    elsif(rising_edge(clock)) then
        -- saida
        if(contagem < largura_pwm) then
          s_controle  <= '1';
        else
          s_controle  <= '0';
        end if;
        -- atualiza contagem e largura
        if(contagem=CONTAGEM_MAXIMA-1) then
          contagem   <= 0;
          largura_pwm <= s_largura;
        else
          contagem   <= contagem + 1;
        end if;
    end if;
  end process;

  process(posicao)
  begin
    case posicao is
		-- bandeira abaixada
      when '0' =>    s_largura <=    10_000;  -- pulso de  1 ms
		-- bandeira levantada
      when '1' =>    s_largura <=   20_000;  -- pulso de 2 ms
      when others =>  s_largura <=     0;  -- nulo   saida 0
    end case;
  end process;
  
end rtl;