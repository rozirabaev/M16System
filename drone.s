
section .rodata
format_digit: db "%d", 0	; format string
format_no_line: db "%.2f",0	; format string
 format_string: db "%s", 0	; format str
    comma: db ", ",0
    point: db ". ",0
    nl: db "", 10,0

section .data
global curr_drone_index
    global drones_functions
    global range_random
    global min_range
    global temp_for_random
    global print_drones
    
    
    delta_a: dd 0
    delta_alfa: dd 0
    delta_y: dd 0
    delta_x: dd 0
    curr_x: dd 0
    curr_y: dd 0
    curr_speed: dd 0
    curr_angle: dd 0
    curr_drone_index: dd 0
   
    temp_x: dd 0
    curr_distance: dd 0
    pi: dd 0
    handred: dd 100
    h_eight: dd 180
    zero: dd 0
    three_six: dd 360
    
    
    section .bss
   
    

section .text
    extern maxint
    extern range_res
    extern drones_arr
    extern target_x
    extern target_y
    extern resume
    extern max_dist
    extern target
    extern numco
    extern scheduler
    extern seed
    extern lfsr
    extern lfsr_function
    global drones_function
    extern printf
    extern range_random
    extern range_res
    extern min_range
    extern temp_for_random
    


%macro print_float 1
    pushad
        fld dword %1
        sub esp,8
        fstp qword [esp]
        push dword  format_no_line
        call printf    
        add esp,12
        popad
%endmacro
    
%macro mayDistroy 0
    fld dword [target_x]
    fsub dword [curr_x]
    fst st1 ; copy st(0) into st(1)
    fmulp 
    fstp dword [temp_x]
    fld dword [target_y]
    fsub dword [curr_y]
    fst st1 ; copy st(0) into st(1)
    fmulp
    fadd dword [temp_x]
    fsqrt 
    fld dword [max_dist]
    fcomip
    jnc %%end1
    fstp dword [curr_distance]
    jmp %%end
update_killed:
%%end1:
    fstp dword [curr_distance]
    mov edx, [curr_drone_index]
    mov ebx, [drones_arr]
    mov ecx, [ebx+edx*4]
    mov  ebx,[ecx+20]
    inc ebx
    mov [ecx+20], ebx
    mov ebx, target
    call resume
%%end:
%endmacro

%macro print_ 2
    pushad
    push dword %1
    push dword  %2
    call printf    
    add esp,8
    popad
%endmacro

drones_function:
    call initiate_values
    
drones_loop:
    call initiate_values
again_in_loop:
    mayDistroy
b3:
    mov ebx, scheduler
    ;print_ ebx, format_digit
    call resume
    jmp drones_loop
    
  ;-------------------------------------------------functions---------  

%macro compute_x 0
    fld dword [curr_angle]
    fldpi
    fmulp
    fild dword [h_eight]
    fdivp  ;radins
    fcos 
    fld  dword [curr_speed]
    fmulp
    fld dword [curr_x]
    faddp 
    fild dword [zero]
    fcomip 
    jnc %%normal1
    jmp %%next
 %%normal1:
    fild dword [handred]
    faddp 
%%next:
    fild dword [handred]
    fcomip 
    jc %%normal
    jmp %%end
 %%normal:
    fild dword [handred]
    fsubp
%%end:
    fstp dword [curr_x]
%endmacro

%macro compute_y 0
    fld dword [curr_angle]
    fldpi
    fmulp
    fild dword [h_eight]
    fdivp  ;radins
    fsin 
    fld  dword [curr_speed]
    fmulp
    fld dword [curr_y]
    faddp 
    fild dword [zero]
    fcomip 
    jnc %%normal1
    jmp %%next
 %%normal1:
    fild dword [handred]
    faddp 
%%next:
    fild dword [handred]
    fcomip 
    jc %%normal
    jmp %%end
 %%normal:
    fild dword [handred]
    fsubp
%%end:
    fstp dword [curr_y]
%endmacro

%macro compute_angle 0
    fld dword [curr_angle]
    fadd dword [delta_alfa]
    fild dword  [three_six]
    fcomip
    jc %%normalGreat
    fild dword [zero]
    fcomip
    jnc %%normalLess
    jmp %%end
%%normalGreat:
    fild dword [three_six]
    fsubp
    jmp %%end
%%normalLess:
    fild dword [three_six]
    faddp
%%end:
    fstp dword [curr_angle]
%endmacro


%macro compute_speed 0
    fld dword [curr_speed]
    fld dword [delta_a]
    faddp
    fild  dword  [handred]
    fcomip
    jc %%normalGreat
    fild  dword [zero]
    fcomip
    jnc %%normalLess
    jmp %%end
%%normalGreat:
    fild dword [handred]
    fsubp 
    jmp %%end
%%normalLess:
    fild dword [handred]
    faddp
%%end:
        fstp dword [curr_speed]
%endmacro


%macro keep_pi 0
    fldpi
    fst st1 ; copy st(0) into st(1)
    faddp
    fstp dword [pi]
%endmacro


initiate_values:      ;**********initiate function*****
   ; call test_print
    mov edx, [curr_drone_index]
    br_ind:
    mov ebx, [drones_arr]
    mov ecx, [ebx+edx*4]
    mov  ebx,[ecx]
    mov [curr_x], ebx
    mov ebx, [ecx+4]
    mov [curr_y], ebx
    mov ebx, [ecx+8]
    mov [curr_speed], ebx
    mov ebx, [ecx+12]
    mov [curr_angle], ebx
    keep_pi   ;keeps the value of 2pi  (360)
    
compute_new_values:
    mov eax, -60
    mov edx, 60
    mov dword [temp_for_random], 120
    mov dword [min_range], 60
    call range_random 
    fld dword [range_res]
    fstp dword [delta_alfa] ;angle
ttt:
    mov eax, -10
    mov edx, 10
    mov dword [temp_for_random], 20
    mov dword [min_range], 10
    call range_random 
    fld dword [range_res]
    fstp dword [delta_a]
   
range:
    compute_x
    br_x:
    compute_y
    br_y:
    compute_angle
    br_angle:
    compute_speed
    br_speed:
update_values:
    mov edx, [curr_drone_index]
    mov ebx, [drones_arr]
    mov ecx, [ebx+edx*4]
    fld dword [curr_x]
    mov eax, [ecx]
    fstp dword [ecx]
    ;print_float  [ecx]  ;y
    b11:
    mov eax, [ecx]
    fld dword [curr_y]
    mov eax, [ecx+4]
    fstp dword [ecx+4]
    ;print_float  [ecx+4]  ;y
    mov eax, [ecx+4]
    fld dword [curr_speed]
    mov eax, [ecx+8]
    fstp dword [ecx+8]
    ;print_float  [ecx+8]  ;y
    mov eax, [ecx+8]
    fld dword [curr_angle]

    mov eax, [ecx+12]
    fstp dword [ecx+12]
    ;print_float  [ecx+12]  ;y
bang:
    mov eax, [ecx+12]
    ret

;-----------------------------------
print_drones:
    print_float [target_x]
    mov eax, comma
    print_ eax, format_string
    print_float [target_y]
    print_ nl, format_string
    
    mov edx, 0
    mov ecx, [drones_arr]
loop_over_drones:
    cmp dword edx, [numco]
    je end_loop
    mov ebx, [ecx+4*edx] ;next drone
    inc edx
    print_ edx, format_digit   ;num
    mov eax, point
    print_ eax, format_string
    print_float [ebx]  ;x

    mov eax, comma
    print_ eax, format_string
    
    print_float  [ebx+4]  ;y

    mov eax, comma
    print_ eax, format_string
  
    print_float  [ebx+8]  ;speed

    mov eax, comma
    print_ eax, format_string

    print_float  [ebx+12]  ;angle
    
    mov eax, comma
    print_ eax, format_string

    mov eax, [ebx+20]
    
    print_ eax, format_digit  ;num of targets

     mov eax, comma
    print_ eax, format_string

    mov eax, [ebx+16]
    
    print_ eax, format_digit  ;num of targets
   
    
    print_ nl, format_string
        jmp loop_over_drones
end_loop:
    print_ nl, format_string
    ret
