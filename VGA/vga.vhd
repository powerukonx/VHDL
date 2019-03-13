----------------------------------------------------------------------------------
-- Company:        Ukonx
-- Engineer:       Power
-- 
-- Create Date:    13:01:28 01/30/2019 
-- Design Name: 
-- Module Name:    vga - Behavioral 
-- Project Name: 
-- Target Devices: CPLD XC9536XL
-- Tool versions:  ISE Design Suite 14.7
-- Description:    VGA Pattern generator (640x480 - 60Hz)
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration IF using
-- arithmetic functions with Signed OR Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration IF instantiating
-- any Xilinx primitives IN this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY vga IS
  GENERIC (
  
    c_visible_area_length : INTEGER := 640;
    c_visible_area_high   : INTEGER := 480;
    c_screen_length_in_px : INTEGER := 800;
    c_screen_high_in_px   : INTEGER := 525;
    c_hsync_start_in_px   : INTEGER := 656;
    c_hsync_stop_in_px    : INTEGER := 752;
    c_vsync_start_in_px   : INTEGER := 490;
    c_vsync_stop_in_px    : INTEGER := 492
  );

  PORT ( 
    p_i_reset : IN   STD_LOGIC;
    p_i_clk   : IN   STD_LOGIC;
    p_o_hsync : OUT  STD_LOGIC;
    p_o_vsync : OUT  STD_LOGIC;
    p_o_red   : OUT  STD_LOGIC_VECTOR(1 DOWNTO 0);
    p_o_green : OUT  STD_LOGIC_VECTOR(1 DOWNTO 0);
    p_o_blue  : OUT  STD_LOGIC_VECTOR(1 DOWNTO 0)
  );
END vga;

ARCHITECTURE Behavioral of vga IS

  SIGNAL s_ctr_x          : UNSIGNED(9 DOWNTO 0)  := (OTHERS => '0');
  SIGNAL s_ctr_y          : UNSIGNED(9 DOWNTO 0)  := (OTHERS => '0');
  SIGNAL s_clk_25mhz      : STD_LOGIC             := '0';
  SIGNAL s_display_enable : STD_LOGIC             := '0';

  BEGIN

  -- HSYNC AND VSYNC generation
  p_o_hsync <= '0' WHEN s_ctr_x >= c_hsync_start_in_px AND s_ctr_x < c_hsync_stop_in_px ELSE '1';
  p_o_vsync <= '0' WHEN s_ctr_y >= c_vsync_start_in_px AND s_ctr_y < c_vsync_stop_in_px ELSE '1';
  
  -- Display only IN visible area
  s_display_enable <= '1' WHEN s_ctr_x < c_visible_area_length AND s_ctr_y < c_visible_area_high ELSE '0';

  -- Color pattern generation
  p_o_red(0)    <= s_ctr_x(0) AND s_ctr_y(0) WHEN s_display_enable = '1' ELSE '0';
  p_o_red(1)    <= s_ctr_x(1) AND s_ctr_y(1) WHEN s_display_enable = '1' ELSE '0';
  p_o_green(0)  <= s_ctr_x(0) OR  s_ctr_y(0) WHEN s_display_enable = '1' ELSE '0';
  p_o_green(1)  <= s_ctr_x(1) OR  s_ctr_y(1) WHEN s_display_enable = '1' ELSE '0';
  p_o_blue(0)   <= s_ctr_x(0) XOR s_ctr_y(0) WHEN s_display_enable = '1' ELSE '0';
  p_o_blue(1)   <= s_ctr_x(1) XOR s_ctr_y(1) WHEN s_display_enable = '1' ELSE '0';

  -- Divider by 2 (50MHz clock input)
  div_by2: PROCESS (p_i_reset, p_i_clk)
  BEGIN
    IF (p_i_reset = '1') THEN
      s_clk_25mhz <= '0';
    ELSIF RISING_EDGE(p_i_clk) THEN
      s_clk_25mhz <= not s_clk_25mhz;
    END IF;
  END PROCESS div_by2;

  -- X/Y counter process
  xy_ctr: PROCESS (p_i_reset, s_clk_25mhz)
  BEGIN
    IF (p_i_reset = '1') THEN
      s_ctr_x <= (OTHERS => '0');
      s_ctr_y <= "0000000001";
   ELSIF RISING_EDGE (s_clk_25mhz) THEN
    IF (s_ctr_x < c_screen_length_in_px) THEN
      s_ctr_x <= s_ctr_x + 1;
    ELSE
      s_ctr_x <= "0000000001";
      IF (s_ctr_y < c_screen_high_in_px) THEN
        s_ctr_y <= s_ctr_y + 1;
      ELSE
        s_ctr_y <= "0000000001";
      END IF;        
    END IF;
   END IF;
  END PROCESS xy_ctr;
END Behavioral;

