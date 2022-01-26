transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Digital/wp01-2021-2-grupo03-2021-2/VGA {C:/Digital/wp01-2021-2-grupo03-2021-2/VGA/VGA_driver.v}
vlog -vlog01compat -work work +incdir+C:/Digital/wp01-2021-2-grupo03-2021-2/VGA {C:/Digital/wp01-2021-2-grupo03-2021-2/VGA/buffer_ram_dp.v}
vlog -vlog01compat -work work +incdir+C:/Digital/wp01-2021-2-grupo03-2021-2/VGA {C:/Digital/wp01-2021-2-grupo03-2021-2/VGA/test_VGA.v}
vlog -vlog01compat -work work +incdir+C:/Digital/wp01-2021-2-grupo03-2021-2/VGA {C:/Digital/wp01-2021-2-grupo03-2021-2/VGA/clock75.v}
vlog -vlog01compat -work work +incdir+C:/Digital/wp01-2021-2-grupo03-2021-2/VGA/db {C:/Digital/wp01-2021-2-grupo03-2021-2/VGA/db/clock75_altpll.v}

vlog -vlog01compat -work work +incdir+C:/Digital/wp01-2021-2-grupo03-2021-2/VGA {C:/Digital/wp01-2021-2-grupo03-2021-2/VGA/test_VGA_TB.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  test_VGA_TB

add wave *
view structure
view signals
run -all
