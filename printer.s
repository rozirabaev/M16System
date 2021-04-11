section	.rodata			; we define (global) read-only variables in .rodata section
	format: db "%.2f", 10, 0	; format float
    format_no_line: db "%.2f", 0	; format string
    format_digit: db "%d", 0	; format int
    format_string: db "%s", 0	; format str
    comma: db " ,",0
    nl: db "", 10,0

    newline: db "",0

section .data
    global printer_function


section .text
    extern drones_arr
    extern target_x
    extern target_y
    extern resume
    extern target
    extern scheduler
    extern printf
    extern numco
    extern print_drones

%macro print_float 1
    pushad
        fld qword %1
        sub esp,8
        fstp qword [esp]
        push dword  format_no_line
        call printf    
        add esp,12
        popad
%endmacro

%macro print_ 2
    pushad
    push dword %1
    push dword  %2
    call printf    
    add esp,8
    popad
%endmacro

printer_function:
print_game_board:
   call print_drones
end_loop:
    mov ebx, scheduler
    call resume
    jmp printer_function
    
    
    
    
reserve:
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
    mov eax, comma
    print_ eax, format_string
    print_float [ebx]  ;x
b1:
    mov eax, [ebx]

    mov eax, comma
    print_ eax, format_string
b2:
    mov eax, [ebx+4]
    
    print_float  [ebx+4]  ;y

    mov eax, comma
    print_ eax, format_string
b3:
    mov eax, [ebx+8]
    
    print_float  [ebx+8]  ;speed

    mov eax, comma
    print_ eax, format_string
bbb:
    mov eax, [ebx+12]
    print_float  [ebx+12]  ;angle
    
    mov eax, comma
    print_ eax, format_string
b4:
    mov eax, [ebx+20]
    
    print_ eax, format_digit  ;num of targets
    
    print_ nl, format_string
        jmp loop_over_drones
    
    
    
    
    
    
    
    
    
    
