.data 

orig: .space 100	# In terms of bytes (25 elements * 4 bytes each)
sorted: .space 100

str0: .asciiz "Enter the number of assignments (between 1 and 25): "
str1: .asciiz "Enter score: "
str2: .asciiz "Original scores: "
str3: .asciiz "Sorted scores (in descending order): "
str4: .asciiz "Enter the number of (lowest) scores to drop: "
str5: .asciiz "Average (rounded down) with dropped scores removed: "
str6: .asciiz "All scores dropped!"
space: .asciiz " "
newline: .asciiz "\n"

.text 

# This is the main program.
# It first asks user to enter the number of assignments.
# It then asks user to input the scores, one at a time.
# It then calls selSort to perform selection sort.
# It then calls printArray twice to print out contents of the original and sorted scores.
# It then asks user to enter the number of (lowest) scores to drop.
# It then calls calcSum on the sorted array with the adjusted length (to account for dropped scores).
# It then prints out average score with the specified number of (lowest) scores dropped from the calculation.
main: 
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, str0
	
loopNum:
	li $v0, 4 
	syscall 
	li $v0, 5	# Read the number of scores from user
	syscall
	
	# Your code here to handle invalid number of scores (can't be less than 1 or greater than 25)
	blt $v0, 1, loopNum # if numScores < 1 repeat input
	bgt $v0, 25, loopNum # if numScores > 25 repeat input
	
	move $s0, $v0	# $s0 = numScores
	move $t0, $0
	la $s1, orig	# $s1 = orig
	la $s2, sorted	# $s2 = sorted
	
loopIn:
	li $v0, 4 
	la $a0, str1 
	syscall 
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	li $v0, 5	# Read elements from user
	syscall
	sw $v0, 0($t1)
	addi $t0, $t0, 1
	bne $t0, $s0, loopIn
	
	move $a0, $s0
	jal selSort	# Call selSort to perform selection sort in original array
	
	li $v0, 4 
	la $a0, str2 
	syscall
	move $a0, $s1	# More efficient than la $a0, orig
	move $a1, $s0
	jal printArray	# Print original scores
	li $v0, 4 
	la $a0, str3 
	syscall 
	move $a0, $s2	# More efficient than la $a0, sorted
	jal printArray	# Print sorted scores
	
loopDrop:
	li $v0, 4 
	la $a0, str4 
	syscall 
	li $v0, 5	# Read the number of (lowest) scores to drop
	syscall
	move $s3, $v0 # $s3 = drop
	
	# Your code here to handle invalid number of (lowest) scores to drop (can't be less than 0, or 
	# greater than the number of scores). Also, handle the case when number of (lowest) scores to drop 
	# equals the number of scores.
	blt $s3, 0, loopDrop # if drop < 0 repeat input
	bgt $s3, $s0, loopDrop # if drop > numScores repeat input
	
	bne $s3, $s0, continue # if drop == numScores, skip calcSum call as it is not necessary
	li $v0, 4 
	la $a0, str6 # Output set to "All scores dropped!"
	syscall # Print "All scores dropped!"
	j end
	
continue:
	move $a1, $s3
	sub $a1, $s0, $a1	# numScores - drop
	move $a0, $s2
	jal calcSum	# Call calcSum to RECURSIVELY compute the sum of scores that are not dropped
	
	# Your code here to compute average and print it (you may also end up having some code here to help 
	# handle the case when number of (lowest) scores to drop equals the number of scores

	sub $t0, $s0, $s3 # $t0 = numScores - drop
	div $v0, $t0 # Value returned by calcSum divided by new number of scores (Average score)
	mflo $t0
	
	li $v0, 4
	la $a0, str5
	syscall
	li $v0, 1
	move $a0, $t0
	syscall
	
end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	li $v0, 10 
	syscall
	
	
# printList takes in an array and its size as arguments. 
# It prints all the elements in one line with a newline at the end.
printArray:
	# Your implementation of printList here
	# $a0 = *arr, $a1 = len, $t0 = i, $t1 = address of arr, $t2 used for offset
	move $t0, $zero # i = 0
	move $t1, $a0 # Move address out of argument register, since it is needed for printing
	
printLoop:
	beq $t0, $a1, printDone # for i < len
	sll $t2, $t0, 2 # $t2 = i * 4 for memory offset
	add $t2, $t2, $t1 # t2 = arr + i * 4
	li $v0, 1 # Ready to pring integer
	lw $a0, 0($t2) # $a0 = arr[i]
	syscall # Printing arr[i]
	li $v0, 4 # Ready to print string
	la $a0, space # Output is now " "
	syscall # Printing " "
	addi $t0, $t0, 1 # i + 1
	j printLoop
	
printDone:
	move $a0, $t6 # Restore $a0 as it was changed during the loop for printing
	li $v0, 4 # Ready to print string
	la $a0, newline # Output is now "\n"
	syscall # Printing "\n"
	jr $ra
		
# selSort takes in the number of scores as argument. 
# It performs SELECTION sort in descending order and populates the sorted array
selSort:
	# Your implementation of selSort
	# $a0 = len, $t0 = 1, $t1 = j, $t2/$t3 = offset, $t4 = len - 1, $t5 = maxIndex, $t6 and $t7 used for addresses of orig and sorted
	# Deep copy of orig to sorted
	move $t0, $zero # i = 0
	
copyLoop:
	bge $t0, $a0, copyDone # i < len
	sll $t4, $t0, 2 # $t4 = i * 4 for memory offset
	add $t5, $s1, $t4 # $t5 = orig + i * 4
	add $t6, $s2, $t4 # $t6 = sorted + i * 4
	lw $t1, 0($t5) # $t1 = orig[i]
	sw $t1, 0($t6) # sorted[i] = orig[i]
	addi $t0, $t0, 1 # i++
	j copyLoop

copyDone:
	move $t0, $zero # i = 0
	addi $t4, $a0, -1 # $t4 = len - 1

sortLoopOuter:
	bge $t0, $t4, sortDone # i < len - 1
	move $t5, $t0 # maxIndex = i
	addi $t1, $t0, 1 # j = i + 1
	
sortLoopInner:
	bge $t1, $a0, innerDone # j < len
	sll $t2, $t1, 2 # $t2 = j * 4
	add $t2, $s2, $t2 # $t2 = sorted + j * 4
	lw $t6, 0($t2) # $t6 = sorted[j]
	
	sll $t3, $t5, 2 # $t3 = maxIndex * 4
	add $t3, $s2, $t3 # $t3 = sorted + maxIndex * 4
	lw $t7, 0($t3) # $t7 = sorted[maxIndex]
	
	ble $t6, $t7, noUpdate # if sorted[j] > sorted[maxIndex], update maxIndex
	move $t5, $t1 # maxIndex = j
	
noUpdate:
	addi $t1, $t1, 1 # j++
	j sortLoopInner
	
innerDone:
	sll $t2, $t5, 2 # $t2 = maxIndex * 4
	add $t2, $s2, $t2 # $t2 = sorted + maxIndex * 4
	
	sll  $t3, $t0, 2 # $t3 = i * 4
	add  $t3, $s2, $t3 # $t3 = sorted + i * 4
	
	lw $t8, 0($t2) # temp = sorted[maxIndex]
	lw $t9, 0($t3) # $t9 = sorted[i]
	
	sw $t9, 0($t2) # sorted[maxIndex] = sorted[i]
	sw $t8, 0($t3) # sorted[i] = temp
	
	addi $t0, $t0, 1 # i++
	j sortLoopOuter

sortDone:
	jr $ra
	
# calcSum takes in an array and its size as arguments.
# It RECURSIVELY computes and returns the sum of elements in the array.
# Note: you MUST NOT use iterative approach in this function.
calcSum:
	# Your implementation of calcSum here
	blez $a1, calcBaseCase # if len <= 0, base case reached.
	
	addi $sp, $sp, -8 # Make room on the stack
	sw $ra, 0($sp) # Save return address
	sw $a1, 4($sp) # Save current value of len
	
	addi $a1, $a1, -1 # len = len - 1
	jal calcSum # Recursive call
	
	lw $ra, 0($sp) # Restore return address
	lw $a1, 4($sp) # Restore value of len
	addi $sp, $sp, 8 # Pop from the stack
	
	addi $t0, $a1, -1 # $t0 = len - 1
	sll $t0, $t0, 2 # $t0 = (len - 1) * 4
	add $t0, $a0, $t0 # $t0 = arr + (len - 1) * 4
	lw $t0, 0($t0) #t0 = arr[len - 1]
	add $v0, $v0, $t0 # return value += arr[len - 1]
	
	jr $ra

calcBaseCase:
	li $v0, 0
	jr $ra
