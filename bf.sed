#!/bin/sed -f

# A brainfuck interpreter in sed
# Andreas Fett <a.fett@gmx.de> found this in his $HOME in 2011.
# It was probably produced by a corrupt filesystem,
# cosmic rays, or bored sprites.

# It works for the wikipedia 'Hello World' example.

# Machine model:
# The pattern space is divded by semicolons
# in three parts A;B;C
#
# A is used as the stack. It contains '[' characters signifying
#   stack depth
#
# B is used as the "infinite data array". Cells hold the two digit ascii
#   representation of hexadecimal values ranging from 00 to FF. The
#   current cell is marked with the character '#'. All cells are 
#   seperated by a space ' ' character. If a cell is inserted at the front
#   or back due to a '<' or '>' command, it is initialized with 00
#
# C stores the current and all BF instructions whithin the outmost
#   enclosing loop ie. '[' ']' pair. The current instruction (ip) is
#   marked with the character '@'. The beginning of current (having
#   same nesting level als the current instruction) loop is marked
#   with '&'.

# The machine supports output, one character per line but no input.

# Initialize the machine.
# The stack is empty.
# We start with one data cell containing 0x00.
# The instruction pointer is placed at the start.
1 {
	x
	s/^/;#00;@/
	x
}

# Read source code.
#	i \DEBUG read
# Remove non command characters
	s/[^][+<>.,-]//g
# skip empty lines
/^$/ 	b
# Append the source to the hold space.
	H
# Then and replace the pattern space with the result
	g
	s/\n//g
:next
#	i \begin DEBUG
#	p
#	i \end DEBUG

# Reset the conditional branch flag
# by executing it as a noop if it is set.
	t reset_t
:reset_t

# Forward scan after '['. Don't execute, just stack ops.
/^[[]/ {
# If ip is [ push it.
	/@[[]/ { s/^/[/; b bottom }
# If ip is ] pop it.
	/@[]]/ s/^[[]//
	b bottom
}

# Execute command
/@[+]/	b call_inc
/@[-]/	b call_dec
/@[>]/  b call_fwd
/@[<]/  b call_rew
/@[.]/  b call_out
/@[,]/  b call_inp

# Begin loop
/@[[]/ 	{
# case false:
# Push it on the stack to start forward scan.
	/#00/ { s/^/[/; b bottom }
# case true:
# Discard the old label.
	s/&[[]/[/
# Mark this label.
	s/@[[]/\&@[/
	b bottom
}

# End loop
/@[]]/	{
# case false:
	/#00/ {
# If it's the outmost level discard it.
# The closing ']' will be eaten after
# the ip has advanced.
		s/;&[[].*@/;@/; t bottom
# Move the jump marker to the enclosing '['.
		s/\([[][^[]*\)&/\&\1/
# Continue with next command.
		b bottom
	}
# case true:
	s/@//;
	s/&/\&@/;
	b bottom;
}

	i \error unknown command
	q

# Move data pointer forward
:call_fwd
#	i \DEBUG fwd
# last cell, so create a new one
	s/#\([A-F0-9][A-F0-9]\);/\1 #00;/; t bottom
# any other cell
	s/#\([A-F0-9][A-F0-9]\) \([A-F0-9][A-F0-9]\)/\1 #\2/
	b bottom

# Move data pointer backward
:call_rew
#	i \DEBUG rew
# first cell, so create a new one
	s/;#\([A-F0-9][A-F0-9]\)/;#00 \1/; t bottom
# any other cell
	s/\([A-F0-9][A-F0-9]\) #\([A-F0-9][A-F0-9]\)/#\1 \2/
	b bottom

# Increment current cell
:call_inc
#	i \DEBUG inc
	s/#\(.\)0/#\11/; t bottom
	s/#\(.\)1/#\12/; t bottom
	s/#\(.\)2/#\13/; t bottom
	s/#\(.\)3/#\14/; t bottom
	s/#\(.\)4/#\15/; t bottom
	s/#\(.\)5/#\16/; t bottom
	s/#\(.\)6/#\17/; t bottom
	s/#\(.\)7/#\18/; t bottom
	s/#\(.\)8/#\19/; t bottom
	s/#\(.\)9/#\1A/; t bottom
	s/#\(.\)A/#\1B/; t bottom
	s/#\(.\)B/#\1C/; t bottom
	s/#\(.\)C/#\1D/; t bottom
	s/#\(.\)D/#\1E/; t bottom
	s/#\(.\)E/#\1F/; t bottom
# carry
	s/#0F/#10/; t bottom
	s/#1F/#20/; t bottom
	s/#2F/#30/; t bottom
	s/#3F/#40/; t bottom
	s/#4F/#50/; t bottom
	s/#5F/#60/; t bottom
	s/#6F/#70/; t bottom
	s/#7F/#80/; t bottom
	s/#8F/#90/; t bottom
	s/#9F/#A0/; t bottom
	s/#AF/#B0/; t bottom
	s/#BF/#C0/; t bottom
	s/#CF/#D0/; t bottom
	s/#DF/#E0/; t bottom
	s/#EF/#F0/; t bottom
# overflow
	s/#FF/#00/; t bottom
	i \error in increment
	q

# Decrement current cell
:call_dec
#	i \DEBUG dec
	s/#\(.\)F/#\1E/; t bottom
	s/#\(.\)E/#\1D/; t bottom
	s/#\(.\)D/#\1C/; t bottom
	s/#\(.\)C/#\1B/; t bottom
	s/#\(.\)B/#\1A/; t bottom
	s/#\(.\)A/#\19/; t bottom
	s/#\(.\)9/#\18/; t bottom
	s/#\(.\)8/#\17/; t bottom
	s/#\(.\)7/#\16/; t bottom
	s/#\(.\)6/#\15/; t bottom
	s/#\(.\)5/#\14/; t bottom
	s/#\(.\)4/#\13/; t bottom
	s/#\(.\)3/#\12/; t bottom
	s/#\(.\)2/#\11/; t bottom
	s/#\(.\)1/#\10/; t bottom
# carry
	s/#F0/#EF/; t bottom
	s/#E0/#DF/; t bottom
	s/#D0/#CF/; t bottom
	s/#C0/#BF/; t bottom
	s/#B0/#AF/; t bottom
	s/#A0/#9F/; t bottom
	s/#90/#8F/; t bottom
	s/#80/#7F/; t bottom
	s/#70/#6F/; t bottom
	s/#60/#5F/; t bottom
	s/#50/#4F/; t bottom
	s/#40/#3F/; t bottom
	s/#30/#2F/; t bottom
	s/#20/#1F/; t bottom
	s/#10/#0F/; t bottom
# underflow
	s/#00/#FF/; t bottom
	i \error in decrement
	q

# Output current cell
:call_out
# Save the pattern space
	h
# This is long ... and we just do 7bit ASCII
	s/^.*#00.*$/NUL/; t out_out
	s/^.*#01.*$/SOH/; t out_out
	s/^.*#02.*$/STX/; t out_out
	s/^.*#03.*$/ETX/; t out_out
	s/^.*#04.*$/EOT/; t out_out
	s/^.*#05.*$/ENQ/; t out_out
	s/^.*#06.*$/ACK/; t out_out
	s/^.*#07.*$/BEL/; t out_out
	s/^.*#08.*$/BS/; t out_out
	s/^.*#09.*$/HT/; t out_out
	s/^.*#0A.*$/LF/; t out_out
	s/^.*#0B.*$/VT/; t out_out
	s/^.*#0C.*$/FF/; t out_out
	s/^.*#0D.*$/CR/; t out_out
	s/^.*#0E.*$/SO/; t out_out
	s/^.*#0F.*$/SI/; t out_out
	s/^.*#10.*$/DLE/; t out_out
	s/^.*#11.*$/DC1/; t out_out
	s/^.*#12.*$/DC2/; t out_out
	s/^.*#13.*$/DC3/; t out_out
	s/^.*#14.*$/DC4/; t out_out
	s/^.*#15.*$/NAK/; t out_out
	s/^.*#16.*$/SYN/; t out_out
	s/^.*#17.*$/ETB/; t out_out
	s/^.*#18.*$/CAN/; t out_out
	s/^.*#19.*$/EM/; t out_out
	s/^.*#1A.*$/SUB/; t out_out
	s/^.*#1B.*$/ESC/; t out_out
	s/^.*#1C.*$/FS/; t out_out
	s/^.*#1D.*$/GS/; t out_out
	s/^.*#1E.*$/RS/; t out_out
	s/^.*#1F.*$/US/; t out_out
	s/^.*#20.*$/ /; t out_out
	s/^.*#21.*$/!/; t out_out
	s/^.*#22.*$/"/; t out_out
	s/^.*#23.*$/#/; t out_out
	s/^.*#24.*$/$/; t out_out
	s/^.*#25.*$/%/; t out_out
	s/^.*#26.*$/\&/; t out_out
	s/^.*#27.*$/´/; t out_out
	s/^.*#28.*$/(/; t out_out
	s/^.*#29.*$/)/; t out_out
	s/^.*#2A.*$/*/; t out_out
	s/^.*#2B.*$/+/; t out_out
	s/^.*#2C.*$/,/; t out_out
	s/^.*#2D.*$/-/; t out_out
	s/^.*#2E.*$/./; t out_out
	s/^.*#2F.*$/\//; t out_out
	s/^.*#30.*$/0/; t out_out
	s/^.*#31.*$/1/; t out_out
	s/^.*#32.*$/2/; t out_out
	s/^.*#33.*$/3/; t out_out
	s/^.*#34.*$/4/; t out_out
	s/^.*#35.*$/5/; t out_out
	s/^.*#36.*$/6/; t out_out
	s/^.*#37.*$/7/; t out_out
	s/^.*#38.*$/8/; t out_out
	s/^.*#39.*$/9/; t out_out
	s/^.*#3A.*$/:/; t out_out
	s/^.*#3B.*$/;/; t out_out
	s/^.*#3C.*$/</; t out_out
	s/^.*#3D.*$/=/; t out_out
	s/^.*#3E.*$/>/; t out_out
	s/^.*#3F.*$/?/; t out_out
	s/^.*#40.*$/@/; t out_out
	s/^.*#41.*$/A/; t out_out
	s/^.*#42.*$/B/; t out_out
	s/^.*#43.*$/C/; t out_out
	s/^.*#44.*$/D/; t out_out
	s/^.*#45.*$/E/; t out_out
	s/^.*#46.*$/F/; t out_out
	s/^.*#47.*$/G/; t out_out
	s/^.*#48.*$/H/; t out_out
	s/^.*#49.*$/I/; t out_out
	s/^.*#4A.*$/J/; t out_out
	s/^.*#4B.*$/K/; t out_out
	s/^.*#4C.*$/L/; t out_out
	s/^.*#4D.*$/M/; t out_out
	s/^.*#4E.*$/N/; t out_out
	s/^.*#4F.*$/O/; t out_out
	s/^.*#50.*$/P/; t out_out
	s/^.*#51.*$/Q/; t out_out
	s/^.*#52.*$/R/; t out_out
	s/^.*#53.*$/S/; t out_out
	s/^.*#54.*$/T/; t out_out
	s/^.*#55.*$/U/; t out_out
	s/^.*#56.*$/V/; t out_out
	s/^.*#57.*$/W/; t out_out
	s/^.*#58.*$/X/; t out_out
	s/^.*#59.*$/Y/; t out_out
	s/^.*#5A.*$/Z/; t out_out
	s/^.*#5B.*$/[/; t out_out
	s/^.*#5C.*$/\\/; t out_out
	s/^.*#5D.*$/]/; t out_out
	s/^.*#5E.*$/^/; t out_out
	s/^.*#5F.*$/_/; t out_out
	s/^.*#60.*$/`/; t out_out
	s/^.*#61.*$/a/; t out_out
	s/^.*#62.*$/b/; t out_out
	s/^.*#63.*$/c/; t out_out
	s/^.*#64.*$/d/; t out_out
	s/^.*#65.*$/e/; t out_out
	s/^.*#66.*$/f/; t out_out
	s/^.*#67.*$/g/; t out_out
	s/^.*#68.*$/h/; t out_out
	s/^.*#69.*$/i/; t out_out
	s/^.*#6A.*$/j/; t out_out
	s/^.*#6B.*$/k/; t out_out
	s/^.*#6C.*$/l/; t out_out
	s/^.*#6D.*$/m/; t out_out
	s/^.*#6E.*$/n/; t out_out
	s/^.*#6F.*$/o/; t out_out
	s/^.*#70.*$/p/; t out_out
	s/^.*#71.*$/q/; t out_out
	s/^.*#72.*$/r/; t out_out
	s/^.*#73.*$/s/; t out_out
	s/^.*#74.*$/t/; t out_out
	s/^.*#75.*$/u/; t out_out
	s/^.*#76.*$/v/; t out_out
	s/^.*#77.*$/w/; t out_out
	s/^.*#78.*$/x/; t out_out
	s/^.*#79.*$/y/; t out_out
	s/^.*#7A.*$/z/; t out_out
	s/^.*#7B.*$/{/; t out_out
	s/^.*#7C.*$/|/; t out_out
	s/^.*#7D.*$/}/; t out_out
	s/^.*#7E.*$/~/; t out_out
	s/^.*#7F.*$/DEL/; t out_out
# For unprintable characters just print a dot.
	s/^.*#.*$/./
:out_out
	p
# Restore the pattern space.
	g
	b bottom

# Input is not supported. The BF code is stdin.
:call_inp
	i \error: the input command is not supported
	q

:bottom
# End of execution, prepare for next command.

# Advance the instruction pointer.
	s/@\(.\)/\1@/	

# If we have no label to branch back to
# just discard the command (its behind the
# second ';').
	s/;[^[&]/;/2

# If the ip has reached the end save the pattern space, clear it
# and start from the beginning.
/@$/ 	{ x; d; }
	b next

# The end.
