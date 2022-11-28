-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : circuito_pwm.vhd
-- Projeto   : Experiencia 1 - Controle de um servomotor
-------------------------------------------------------------------------
-- Descricao : 
--             codigo VHDL RTL gera saída digital com modulacao pwm
--
-- parametros de configuracao da saida pwm: CONTAGEM_MAXIMA e largura_pwm
-- (considerando clock de 50MHz ou periodo de 20ns)
--
-- CONTAGEM_MAXIMA=1250 gera um sinal periodo de 4 KHz (25us)
-- entrada LARGURA controla o tempo de pulso em 1:
-- 00=0 (saida nula), 01=pulso de 1us, 10=pulso de 10us, 11=pulso de 20us
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     26/09/2021  1.0     Edson Midorikawa  criacao
--     24/08/2022  1.1     Edson Midorikawa  revisao
-------------------------------------------------------------------------
--
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

  constant CONTAGEM_MAXIMA : integer := 1_000_000;  -- valor para frequencia da saida de 4KHz 
                                               -- ou periodo de 25us
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
      when '0' =>    s_largura <=    75_000;  -- pulso de  1.5 ms
		-- bandeira levantada
      when '1' =>    s_largura <=   100_000;  -- pulso de 2 ms
      when others =>  s_largura <=     0;  -- nulo   saida 0
    end case;
  end process;
  
end rtl;