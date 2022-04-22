.eqv OK 1
.eqv UNINITIALIZED_LIST -1
.eqv OUT_OF_MEMORY -2
.eqv INDEX_OUT_OF_BOUNDS -3
.eqv UNINITIALIZED_RETVAL -4

.macro check_register(%register, %offset)
la t0, calleesaveframe
lw t0, %offset(t0)
beq %register, t0, _cont
la a0, str_callee_save_error
li a7, 4
ecall
csrrwi zero, ustatus, 0
fail
_cont:
.end_macro

.macro jal_and_check (%label)
csrrw zero, uscratch, t0
la t0, calleesaveframe
sw sp, (t0)
sw s0, 4(t0)
sw s1, 8(t0)
sw s2, 12(t0)
sw s3, 16(t0)
sw s4, 20(t0)
sw s5, 24(t0)
sw s6, 28(t0)
sw s7, 32(t0)
sw s8, 36(t0)
sw s9, 40(t0)
sw s10, 44(t0)
sw s11, 48(t0)
jal %label
check_register(sp, 0)
check_register(s0, 4)
check_register(s1, 8)
check_register(s2, 12)
check_register(s3, 16)
check_register(s4, 20)
check_register(s5, 24)
check_register(s6, 28)
check_register(s7, 32)
check_register(s8, 36)
check_register(s9, 40)
check_register(s10, 44)
check_register(s11, 48)
csrrw t0, uscratch, zero
.end_macro

.macro fail
lw t1, 0xdeadbeef
.end_macro

.macro assert_not_null (%register)
bne %register, zero, _skip
fail
_skip:
.end_macro

.macro assert_null (%register)
beqz %register, _skip
fail
_skip:
.end_macro

.macro assert_ok
assert_eqi (a0, OK)
.end_macro

.macro assert_eq(%reg_a, %reg_b)
beq %reg_a, %reg_b, _skip
fail
_skip:
.end_macro

#using gp here because the used register cannot be the same as %register
.macro assert_eqi(%register, %imm)
csrrw zero, uscratch, gp
li gp, %imm
beq gp, %register, _skip
fail
_skip:
csrrw gp, uscratch, zero

.end_macro

.data
unit_tests: .word list_create_test, list_append_test, list_length_test, list_get_test, list_remove_item_test, list_delete_test, list_insert_test
unit_test_names: .word list_create_test_name, list_append_test_name, list_length_test_name, list_get_test_name, list_remove_item_test_name, list_delete_test_name, list_insert_test_name
unit_tests_size: .word 28 #(4 * 7)
trapframe: .space 12
calleesaveframe: .space 52 #13 registers

#--Strings--
# list tests
list_create_test_name: .string "list_create_test"
list_append_test_name: .string "list_append_test"
list_length_test_name: .string "list_length_test"
list_get_test_name: .string "list_get_test"
list_remove_item_test_name: .string "list_remove_item_test"
list_delete_test_name: .string "list_delete_test"
list_insert_test_name: .string "list_insert_test"
# test strings
str_starting_unit_tests: .string "Starting unit tests...\n\n"
str_starting: .string "Starting "
str_ok: .string "[OK] "
str_error: .string "[ERROR] "
str_complete: .string "Unit tests complete (7/7 succesful).\n"

# debug strings
str_list_address: .string "List at address "
str_list_empty: .string "Empty list\n"
str_value: .string "Value: "
str_node: .string "Node: "
str_next: .string "Next: "

# exception hint strings
str_null_pointer: .string "Uh oh - looks like you're about to dereference the null pointer in 3, 2, 1, ...\n(Hint: the list argument in a0 might be pointing to address 0, in which case you need to return UNINITIALIZED_LIST)\n"
str_assert_fail: .string "An assertion in the test suite has failed.\nWe are going to let the program crash by loading address 0xdeadbeef.\nCheck the line number in the RARS error message to find the faulting assertion.\n(ignore the actual error message, this is simply the consequence of our assertion code throwing a random exception so that RARS tells you the line number)\n(hint: double click the error message to highlight the faulting assertion)\n"
str_callee_save_error: .string "A function in your interface failed to restore all callee save registers to their original values.\nThis breaks calling convention.\nWe are going to let the program crash by loading address 0xdeadbeef.\nCheck the line number in the RARS error message to find the faulting function call.\n(ignore the actual error message, this is simply the consequence of our assertion code throwing a random exception so that RARS tells you the line number)\n(hint: double click the error message to highlight the faulting function)\n"
.text

list_create_test:
	addi sp, sp, -4
	sw ra, (sp)
	
	li a0, 0
	jal_and_check list_create
	assert_not_null (a0)
	
	#EXTRA TEST - WHAT IF MALLOC RUNS OUT OF MEMORY (AND RETURNS 0)? HOW DOES YOUR FUNCTION BEHAVE?
	li t0, 1
	sw t0, out_of_memory, t1
	jal_and_check list_create
	assert_null(a0)
	sw zero, out_of_memory, t0
	
	lw ra, (sp)
	addi sp, sp, 4
	ret

list_append_test:
	#Register allocation:
	# s0: list
	# s1: node
	addi sp, sp, -12
	sw ra, (sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	
	jal_and_check list_create
	assert_not_null (a0)
	mv s0, a0
	
	#Testing empty list
	#assert(list_append(list, 1) == OK)
	li a1, 1
	jal_and_check list_append
	assert_ok
	
	# (s1) node = list->first
	lw s1, (s0)
	# (t1) node->value
	lw t1, (s1)
	# (t2) node->next
	lw t2, 4(s1)
	
	assert_not_null(t0)
	#assert(node->value == 1)
	assert_eqi(t1, 1)
	#assert(node->next == NULL)
	assert_null(t2)
	
	
	#assert(list_append(list, 2) == OK)
	mv a0, s0
	li a1, 2
	jal_and_check list_append
	assert_ok
	
	#node = node->next
	lw s1, 4(s1)
	# (t0) list->first
	lw t0, (s0)
	# (t0) list->first->next
	lw t0, 4(t0)
	# assert(list->first->next == node)
	assert_eq(t0, s1)

	# (t1) node->value
	lw t1, (s1)
	# (t2) node->next
	lw t2, 4(s1)
	# assert(node->value == 2)
	assert_eqi(t1, 2)
	#assert(node->next == NULL)
	assert_null(t2)
	
	
	#assert(list_append(list, 3) == OK)
	mv a0, s0
	li a1, 3
	jal_and_check list_append
	assert_ok
	
	#node = node->next
	lw s1, 4(s1)
	# (t0) list->first
	lw t0, (s0)
	# (t0) list->first->next
	lw t0, 4(t0)
	# (t0) list->first->next->next
	lw t0, 4(t0)
	# assert(list->first->next->next == node)
	assert_eq(t0, s1)
	
	# (t1) node->value
	lw t1, (s1)
	# (t2) node->next
	lw t2, 4(s1)
	# assert(node->value == 3)
	assert_eqi(t1, 3)
	# assert(node->next == NULL)
	assert_null(t2)
	
	# assert(list_append(NULL, 0) == UNINITIALIZED_LIST)
	li a0, 0
	li a1, 0
	jal_and_check list_append
	assert_eqi(a0, UNINITIALIZED_LIST)
	
	
	#EXTRA TEST - WHAT IF MALLOC RUNS OUT OF MEMORY? HOW DOES YOUR FUNCTION BEHAVE?
	li t0, 1
	sw t0, out_of_memory, t1
	mv a0, s0
	li a1, 5
	jal_and_check list_append
	assert_eqi(a0, OUT_OF_MEMORY)
	sw zero, out_of_memory, t0
	
	lw ra, (sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	addi sp, sp, 12
	ret
	
	
list_length_test:
	# Register allocation
	# s0: list
	# s1: i
	 
	addi sp, sp, -12
	sw ra, (sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	
	jal_and_check list_create
	# assert(list != NULL)
	assert_not_null(a0)
	mv s0, a0
	
	li s1, 0
.L_ll_for_begin:
	#assert(list_length(list) == i)
	mv a0, s0
	jal_and_check list_length
	assert_eq(a0, s1)
	
	#list_append(list, i)
	mv a0, s0
	mv a1, s1
	jal_and_check list_append
	
	li t0, 5
	addi s1, s1, 1
	blt s1, t0, .L_ll_for_begin
	
	#assert(list_length(NULL) == UNINITIALIZED_LIST)
	li a0, 0
	jal_and_check list_length
	assert_eqi(a0, UNINITIALIZED_LIST)
	
	lw ra, (sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	addi sp, sp, 12
	ret
	
list_get_test:
	#Register* allocation
	# s0: list
	# s1: i
	# 12(sp): retval (*we allocate retval on the stack, registers don't have an address!)
	addi sp, sp, -16
	sw ra, (sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	
	jal_and_check list_create
	# assert(list != NULL)
	assert_not_null(a0)
	mv s0, a0
	
	#for loop
	li s1, 0
.L_lg_for_begin:
	#assert(list_length(list) == i)
	mv a0, s0

	#list_append(list, i)
	mv a0, s0
	mv a1, s1
	jal_and_check list_append
	
	#assert(list_get(list, i, &retval) == OK)
	mv a0, s0
	mv a1, s1
	mv a2, sp
	addi a2, a2, 12 #a2 = addr of retval
	jal_and_check list_get
	assert_ok
	#assert(retval == i)
	lw t0, 12(sp)
	assert_eq(t0, s1)
	
	li t0, 5
	addi s1, s1, 1
	blt s1, t0, .L_lg_for_begin
	#end for loop
	
	#assert(list_get(NULL, 0, &retval) == UNINITIALIZED_LIST)
	li a0, 0
	li a1, 0
	mv a2, sp
	addi a2, a2, 12 #a2 = addr of retval
	jal_and_check list_get
	assert_eqi(a0, UNINITIALIZED_LIST)
	
	#assert(list_get(list, 0, NULL) = UNINITIALIZED_RETVAL)
	mv a0, s0
	li a1, 0
	li a2, 0
	jal_and_check list_get
	assert_eqi(a0, UNINITIALIZED_RETVAL)
	
	#assert(list_get(list, -1, &retval) == INDEX_OUT_OF_BOUNDS)
	mv a0, s0
	li a1, -1
	mv a2, sp
	addi a2, a2, 12
	jal_and_check list_get
	assert_eqi(a0, INDEX_OUT_OF_BOUNDS)
	
	#assert(list_get(list, 5, &retval) == INDEX_OUT_OF_BOUNDS)
	mv a0, s0
	li a1, 5
	mv a2, sp
	addi a2, a2, 12
	jal_and_check list_get
	assert_eqi(a0, INDEX_OUT_OF_BOUNDS)
	
	
	lw ra, (sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	addi sp, sp, 16
	ret
	
list_remove_item_test:
	# Register allocation
	# s0: list
	# s1: i 
	addi sp, sp, -12
	sw ra, (sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	
	jal_and_check list_create
	mv s0, a0
	
	#assert(list_remove_item(list, 0) == INDEX_OUT_OF_BOUNDS)
	li a1, 0
	jal_and_check list_remove_item
	assert_eqi(a0, INDEX_OUT_OF_BOUNDS)
	
	#for loop
	li s1, 0
.L_lr_for_begin:	
	#list_append(list, i)
	mv a0, s0
	mv a1, s1
	jal_and_check list_append
	li t0, 5
	addi s1, s1, 1
	blt s1, t0, .L_lr_for_begin
	
	#Removal of first element
	#assert(list_remove_item(list, 0) == OK)
	mv a0, s0
	li a1, 0
	jal_and_check list_remove_item
	assert_ok
	
	#assert(list_length(list) == 4);
	mv a0, s0
	jal_and_check list_length
	assert_eqi(a0, 4)
	
     #assert(list->first->value == 1);
	lw t0, (s0)
	lw t0, (t0)
	assert_eqi(t0, 1)
	
	
	#Removal of middle element
	#assert(list_remove_item(list, 0) == OK)
	mv a0, s0
	li a1, 1
	jal_and_check list_remove_item
	assert_ok
	
	#assert(list_length(list) == 3);
	mv a0, s0
	jal_and_check list_length
	assert_eqi(a0, 3)
	
     #assert(list->first->value == 1);
	lw t0, (s0)
	lw t0, (t0)
	assert_eqi(t0, 1)
	
	#assert(list->first->next->value == 3);
	lw t0, (s0)
	lw t0, 4(t0)
	lw t0, (t0)
	assert_eqi(t0, 3)
	
	#Removal of last element
	#assert(list_remove_item(list, 0) == OK)
	mv a0, s0
	li a1, 2
	jal_and_check list_remove_item
	assert_ok
	
	#assert(list_length(list) == 2);
	mv a0, s0
	jal_and_check list_length
	assert_eqi(a0, 2)
	
     #assert(list->first->value == 1);
	lw t0, (s0)
	lw t0, (t0)
	assert_eqi(t0, 1)
	
	#assert(list->first->next->value == 3);
	lw t0, (s0)
	lw t0, 4(t0)
	lw t0, (t0)
	assert_eqi(t0, 3)
	
	# Index out of bounds
	# assert(list_remove_item(list, 2) == INDEX_OUT_OF_BOUNDS);
	mv a0, s0
	li a1, 2
	jal_and_check list_remove_item
	assert_eqi(a0, INDEX_OUT_OF_BOUNDS)
	
    	#assert(list_remove_item(list, -1) == INDEX_OUT_OF_BOUNDS);
    	mv a0, s0
	li a1, -1
	jal_and_check list_remove_item
	assert_eqi(a0, INDEX_OUT_OF_BOUNDS)
	
	#assert(list_remove_item(NULL, 0) == UNINITIALIZED_LIST);
	li a0, 0
	li a1, 0
	jal_and_check list_remove_item
	assert_eqi(a0, UNINITIALIZED_LIST)
	
    	#assert(list_length(list) == 2);
    	mv a0, s0
	jal_and_check list_length
	assert_eqi(a0, 2)
	
	lw ra, (sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	addi sp, sp, 12
	ret

list_delete_test:
	# Register allocation
	# s0: list
	# s1: i 
	addi sp, sp, -12
	sw ra, (sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	
	jal_and_check list_create
	
	#assert(list_delete(list) == OK)
	jal_and_check list_delete
	assert_ok
	
	jal_and_check list_create
	mv s0, a0
	assert_not_null(s0)
	
	#for loop
	li s1, 0
.L_ld_for_begin:	
	#list_append(list, i)
	mv a0, s0
	mv a1, s1
	jal_and_check list_append
	li t0, 5
	addi s1, s1, 1
	blt s1, t0, .L_ld_for_begin
	
	#assert(list_delete(list) == OK
	mv a0, s0
	jal_and_check list_delete
	assert_ok
	
	li a0, 0
	jal_and_check list_delete
	assert_eqi(a0, UNINITIALIZED_LIST)
	
	lw ra, (sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	addi sp, sp, 12

list_insert_test:
	#Register allocation
	# s0: list
	addi sp, sp, -8
	sw ra, (sp)
	sw s0, 4(sp)
	
	jal_and_check list_create
	assert_not_null(a0)
	mv s0, a0
	
	#OUT OF BOUNDS ACCESSES
	#assert(list_insert(list, 1, 0) == INDEX_OUT_OF_BOUNDS)
	mv a0, s0
	li a1, 1
	li a2, 0
	jal_and_check list_insert
	assert_eqi(a0, INDEX_OUT_OF_BOUNDS)
	
	#assert(list_length(list) == 0);
    	mv a0, s0
	jal_and_check list_length
	assert_eqi(a0, 0)
	
	#assert(list_insert(list, -1, 0) == INDEX_OUT_OF_BOUNDS)
	mv a0, s0
	li a1, -1
	li a2, 0
	jal_and_check list_insert
	assert_eqi(a0, INDEX_OUT_OF_BOUNDS)
	
	#assert(list_length(list) == 0);
    	mv a0, s0
	jal_and_check list_length
	assert_eqi(a0, 0)
	#--------
	
	
	#EMPTY LIST INSERT
	#assert(list_insert(list, 0, 0) == OK)
	mv a0, s0
	li a1, 0
	li a2, 0
	jal_and_check list_insert
	assert_eqi(a0, OK)
	
	#assert(list_length(list) == 1);
    	mv a0, s0
	jal_and_check list_length
	assert_eqi(a0, 1)
	
	#assert(list->first->value == 0)
	lw t0, (s0)
	lw t0, (t0)
	assert_eqi(t0, 0)
	#-------
	
	#LIST FRONT INSERT
	#assert(list_insert(list, 0, 1) == OK)
	mv a0, s0
	li a1, 0
	li a2, 1
	jal_and_check list_insert
	assert_eqi(a0, OK)
	
	#assert(list_length(list) == 2);
    	mv a0, s0
	jal_and_check list_length
	assert_eqi(a0, 2)
	
	#assert(list->first->value == 1)
	lw t0, (s0)
	lw t0, (t0)
	assert_eqi(t0, 1)
	#-------
	
	#LIST BACK INSERT
	#assert(list_insert(list, 2, 2) == OK)
	mv a0, s0
	li a1, 2
	li a2, 2
	jal_and_check list_insert
	assert_eqi(a0, OK)
	
	#assert(list_length(list) == 3);
    	mv a0, s0
	jal_and_check list_length
	assert_eqi(a0, 3)
	
	#assert(list->first->value == 1)
	lw t0, (s0)
	lw t0, (t0)
	assert_eqi(t0, 1)
	
	#assert(list->first->next->value == 0)
	lw t0, (s0)
	lw t0, 4(t0)
	lw t0, (t0)
	assert_eqi(t0, 0)
	
	#assert(list->first->next->next->value == 0)
	lw t0, (s0)
	lw t0, 4(t0)
	lw t0, 4(t0)
	lw t0, (t0)
	assert_eqi(t0, 2)
	#-------
	
	#LIST MIDDLE INSERT
	#assert(list_insert(list, 2, 2) == OK)
	mv a0, s0
	li a1, 2
	li a2, 3
	jal_and_check list_insert
	assert_eqi(a0, OK)
	
	#assert(list_length(list) == 3);
    	mv a0, s0
	jal_and_check list_length
	assert_eqi(a0, 4)
	
	#assert(list->first->value == 1)
	lw t0, (s0)
	lw t0, (t0)
	assert_eqi(t0, 1)
	
	#assert(list->first->next->value == 0)
	lw t0, (s0)
	lw t0, 4(t0)
	lw t0, (t0)
	assert_eqi(t0, 0)
	
	#assert(list->first->next->next->value == 3)
	lw t0, (s0)
	lw t0, 4(t0)
	lw t0, 4(t0)
	lw t0, (t0)
	assert_eqi(t0, 3)
	
	#assert(list->first->next->next->next->value == 2)
	lw t0, (s0)
	lw t0, 4(t0)
	lw t0, 4(t0)
	lw t0, 4(t0)
	lw t0, (t0)
	assert_eqi(t0, 2)
	#-------
	
	
	#EXTRA TEST - WHAT IF MALLOC RUNS OUT OF MEMORY (AND RETURNS 0)? HOW DOES YOUR FUNCTION BEHAVE?
	li t0, 1
	sw t0, out_of_memory, t1
	mv a0, s0
	li a1, 0
	li a2, 0
	jal_and_check list_insert
	assert_eqi(a0, OUT_OF_MEMORY)
	sw zero, out_of_memory, t0
	
	lw s0, 4(sp)
	lw ra, (sp)
	addi sp, sp, 8
	ret


.globl run_test_suite
run_test_suite:
	addi sp, sp, -4
	sw ra, (sp)

	la a0, exception_handler
	csrrw zero, utvec, a0
	csrwi ustatus, 1

	la a0, str_starting_unit_tests
	li a7, 4
	ecall
	
	li s0, 0 #test counter
	
_execute_unit_test:
	#Print starting
	la a0, str_starting
	li a7, 4
	ecall
	
	#Print test name
	la a0, unit_test_names
	add a0, a0, s0
	lw a0, (a0)
	ecall
	
	li a7, 11
	li a0, '\n'
	ecall

	#Execute test
	la t0, unit_tests
	add t0, t0, s0
	lw t1, 0(t0)
	jalr t1
	
	#Print OK
	la a0, str_ok
	li a7, 4
	ecall
	
	#Print test name
	la a0, unit_test_names
	add a0, a0, s0
	lw a0, (a0)
	ecall
	
	li a7, 11
	li a0, '\n'
	ecall
	
	li a7, 11
	li a0, '\n'
	ecall
	
	addi s0, s0, 4
	lw a0, unit_tests_size
	bge s0, a0, ret_to_main
	j _execute_unit_test
	
ret_to_main:
	lw ra, (sp)
	addi sp, sp, 4
	ret


# This exception handler is used to provide debug tips
# It simply prints a hint and then crashes the same way as the simulator would normally
# by disabling custom exception handlers and jumping back to the faulting instruction
exception_handler:
	csrwi ustatus, 0
	csrrw zero, uscratch, t0
	la t0, trapframe
	sw a0, (t0)
	sw t1, 4(t0)
	sw a7, 8(t0)
	
	li a0, 5
	csrrw t1, ucause, zero
	beq a0, t1, _load_access_fault
	li a0, 7
	beq a0, t1, _store_access_fault
	
	li a0, 4
	beq a0, t1, _load_address_misaligned
	j _ex_ret

_store_access_fault:
_load_access_fault:	
	csrrw a0, utval, zero
	beqz a0, _null_pointer
	j _ex_ret
	#null pointer exception!
_load_address_misaligned:
	csrrw a0, utval, zero
	li t1, 0xdeadbeef
	beq a0, t1, _assert_fail
	csrrw zero, utval, a0
	j _ex_ret

_null_pointer:
	la a0, str_null_pointer
	li a7, 4
	ecall
	j _ex_ret

_assert_fail:
	la a0, str_assert_fail
	li a7, 4
	ecall
	j _ex_ret
	
_ex_ret:
	lw a0, (t0)
	lw t1, 4(t0)
	lw a7, 8(t0)
	csrrw t0, uscratch, zero
	uret
