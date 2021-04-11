
section .rodata
    format: db "%s", 0	; format string
    format_digit: db "%d", 10, 0	; format string
    winner_drone: db "The Winner is drone: ",0


section .data
    roundes: dd 0
    active_drones: dd 0
    min_targets: dd 2147483647
    min_targets_index: dd 0
    max_int: dd 65535




section .text
    extern resume
    extern drones_arr
    extern printer
    extern R  ;R
    extern K  ;K
    extern numco
    extern CORS
    extern printf
    extern endCo
    global scheduler_function
    extern curr_drone_index

%macro print_ 2
    pushad
    push dword %1
    push dword  %2
    call printf    
    add esp,8
    popad
%endmacro


scheduler_function:
scheduler_loop:
    
    mov eax, [numco]
    mov [active_drones], eax
    mov ecx, -1
get_active_dr:
    inc ecx
    cmp ecx, [numco]
    je loop
    mov edx, [drones_arr]
    mov ebx, [edx+4*ecx]
    mov eax, [ebx+16]
    br_:
    cmp eax, 1
    je get_active_dr
loop:
    cmp ecx, [numco]
    jne check_print
    call next_round
    jmp get_active_dr

    check_print: 
        cmp ecx, 0
        je call_drone  
        mov edx, 0
        mov ebx, [K]
        mov eax, ecx
        div ebx 
        cmp edx, 0
        je print  ;i%k==0
        jmp call_drone
    print:
        mov ebx, printer
        call resume
    
    call_drone:
        mov [curr_drone_index], ecx
        mov edx, [CORS]
        mov ebx, [edx+4*ecx]
        call resume 
 before_loop:
    jmp get_active_dr
    
 
 
next_round:
    mov eax, [roundes]
    inc eax
    mov [roundes], eax
    mov ebx, [R]
    cmp eax, ebx
    jne go_to_loop
    call turn_off_drone
    call check_is_one_active_drone
    mov eax, 0
    mov [roundes], eax

go_to_loop:
    mov ecx, -1
    ret
    
turn_off_drone:
    pushad
    mov ecx, [drones_arr]
    mov edx, 0  ;counter
find_min_loop:
    cmp edx, [numco]
    je end_min_loop
    mov ecx, [drones_arr]
    mov ebx, [ecx+4*edx]
    mov eax, [ebx+16] ; active?
    cmp eax, 1  ; in  non active
    nnn:
    jne is_active_
    inc edx
    jmp find_min_loop
is_active_:
    mov eax, [ebx+20]
    cmp eax, [min_targets]
    jl is_less
    inc edx
    jmp find_min_loop
is_less:
    mov [min_targets], eax
    mov [min_targets_index], edx
    inc edx
    jmp find_min_loop
end_min_loop:
    mov ecx, [drones_arr]
    mov edx, [min_targets_index]
    mov ebx, [ecx+4*edx]  ; deactivated it 
    mov dword [ebx+16], 1
    mov edx, [active_drones]
    dec edx
    mov [active_drones], edx
    mov eax,2147483647
    mov [min_targets], eax
    popad
    ret
    

check_is_one_active_drone:
    mov eax, [active_drones]
    cmp eax, 1
    jne end_active
    mov edx, 0
    mov ecx, [drones_arr]
get_the_active:
    cmp edx, [numco]
    je end_active
    mov ebx, [ecx+4*edx]
    mov eax, [ebx+16] ; active?
    cmp eax, 1  ; in  non active
    jne is_active
    inc edx
    jmp get_the_active
is_active:

    print_ winner_drone, format
    inc edx
    print_ edx, format_digit
   ; call free_mem
    call endCo
end_active:
    ret
    
