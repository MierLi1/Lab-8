#############################################################################################
#
# Montek Singh
# COMP 541:  Single-Cycle MIPS CPU
# 3/3/2025
#
# This is a MIPS program that tests the MIPS processor.
#
# In MARS, please select:  Settings ==> Memory Configuration ==> Default.
#
# NOTE:  MEMORY SIZES.
#
# Instruction memory:  This program has 64 instructions (after assembly, a couple of
# instructions -- lw "a" and sw "a_sqr" -- expand to three instructions each).  There is
# also the pseudoinstruction la, which expands to 2 instructions.
# While an instruction memory of size 64 will suffice, let us make give it a size of 128 locations,
# to allow for more instructions to be easily added.
#
# Data memory:  Assume data memory has 64 locations.  This program only uses two locations for data,
# and a handful more for the stack.  Top of the stack is set at the word address
# [0x1001_0100], giving a total of 64 locations --- i.e., (0x1001_0100 - 0x1001_0000)/4) locations --- for
# data and stack together.
#
# If you need larger data memory than 64 words, you will have to move the top of the stack
# to a higher address.
#
#############################################################################################

.data 0x10010000 			# Start of data memory
a_sqr:	.space 4
a:	.word 3

.text 0x00400000			# Start of instruction memory
main:
	lui 	$sp, 0x1001		# Initialize stack pointer to the 512th location above start of data
	ori 	$sp, $sp, 0x0100	# $sp will be decremented first before storing the first data item
	
	
	#############################
	# TEST ALL 31 INSTRUCTIONS #
	#############################

	lui 	$t0, 0xffff
	ori 	$t0, $t0, 0xffff 	# $t0 = -1
	addi	$t1, $0, -1		# $t1 = -1
	bne 	$t0, $t1, end
	sll 	$t0, $t0, 24		# $t0 = 0xff00_0000
	ori 	$t0, $t0, 0xf000	# $t0 = 0xff00_f000
	sra 	$t0, $t0, 8		# $t0 = 0xffff_00f0
	srl 	$t0, $t0, 4		# $t0 = 0x0fff_f00f
	ori 	$t2, $0, 3		# $t2 = 3
	sub 	$t2, $t2, $t1 		# $t2 = 3 - (-1) = 4
	sllv	$t0, $t0, $t2 		# $t0 = 0xffff_00f0
	srav	$t0, $t0, $t2 		# $t0 = 0xffff_f00f
	srlv	$t0, $t0, $t2 		# $t0 = 0x0fff_ff00
	sllv	$t0, $t0, $t2 		# $t0 = 0xffff_f000
	
	slt 	$t3, $t0, $t2 		# 0xffff_f000 < 4 ?  (signed)  YES
	sltu 	$t3, $t0, $t2 		# 0xffff_00f0 < 4 ?  (unsigned)  NO
	addi 	$t0, $0, 5		# $t0 = 5
	slti	$t3, $t0, 10		# 5 < 10?  YES
	sltiu	$t3, $t0, 4		# 5 < 4?   NO
	addi 	$t0, $0, -5		# $t0 = -5
	sltiu	$t3, $t0, 5		# -5 < 5?  NO -- because -5 unsigned is a big number
	addi	$t0, $0, 20		# $t0 = 20
	sltiu	$t3, $t0, -1		# 20 < -1?  YES -- because -1 sign-extended and then unsigned is a big number
	
		
			

	
	lui 	$t3, 0x1010
	ori 	$t3, $t3, 0x1010	# $t3 = 0x1010_1010
	lui 	$t4, 0x0101
	addi	$t4, $t4, 0x1010	# $t4 = 0x0101_1010
	andi	$t5, $t4, 0xFFFF	# $t5 = 0x0000_1010
	xori	$t5, $t5, 0xFFFF	# $t5 = 0x0000_EFEF	
	and 	$t5, $t3, $t4		# $t5 = 0x0000_1010 
	or  	$t5, $t3, $t4		# $t5 = 0x1111_1010
	xor 	$t5, $t3, $t4		# $t5 = 0x1111_0000
	nor 	$t5, $t3, $t4		# $t5 = 0xEEEE_EFEF
     	
	##############################################
	# TEST procedure calls, stack and recursion #
	##############################################

	lw  	$a0, a($0) 		# bring a into register $a0
	addi	$a0, $a0, 2
	addiu	$a0, $a0, 0xfffffffe 	# -2
	la  	$s0, sqr		# la = pseudo-instruction
	jalr   	$ra, $s0		# compute sqr(a) by jumping to sqr
	sw  	$v0, a_sqr($0)		# store result into a_sqr     

			
					
	###############################
	# END using infinite loop     #
	###############################
end:
	j   	end          	# infinite loop "trap" because we don't have syscalls to exit


######## END OF MAIN #################################################################################


######## CALLED PROCEDURES BELOW #####################################################################



	###############################
	# sqr() recursive procedure   #
	###############################

sqr:
	addi	$sp, $sp, -8
	sw  	$ra, 4($sp)
	sw  	$a0, 0($sp)
	slti	$t0, $a0, 2
	beq 	$t0, $0, then
	add 	$v0, $0, $a0
	j   	rtn	
then:
	addi	$a0, $a0, -1
	jal 	sqr
	lw  	$a0, 0($sp)
	add 	$v0, $v0, $a0
	addu	$v0, $v0, $a0
	addi	$v0, $v0, -1
	bne 	$0, $0, then 		# branch should not be taken
rtn:
	lw  	$ra, 4($sp)
	addi	$sp, $sp, 8
	jr  	$ra
	

######## END OF CODE #################################################################################
