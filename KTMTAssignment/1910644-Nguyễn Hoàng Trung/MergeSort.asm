.data
	# Declare two 20-integer arrays: arr and tempArr
	arr: 		.word 	0:20						# int arr[20];
	tempArr: 	.word 	0:20						# int tempArr[20];
.text
.globl main
	##################################################################################################
	## MAIN FUNCTION
	##################################################################################################
	main:									# int main(){
		#=============================================================================================
		# Read arr							#
		la $t0, arr							#
		addi $t1, $0, 0							# 	int i = 0;
										#
		# Read arr for loop						#
		for_read_arr:							#
			# Terminating condition check				#
			addi $t9, $t1, -20					#
			bgez $t9, end_for_read_arr				# 	while (i < 20){
										#
			# Read input and save to pointer $t0			#
			addi $v0, $0, 5						#
			syscall							#
			sw $v0, 0($t0)						#		scanf("%d", arr[i]);
										#
			# Update iterators					#
			addi $t0, $t0, 4					#					
			addi $t1, $t1, 1					#		i++;
			j for_read_arr						#
		end_for_read_arr:						# 	}
		# End read arr							#
		#---------------------------------------------------------------------------------------------
		
		#---------------------------------------------------------------------------------------------
		# mergeSort function calling					#
										#
		# Load parameter (int* arr, int size)				#
		la $a0, arr							#
		addi $a1, $0, 20						#
										#
		# Jump to mergeSort						#
		jal mergeSort							# 	mergeSort(arr, 20);
		# End mergeSort calling						#
		#---------------------------------------------------------------------------------------------
		
		#---------------------------------------------------------------------------------------------
		# Program terminating						#
		addi $v0, $0, 10						#
		syscall								# 	return 0;
		# End program terminating					# }
		#=============================================================================================
		
	##################################################################################################
	## PRINT ARRAY FUNCTION
	##################################################################################################
	printArr:								# void printArr(){
		#=============================================================================================
		# Load arr							#
		la $t0, arr							#
		addi $t1, $0, 0							# 	int i = 0;
										#
		# Print arr for loop						#
		for_print_arr:							#
			# Terminating condition check				#
			addi $t9, $t1, -20					#
			bgez $t9, end_for_print_arr				# 	while (i < 20){
										#
			# Print integer saved to pointer $t0			#
			addi $v0, $0, 1						#
			lw $a0, 0($t0)						#
			syscall							#		printf("%d", arr[i]);
										#
			# Print space character					#
			addi $a0, $0, ' '					#
			addi $v0, $0, 11					#
			syscall							# 		printf("%c", ' ');
										#
			# Update iterators					#
			addi $t0, $t0, 4					#
			addi $t1, $t1, 1					#		i++;
			j for_print_arr						#
		end_for_print_arr:						# 	}
										#
		# Print endline character					#
		addi $a0, $0, '\n'						#
		addi $v0, $0, 11						#
		syscall								#	printf("%c", '\n');
										#
		# Return to previous function					#
		jr $ra								# }
		# End read arr							#
		#=============================================================================================
		
	##################################################################################################
	## MERGE SORT FUNCTION
	##################################################################################################
	mergeSort:								# void mergeSort(int* arr, int size){
		#=============================================================================================
		# Unload parameter (int* arr, int size)				#
		add $s0, $a0, $0						#
		add $s1, $a1, $0						#
										#
		# Terminate function if size <= 1				#
		addi $t9, $s1, -1						#
		blez $t9, end_merge_sort					#	if (size <= 1) return;
										#
		#---------------------------------------------------------------------------------------------
		# Left half merge sort						#
										#
		# Save current parameters and return address to stack		#
		addi $sp, $sp, -4						#
		sw $ra, 0($sp)							#
		addi $sp, $sp, -4						#
		sw $s0, 0($sp)							#
		addi $sp, $sp, -4						#
		sw $s1, 0($sp)							#
										#
		# Compute new argument						#
		add $a0, $s0, $0						#
		addi $t2, $0, 2							#
		div $s1, $t2							#
		mflo $a1							#	\\ $a1 = size/2
										#
		# Half left merge sort						#
		jal mergeSort							#	mergeSort(arr, size/2);
										#
		# Pop parameters from stack					#
		lw $s1, 0($sp)							#
		addi $sp, $sp, 4						#
		lw $s0, 0($sp)							#
		addi $sp, $sp, 4						#
		lw $ra, 0($sp)							#
		addi $sp, $sp, 4						#
		# End left half merge sort					#
		#---------------------------------------------------------------------------------------------
		
		#---------------------------------------------------------------------------------------------
		# Right half merge sort						#
										#
		# Save current parameters and return address to stack		#
		addi $sp, $sp, -4						#
		sw $ra, 0($sp)							#
		addi $sp, $sp, -4						#
		sw $s0, 0($sp)							#
		addi $sp, $sp, -4						#
		sw $s1, 0($sp)							#
										#
		# Compute new argument						#
		addi $t2, $0, 2							#
		div $s1, $t2							#
		mflo $t0							#
		addi $t9, $0, 4							#
		mul $t1, $t0, $t9						#
		add $a0, $s0, $t1						#	\\ $a0 = arr + size/2;
		sub $a1, $s1, $t0						#	\\ $a1 = size - size/2;
										#
		# Half right merge sort						#
		jal mergeSort							#	mergeSort(arr + size/2, size - size/2);
										#
		# Pop parameters from stack					#
		lw $s1, 0($sp)							#
		addi $sp, $sp, 4						#
		lw $s0, 0($sp)							#
		addi $sp, $sp, 4						#
		lw $ra, 0($sp)							#
		addi $sp, $sp, 4						#
		# End right half merge sort					#
		#---------------------------------------------------------------------------------------------
		
		#---------------------------------------------------------------------------------------------
		# Merge 2 halves of the array					#
										#
		# Save current parameters and return address to stack		#
		addi $sp, $sp, -4						#
		sw $ra, 0($sp)							#
		addi $sp, $sp, -4						#
		sw $s0, 0($sp)							#
		addi $sp, $sp, -4						#
		sw $s1, 0($sp)							#
										#
		# Compute arguments for merge: (int* left, int* right, int sizeLeft, int sizeRight)
		add $a0, $s0, $0						#	// $a0= arr
		addi $t2, $0, 2							#
		div $s1, $t2							#
		mflo $t0							#
		addi $t9, $0, 4							#	// $t0 = size/2
		mul $t1, $t0, $t9						#
		add $a1, $a0, $t1						#	// $a1 = arr + size/2
		add $a2, $t0, $0						#	// $a2 = $t0
		sub $a3, $s1, $a2						#	// $a3 = size - size/2
										#
		# Half right merge sort						#
		jal merge							#	merge(arr, arr + size/2, size/2, size - size/2);
										#
		# Pop parameters from stack					#
		lw $s1, 0($sp)							#
		addi $sp, $sp, 4						#
		lw $s0, 0($sp)							#
		addi $sp, $sp, 4						#
		lw $ra, 0($sp)							#
		addi $sp, $sp, 4						#
		# End merge 2 halves						#
		#---------------------------------------------------------------------------------------------
		
		#---------------------------------------------------------------------------------------------
		# Print arr							#
										#
		# Save current parameters and return address to stack		#
		addi $sp, $sp, -4						#
		sw $ra, 0($sp)							#
		addi $sp, $sp, -4						#
		sw $s0, 0($sp)							#
		addi $sp, $sp, -4						#
		sw $s1, 0($sp)							#
										#
		# Half right merge sort						#
		jal printArr							#	ptintArr();
										#
		# Pop parameters from stack					#
		lw $s1, 0($sp)							#
		addi $sp, $sp, 4						#
		lw $s0, 0($sp)							#
		addi $sp, $sp, 4						#
		lw $ra, 0($sp)							#
		addi $sp, $sp, 4						#
		# End print arr							#
		#---------------------------------------------------------------------------------------------
										#
		# End function label						#
		end_merge_sort:							#
										#
		# Return to previous function					#	return;
		jr $ra								# }
		#=============================================================================================
		
	##################################################################################################
	## MERGE FUNCTION
	##################################################################################################
	merge:									# void merge(int* left, int* right, int leftSize, int rightSize){
		#=============================================================================================
		# Iterators initialize						#
		addi $t0, $0, 0							#	int i = 0;
		addi $t1, $0, 0							#	int j = 0;
		la $s0, tempArr							#	int* ptr = tempArr;			// or: int k = 0;
										#
		#---------------------------------------------------------------------------------------------
		# Merging for_loop						#
		for_merge:							#	
			# Checking condition					#
			sub $t9, $t0, $a2 					#
			bltz $t9, begin_for_merge				#
			sub $t9, $t1, $a3					#
			bltz $t9, begin_for_merge				#	while (i < leftSize || j < rightSize){
			j end_for_merge						#	
			begin_for_merge:					#
										#
			# Address adding unit					#
			addi $t9, $0, 4						#
			mul $t2, $t0, $t9					#
			mul $t3, $t1, $t9					#
			add $t4, $a0, $t2					#		
			add $t5, $a1, $t3					#
			lw $t6, 0($t4)						#		// $t6 = left[i]
			lw $t7, 0($t5)						#		// $t7 = right[j]
										#
			# Branching cases					#
			if1:							#
				sub $t9, $t0, $a2				#
				bltz $t9, if2					#		if (i >= leftSize){
				sw $t7, 0($s0)					#			*ptr = right[j];	// or: tempArr[k] = right[j];
				addi $t1, $t1, 1				#			j++;
				j end_branching					#		}
										#
			if2:							#
				sub $t9, $t1, $a3				#
				bltz $t9, if3					#		else if (j >= rightSize){
				sw $t6, 0($s0)					#			*ptr = left[i];		// or: tempArr[k] = left[i];
				addi $t0, $t0, 1				#			i++;
				j end_branching					#		}
										#
			if3:							#
				sub $t9, $t6, $t7				#
				bgtz $t9, if4					#		else if (left[i] <= right[j]){
				sw $t6, 0($s0)					#			*ptr = left[i];		// or: tempArr[k] = left[i];
				addi $t0, $t0, 1				#			i++;
				j end_branching					#		}
										#
			if4:							#		else{
				sw $t7, 0($s0)					#			*ptr = right[j];	// or: tempArr[k] = right[j];
				addi $t1, $t1, 1				#			j++;
										#
			end_branching:						#		}
										#
			# Update iterators					#
			addi $s0, $s0, 4					#		ptr++;				// or: k++;
			j for_merge						#
		end_for_merge:							#	}
		#---------------------------------------------------------------------------------------------
		
		#---------------------------------------------------------------------------------------------
		# Moving data to original array					#
										#
		# Iterators initialize						#
		la $s0, tempArr							#
		add $s1, $a0, $0						#	ptr = left;
		addi $t0, $0, 0							#	i = 0;
		add $t1, $a2, $a3						#	// $t1 = leftSize + rightSize;
										#
		# Moving data for loop						#
		for_moving_data:						#	
			# Checking condition					#
			sub $t9, $t0, $t1					#
			bgez $t9, end_for_moving_data				#	while (i < leftSize + rightSize){
										#
			# Moving data						#
			lw $t2, 0($s0)						#		
			sw $t2, 0($s1)						#		*ptr = tempArr[i];		// or: left[i] = tempArr[i];
										#
			# Update iterators					#
			addi $s0, $s0, 4					#
			addi $s1, $s1, 4					#		ptr++;
			addi $t0, $t0, 1					#		i++;
			j for_moving_data					#	}
		end_for_moving_data:						#
										#
		#---------------------------------------------------------------------------------------------
		# Return to previous function					#	return;
		jr $ra								# }
		#=============================================================================================
				
	
