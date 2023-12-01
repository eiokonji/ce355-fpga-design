
setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vcom -work work "clock_counter.vhd"
vcom -work work "tank.vhd"
vcom -work work "bullet.vhd"
vcom -work work "inc_score.vhd"
vcom -work work "game_state.vhd"
vcom -work work "pll.vhd"
vcom -work work "game.vhd"
vcom -work work "demo_tb.vhd"


add wave -noupdate -group demo_tb
add wave -noupdate -group demo_tb -radix unsigned /testbench/*

add wave -noupdate -group demo_tb/dut
add wave -noupdate -group demo_tb/dut -radix unsigned /testbench/dut/*

add wave -noupdate -group demo_tb/dut/clockCount
add wave -noupdate -group demo_tb/dut/clockCount -radix unsigned /testbench/dut/clockCount/*

add wave -noupdate -group demo_tb/dut/tankAModule
add wave -noupdate -group demo_tb/dut/tankAModule -radix unsigned /testbench/dut/tankAModule/*

add wave -noupdate -group demo_tb/dut/tankBModule
add wave -noupdate -group demo_tb/dut/tankBModule -radix unsigned /testbench/dut/tankBModule/*

add wave -noupdate -group demo_tb/dut/bulletAModule
add wave -noupdate -group demo_tb/dut/bulletAModule -radix unsigned /testbench/dut/bulletAModule/*

add wave -noupdate -group demo_tb/dut/bulletBModule
add wave -noupdate -group demo_tb/dut/bulletBModule -radix unsigned /testbench/dut/bulletBModule/*

add wave -noupdate -group demo_tb/dut/scoreA
add wave -noupdate -group demo_tb/dut/scoreA -radix unsigned /testbench/dut/scoreA/*

add wave -noupdate -group demo_tb/dut/scoreB
add wave -noupdate -group demo_tb/dut/scoreB -radix unsigned /testbench/dut/scoreB/*

add wave -noupdate -group demo_tb/dut/gameState
add wave -noupdate -group demo_tb/dut/gameState -radix unsigned /testbench/dut/gameState/*



run -all
