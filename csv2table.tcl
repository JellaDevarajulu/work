#!/bin/sh
# csv2dict.tcl \
exec tclsh "$0" ${1+"$@"}

namespace eval c2d {
	# Create a variable inside the namespace
	variable header
	variable data
	variable col_bit_size ; # Bit size of each column

	proc get_map {header row line_no} {
		
		set h_size [llength $header]
		set r_size [llength $row]
		
		if {$h_size != $r_size} {
			puts "Invalid row : $line_no, header size: $h_size != row size $r_size"
			return 
		}
		
		set row_dict [dict create]
    	foreach k $header v $row {
    		dict append row_dict $k $v
    	}
		
		return $row_dict
	}
	
	proc read_csv { csvIn } {
		puts "Reading file '$csvIn'"
		set fpIn [open $csvIn r]
		set header [list ]
		set col_bit_size [dict create]
		set data ""
		set line_no 0
		
		while {[gets $fpIn line] >= 0} {
			regsub {"\s+"} "" $line 
			regsub {#.*} "" $line
			incr line_no
			
			set row [ split $line ","]
#			set row [string map { , " " } $line
            if { [llength $header] == 0 } {
            	set header  $row
            	continue
            } 
		
			if { [dict size $col_bit_size] == 0 } {
				set col_bit_size [get_map $header $row $line_no]
				continue
			}
			
			set r_data [get_map $header $row, $line_no]
			set key [lindex $row 0 ]
			dict append data $key $r_data
		}
		
		close $fpIn

#		Updating namespace with values
		set ::c2d::header $header
		set ::c2d::col_bit_size $col_bit_size
		set ::c2d::data $data
		
		
		return $data
	}
	
	proc get_when_code {key columns join_opr} {
#		Creates when condition for columns and joins with 'join_opr'
		set table_data $::c2d::data
		set cols_bit_size $::c2d::col_bit_size
		set output [list]
		set row [dict get $table_data $key]
	
		foreach column $columns {
    		set col_bit [dict get $cols_bit_size $column]
    		set col_val [dict get $row $column]
    	
    		set val [get_col_when_code $column $col_val $col_bit]
    	
    		lappend output $val
		}
	
		return [join $output $join_opr]
	}

    proc get_col_when_code {col val bitsize} {
#		Convert when condition for given value with specific bit format
#		Example 
#			inputs : col1 3 4
#			output : 0011 == > "!col_3&!col_2&col_1&col_0"
		
    	set tmplt "%0${bitsize}b"
    	set binary_str [format $tmplt $val]
    
    	# for loop execution
    	set size [string length $binary_str]
    
    	# Create empty list
    	set col_cond [list ]
    
    	for { set pos 0}  {$pos < $size} {incr pos} {
    	set val [string index $binary_str $pos]
    	set pos_val [expr $size - 1 - $pos]
    
    	if {$val == "0"} {
    		set f_val  "!${col}_${pos_val}"
    	} else {
    		set f_val "${col}_${pos_val}"
    	}
    
    	lappend col_cond $f_val
    
    	}
    
    	set col_code [join $col_cond "&"]
    	return $col_code
    
    }
	
}

