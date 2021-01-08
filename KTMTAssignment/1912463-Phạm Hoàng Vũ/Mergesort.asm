.data
        set_size:       .asciiz         "Choose your array size: "
        error:          .asciiz         "Error"
        input:          .asciiz         "Input integer:\n"
        printText:      .asciiz         "Your array is: "
        result:         .asciiz         "\nSorted Array is: "
        merging:	.asciiz 	"\nMerging: "
        comma:          .asciiz         ", "
        ArraySize:      .word           0:1
        ArrayPtr:       .word           0:1
        ArrayPtrEnd:    .word           0:1
        ArrayTmp:       .word           0:1
        
.text
main:
		# Declare array ////////////////////////////	
                la              $s0, ArraySize                  # s0 = elementsNum 	   
                la              $s1, ArrayPtr                   # s1 = pointer to input array[0] address  
                la              $s2, ArrayPtrEnd                # s2 = pointer to input array[n] address
                la              $s3, ArrayTmp                   # s3 = pointer to temp array's address
		# /////////////////////////////////////////
		
		# Ask the user to set array's size ////////
        	li 		$v0, 4				    
		la 		$a0, set_size		     
		syscall
        	li 		$v0, 5			
		syscall
		slti		$t6, $v0, 1
		bne		$t6, $0, invalidSize		# If size < 1 then exit
		slti 		$t6, $v0, 21	
		beq 		$t6, $0, invalidSize		# If size > 20 then exit
		sw 		$v0, ($s0)			# Set s0 = constant array size			  
		# /////////////////////////////////////////
               
               	# Allocate memory for input array and temp array
        	li 		$t6, 4						
		mult 		$v0, $t6			   
		mflo 		$a0							    
		li 		$v0, 9			
		syscall
		sw 		$v0, ($s1)
		add             $v0, $v0, $a0	
		sw 		$v0, ($s2)			
		li 		$v0, 9			
		syscall
		sw 		$v0, ($s3)		
		# /////////////////////////////////////////
		                
                # Ask the user to enter array's elements 					  					  
        	li 		$v0, 4			
		la		$a0, input		  
		syscall
		lw              $a0, ($s1)			# Set t0 = pointer to array[0]                     
                lw              $a1, ($s2) 			# Set t1 = pointer to array[n]		
		jal 		read				# read(a0, a1)
		# /////////////////////////////////////////
		                                		               
		# Print input array ///////////////////////
                li            	$v0, 4                   
                la              $a0, printText                  
                syscall
                lw              $a0, ($s1)			# Reset pointer a0                      
                move	        $t0, $a0                                        
                jal             print				# print(a0, a1)                              
                # ////////////////////////////////////////
                
                # Mergesort(pointer Start = a0, pointer End = a1)                
                lw              $a0, ($s1)                                           
                jal             mergeSort			# mergesort(a0, a1)				
                # ///////////////////////////////////////
                
                # Print sorted array ////////////////////
                li            	$v0, 4                   
                la              $a0, result                     
                syscall           
                lw              $a0, ($s1)			# Reset pointer a0                             
                lw              $a1, ($s2)			# Reset pointer a1       
                move	        $t0, $a0                                      
                jal             print				# print(a0, a1)                              
		# //////////////////////////////////////
		
		# Exit program /////////////////////////
                li            	$v0, 10                 
                syscall
                # /////////////////////////////////////

merge: #(pointer Left, pointer Mid, pointer Right)
		# Reset pointer ////////////////////////
                lw              $t6, ($s3)                                     
                move            $t0, $a0                    	# t0 point to Left
                move            $t1, $a1                     	# t1 point to Mid
                move            $t2, $t6                     	# t2 point to temp
                # /////////////////////////////////////
                
leftArray:
                # Create leftArray /////////////////////
                lw              $t3, ($t0)                      
                sw              $t3, ($t2)                     	# leftArray[i] = array[i]
                addi            $t0, $t0, 4                     # array++
                addi            $t2, $t2, 4                     # leftArray++     
                bne             $t0, $a1, leftArray		# while (i < leftSize)
                move            $s4, $t2			# s4 point to end of leftArray
		# /////////////////////////////////////
		
rightArray:
		# Create rightArray ////////////////////
                lw              $t3, ($t1)                      
                sw              $t3, ($t2)                     	# rightArray[i] = array[i + mid] 
                addi            $t1, $t1, 4                     # array++
                addi            $t2, $t2, 4                     # rightArray++
                bne             $t1, $a2, rightArray		# while (i < rightSize)
                move            $s5, $t2                    	# s5 point to end of rightArray
                move            $t0, $t6                    	# t0 point to temp array (start of leftArray) ( i = 0 )
                move            $t1, $s4                     	# t1 point to end of leftArray (start of rightArray) ( j = 0 )
                move            $t2, $a0                     	# t2 point to Left (start of input array) ( k = 0 )
		# /////////////////////////////////////                

sortArray:
		# Sort leftArray and rightArray ///////
                beq             $t0, $s4, fillRight		# i = leftSize
                beq             $t1, $s5, fillLeft		# j = rightSize
                lw              $t3, ($t0)                      
                lw              $t4, ($t1) 
                slt 		$t6, $t3, $t4                     
                bne             $t6, $0, leftFirst		# if leftArray[i] < rightArray[j] 		
                sw              $t4, ($t2)                     	# else array[k] = rightArray[j]
                addi            $t1, $t1, 4                     # j = j + 1
                addi            $t2, $t2, 4                     # k = k + 1
                j               sortArray 
                # /////////////////////////////////////             
leftFirst:
		# /////////////////////////////////////
                sw              $t3, ($t2)                     	# array[k] = leftArray[i]
                addi            $t0, $t0, 4                     # i = i + 1
                addi            $t2, $t2, 4                     # k = k + 1
                j               sortArray  
                # /////////////////////////////////////
                
fillLeft:
		# Push remaining leftArray elements 
                beq             $t0, $s4, return		# i = leftSize
                lw              $t3, ($t0)                      
                sw              $t3, ($t2)                      
                addi            $t0, $t0, 4                     # i = i + 1
                addi            $t2, $t2, 4                     # k = k + 1
                j               fillLeft                           
		# /////////////////////////////////////

fillRight:
		# Push remaining rightArray elements
                beq             $t1, $s5, return		# j = rightSize
                lw              $t3, ($t1)                      
                sw              $t3, ($t2)                                      
                addi            $t1, $t1, 4                     # j = j + 1
                addi            $t2, $t2, 4                     # k = k + 1
                j               fillRight                           
                # /////////////////////////////////////
                 		             
mergeSort: #(pointer Start, pointer End)	
		# Calculate pointer Mid //////////////
                beq             $a0, $a1, return                
                sub             $t0, $a1, $a0                   
                beq             $t0, 4, return
                slti		$t6, $t0, 4
                bne		$t6, $0, return              
                srl             $t0, $t0, 3                     # t0 = t0 / 8	
	        sll             $t0, $t0, 2                     # t0 = t0 x 4
                add             $t0, $t0, $a0               
                # ///////////////////////////////////// 
                
                # Push pointers into stack, which can be reused after recursion     
        	addi 		$sp, $sp, -16			# Make room for 4 elements in stack	
        	sw 		$ra, 12($sp)			# Push return address into stack		   
        	sw 		$a0, 8($sp)		       	# Push Start address into stack
        	sw 		$a1, 0($sp)			# Push End address into stack			  
        	sw 		$t0, 4($sp)			# Push Mid address into stack		      
        	# ////////////////////////////////////////////
        	
                # Mergesort(start, mid) //////////////////////
                lw              $a1, 4($sp)                     # a1 point to Mid
                jal             mergeSort			# mergesort(a0, a1)
                # ////////////////////////////////////////////
                
                # Mergesort(mid, end) /////////////////////
                lw              $a0, 4($sp)			# a0 point to Mid                    			
                lw              $a1, 0($sp)			# a1 point to End                    
                jal             mergeSort			# mergesort(a0, a1)
                # ////////////////////////////////////////////
                
		# Merge //////////////////////////////////////          
                lw              $a0, 8($sp)                     # a0 point to Start
                lw              $a1, 4($sp)                     # a1 point to Mid 
                lw              $a2, 0($sp)                     # a2 point to End
                jal             merge				# merge(a0, a1, a2)                              
                # //////////////////////////////////////////

		# Print merging array /////////////////
		li		$v0, 4
		la 		$a0, merging
		syscall			
		lw 		$a0, 8($sp)
		lw		$a1, 0($sp)
		move 		$t0, $a0	
		jal		print				# print(a0, a1)
 		# /////////////////////////////////////
 		                  
                lw              $ra, 12($sp)			# Return caller address                    
                addi            $sp, $sp, 16                    # Pop 4 elements out of stack	
		j return

read: #(pointer Start, pointer End)
		# Set array[0] -> array[n-1] ///////////////
                beq             $a0, $a1, return		# i = n : exit
                li            	$v0, 5                  
                syscall
                sw              $v0, ($a0)			# Set array[i]                    
                addi            $a0, $a0, 4			# t0 point to array[i + 1]                     
                j               read				# read(a0 + 1, a1)
                # //////////////////////////////////////////
                		
print: #(pointer Start, pointer End)       
		# Print array[Start] -> array[End - 1] /////////   	               
                lw              $a0, ($t0)			# Print array[i]                     
                li            	$v0, 1                   
                syscall
                addi            $t0, $t0, 4			# t0 point to array[i + 1] 
                beq             $t0, $a1, return		# i = n : don't print ','   
                li            	$v0, 4                  
                la              $a0, comma			                     
                syscall
                j               print                           # print(a0 + 1, a1)
                # ///////////////////////////////////////
                                                                                                                     
return:
        	jr 		$ra
        	
invalidSize:
		# Exit if array's size is invalid ////////////
		li 		$v0, 4
		la 		$a0, error
		syscall
		li 		$v0, 10
		syscall
		# ////////////////////////////////////////////
