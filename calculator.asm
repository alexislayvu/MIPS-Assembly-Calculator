.data
    prompt:             .asciiz         "Enter an equation: "
    input_buffer:       .space          100

    numbers:            .byte           '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
    operations:         .byte           '+', '-', '*', '/'

    add_sym:            .asciiz         " + "
    sub_sym:            .asciiz         " - "
    mul_sym:            .asciiz         " * "
    div_sym:            .asciiz         " / "
    equals_sign:        .asciiz         " = "
    display_total:      .asciiz         "Total = "

    newline:            .asciiz         "\n"

.text
.globl main

main:
    # load arrays
    # $s0 = user input
    la      $s1, numbers        # load numbers array
    la      $s2, operations     # load operations array

    # trackers
    li      $t1, 0               # num_index = 0
    li      $t2, 1               # op_index = 1

    # num1, num2, total, which operation, and operation flag
    li      $t3, 0               # num1                   
    li      $t4, 0               # num2   
    li      $t5, 0               # total   
    li      $t6, 0               # which operation 
    li      $t7, 0               # operation flag

    # to check if the operation flag is on
    li      $t8, 1               # 1 = on

    # PRINT PROMPT
    li      $v0, 4               # print_str
    la      $a0, prompt          # load address of prompt
    syscall

    # GET USER INPUT
    li      $v0, 8               # read_str
    la      $a0, input_buffer    # load byte space into address
    li      $a1, 100             # allocate byte space
    syscall

    la      $s0, input_buffer    # $s0 = user input

# -- FIND STRING LENGTH -- #
compute_string_length:
    lb      $s3, 0($s0)                         # current char
    beq     $s3, $zero, found_string_length     # end of the input? jump found_string_length

    addi    $s0, $s0, 1                         # increment to next char in input
    j       compute_string_length               # jump compute_string_length

found_string_length:
    la      $t0, input_buffer                   # load user input into $t0
    sub     $t9, $s0, $t0                       # $t9 = string length 
    addi    $t9, $t9, -1                        # decrement by 1 because it's off by 1

    la      $s0, input_buffer                   # load user input again

# -- PARSE INPUT AND FIND NUM1, OPERATION SYMBOL, AND NUM2 -- #
parse_input:
    lb      $s3, 0($s0)                         # current char
    
    beq     $t7, $t8, reset_num_index           # if operation flag on, jump reset_num_index
    beq     $t3, $zero, find_num1               # if num1 == 0, jump find_num1
    bne     $t3, $zero, reset_operation_index   # if num1 != 0, jump reset_operation_index

    find_num1:
        lb      $s4, 0($s1)             # current num
        beq     $s3, $s4, set_num1      # if current char == current num, jump set_num1

        addi    $s1, $s1, 1             # increment to next num in numbers
        addi    $t1, $t1, 1             # num_index++
        j       find_num1               # jump find_num1
    
        set_num1:
            move    $t3, $t1            # set num1 = num_index
            li      $t1, 0              # set num_index = 0
            j       get_next_char       # jump parse_next_index
    
    reset_operation_index:
        la      $s2, operations         # load operations array
        j       find_operation          # jump find_operation

    find_operation:
        lb      $s5, 0($s2)             # current operation
        beq     $s3, $s5, set_operation # if current char = current operation, jump set_operation

        addi    $s2, $s2, 1             # increment to next operattion in operations
        addi    $t2, $t2, 1             # op_index++
        j       find_operation          # jump find_operation

        set_operation:
            move    $t6, $t2            # set operation num = op_index
            li      $t2, 1              # set op_index = 1
            li      $t7, 1              # set operation flag on
            j       get_next_char       # jump get_char_char

    reset_num_index:
        la      $s1, numbers            # load numbers array
        j       find_num2               # jump find_num2

        find_num2:
            lb      $s6, 0($s1)             # current num
            beq     $s3, $s6, set_num2      # if current char = current num, jump set_num2

            addi    $s1, $s1, 1             # increment to the next num in numbers
            addi    $t1, $t1, 1             # num_index++
            j       find_num2               # jump find_num2

            set_num2:
                move    $t4, $t1            # set num2 = num_index
                li      $t1, 0              # set num_index = 0
                j       which_operation     # jump which_operation

        which_operation:
            li      $t0, 1                      # set $t0 = 1
            beq     $t6, $t0, addition          # if $t6 == 1, jump addition

            li      $t0, 2                      # set $t0 = 2
            beq     $t6, $t0, subtraction       # if $t6 == 2, jump subtraction

            li      $t0, 3                      # set $t0 = 3
            beq     $t6, $t0, multiplication    # if $t6 == 3, jump multiplication

            li      $t0, 4                      # set $t0 = 4
            beq     $t6, $t0, division          # if $t6 == 4, jump division

            addition:
                add     $t5, $t3, $t4               # total = num1 + num2
                j       print_first_half_subtotal   # jump print_first_half_subtotal

            subtraction:
                sub     $t5, $t3, $t4               # total = num1 - num2                
                j       print_first_half_subtotal   # jump print_first_half_subtotal

            multiplication:
                mul     $t5, $t3, $t4               # total = num1 * num2
                j       print_first_half_subtotal   # jump print_first_half_subtotal
            
            division:
                div     $t5, $t3, $t4               # total = num1 / num2
                j       print_first_half_subtotal   # jump print_first_half_subtotal
        
        print_first_half_subtotal:
                li      $v0, 1                  # print_int
                move    $a0, $t3                # print num1
                syscall

                # FIND WHICH OPERATION SYMBOL TO PRINT AND JUMP ACCORDINGLY
                li      $t0, 1
                beq     $t6, $t0, print_addition_subtotal       # jump print_addition_subtotal

                li      $t0, 2
                beq     $t6, $t0, print_subtraction_subtotal    # jump print_subtraction_subtotal

                li      $t0, 3
                beq     $t6, $t0, print_multiplication_subtotal # jump print_multiplication_subtotal

                li      $t0, 4
                beq     $t6, $t0, print_division_subtotal       # jump print_division_subtotal

            print_addition_subtotal:
                li      $v0, 4                  # print_str
                la      $a0, add_sym            # print add_sym
                syscall

                j       print_second_half_subtotal  # jump print_second_half_subtotal

            print_subtraction_subtotal:
                li      $v0, 4                  # print_str
                la      $a0, sub_sym            # print sub_sym
                syscall
            
                j       print_second_half_subtotal  # jump print_second_half_subtotal

            print_multiplication_subtotal:
                li      $v0, 4                  # print_str
                la      $a0, mul_sym            # print mul_sym
                syscall

                j       print_second_half_subtotal  # jump print_second_half_subtotal
            
            print_division_subtotal:
                li      $v0, 4                  # print_str
                la      $a0, div_sym            # print div_sym
                syscall

                j       print_second_half_subtotal  # jump print_second_half_subtotal

        print_second_half_subtotal:
            li      $v0, 1                      # print_int
            move    $a0, $t4                    # print num2
            syscall
            li      $v0, 4                      # print_str
            la      $a0, equals_sign            # print equals_sign
            syscall
            li      $v0, 1                      # print_int
            move    $a0, $t5                    # print total
            syscall
            li      $v0, 4                      # print_str
            la      $a0, newline                # print newline
            syscall

            j       reset_variables             # jump reset_variables
        
        reset_variables:
            move    $t3, $t5                    # set num1 = total
            li      $t4, 0                      # set num2 = 0
            li      $t5, 0                      # set total = 0
            li      $t6, 0                      # set operation num = 0
            li      $t7, 0                      # set operation flag off (0)

            j       get_next_char               # jump get_next_char

    get_next_char:
        addi    $s0, $s0, 1                 # increment to next char in input
        addi    $t9, $t9, -1                # decrement loop count
        bne     $t9, $zero, parse_input     # if loop count != 0, jump parse_input

# -- EXIT AND PRINT TOTAL -- #
exit:
    li      $v0, 4              # print_str
    la      $a0, display_total  # print display_total
    syscall
    li      $v0, 1              # print_int
    move    $a0, $t3            # print total
    syscall
    li      $v0, 4              # print_str
    la      $a0, newline        # print newline
    syscall 

    li      $v0, 10             # exit cleanly
    syscall