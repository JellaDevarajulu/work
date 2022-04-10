#!/bin/sh
# csv2dict_example.tcl \
exec tclsh "$0" ${1+"$@"}


source csv2table.tcl
set file_path "./data/table_data.csv"

::c2d::read_csv $file_path

#puts $::c2d::data
puts "Table header:\n\t $::c2d::header"
puts "Table col_bit_size:\n\t $::c2d::col_bit_size"
puts "Table data:\n\t $::c2d::data"

puts "Table primary_column keys:\n\t [dict keys $::c2d::data]"

puts "LL_1P5_P45 when_condition : '[::c2d::get_when_code LL_1P5_P45 {tccode tlcode} '&']'"
