# Настройка системного тактирования (200 MHz)
set_property IOSTANDARD LVDS [get_ports clk_p]
set_property PACKAGE_PIN E19 [get_ports clk_p]
set_property IOSTANDARD LVDS [get_ports clk_n]
set_property PACKAGE_PIN E18 [get_ports clk_n]
# Задание временных ограничений
create_clock -period 5.000 -name clk_p -waveform {0.000 2.500} [get_ports clk_p]

# Светодиоды (LEDS)
set_property IOSTANDARD LVCMOS18 [get_ports {leds[*]}]
set_property PACKAGE_PIN AM39 [get_ports {leds[0]}]
set_property PACKAGE_PIN AN39 [get_ports {leds[1]}]
set_property PACKAGE_PIN AR37 [get_ports {leds[2]}]
set_property PACKAGE_PIN AT37 [get_ports {leds[3]}]
set_property PACKAGE_PIN AR35 [get_ports {leds[4]}]
set_property PACKAGE_PIN AP41 [get_ports {leds[5]}]
set_property PACKAGE_PIN AP42 [get_ports {leds[6]}]
set_property PACKAGE_PIN AU39 [get_ports {leds[7]}]

# Кнопки (BUTTONS)
# btns[0] - Center (AV40) -> Кнопка навигации 1
set_property PACKAGE_PIN AW40 [get_ports {btns[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {btns[0]}]
# btns[1] - North (AR40) -> Кнопка навигации 2
set_property PACKAGE_PIN AV39 [get_ports {btns[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {btns[1]}]
# btns[2] - South (AP40)
set_property PACKAGE_PIN AU38 [get_ports {btns[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {btns[2]}]
# btns[3] - East (AU38)
set_property PACKAGE_PIN AP40 [get_ports {btns[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {btns[3]}]
# btns[4] - West (AW40) -> Переключение режима ЛР2 / ЛР3
set_property PACKAGE_PIN AR40 [get_ports {btns[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {btns[4]}]

# LCD Display signals 
# DB[7:4] connected to FPGA
set_property PACKAGE_PIN AT42 [get_ports {LCD_D[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LCD_D[0]}]

set_property PACKAGE_PIN AR38 [get_ports {LCD_D[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LCD_D[1]}]

set_property PACKAGE_PIN AR39 [get_ports {LCD_D[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LCD_D[2]}]

set_property PACKAGE_PIN AN40 [get_ports {LCD_D[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LCD_D[3]}]

# Control signals
set_property PACKAGE_PIN AN41 [get_ports LCD_RS]
set_property IOSTANDARD LVCMOS18 [get_ports LCD_RS]

set_property PACKAGE_PIN AR42 [get_ports LCD_RW]
set_property IOSTANDARD LVCMOS18 [get_ports LCD_RW]

set_property PACKAGE_PIN AT40 [get_ports LCD_E]
set_property IOSTANDARD LVCMOS18 [get_ports LCD_E]
