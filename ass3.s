 
    CODEP equ 0 ; offset of pointer to co-routine function in co-routine struct
    SPP equ 4 ; offset of pointer to co-routine stack in co-routine struct
    

section	.rodata			; we define (global) read-only variables in .rodata section
	format: db "%s", 10, 0	; format string
    formatD: db "%s", 0	; format string
    format_digit: db "%d", 10, 0	; format string
    format_float: db "%.2f", 10, 0	; format string
    format_hex: db "%X", 10, 0	; format string
    format_hexd: db "%02X", 0	; format string
    format_print: db "%0X", 0
    dbug_msg: db "DBUG:",0
    newline: db "",0
    format_scan_digit: db "%d"
    format_scan_float: db "%f"
    
    
    winner_drone: db "The Winner is drone: ",0

    
    
   
section .data 
    global numco
    global drones_arr
    global target_x
    global target_y
    global lfsr_function
    global lfsr
    global resume
    global max_dist
    global target
    global drones_arr
    global printer
    global R  ;R
    global K  ;K
    global numco
    global CORS
    global endCo
    global scheduler
    global main
    global range_random
    global range_res
    global min_range
    global temp_for_random
    global range_res
    global maxint
    
    pointer: dd 0
    numco: dd 3
    R: dd 0
    K: dd 0
    max_dist: dd 0
    seed: dd 0
    temp: dd 0
    scheduler: dd scheduler_function ; struct of first co-routine
                dd STK1+STKSZ
    printer: dd printer_function ; struct of second co-routine
             dd STK2+STKSZ
    target: dd target_function ; struct of scheduler
            dd STK3+STKSZ
    target_x: dd 0.0
    target_y: dd 0.0
    temp_for_random: dd 0
    min_range: dd 0
     maxint: dd 65535
    range_res: dd 0
    

section .bss
    CORS: resb 4  ; pointer to cors  
    CURR: resd 1
    SPT: resd 1 ; temporary stack pointer
    SPMAIN: resd 1 ; stack pointer of main
    STKSZ equ 16*1024 ; co-routine stack size

    STK1: resb STKSZ
    STK2: resb STKSZ
    STK3: resb STKSZ
    lfsr: resb 16 ;
    drones_arr: resb 4 ; pointer
  

section .text
      extern calloc
    extern drones_function
    extern scheduler_function
    extern target_function
    extern printer_function
    extern sscanf
    extern printf
   
%macro sscanf_ 2
    pushad

    push ebx        ;dest str
    push dword %1   ;str
    push dword  %2  ;format
    

    call sscanf  
    mov [temp], ebx
    
    add esp,12
    popad
%endmacro

%macro sscanf_f 2
    pushad

    push temp
    push dword  %2
    push dword %1
    

    call sscanf  
   ; mov [temp], ebx
    
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
    
%macro convArgs 1  ; input is num in ascii
    pushad
    mov eax, %1 ;pointer to string
    mov edx, 0  ; future result in hex
    mov ecx, 0 ;counter
%%loop:
    mov ebx, 0
    mov bl, [eax+ecx]
    cmp bl, 0   ;null term
    je %%end
    sub ebx, 48
    or edx, ebx
    shl edx, 4
    inc ecx
    jmp %%loop
%%end:
    shr edx, 4
    mov [temp], edx
    popad
%endmacro

%macro calloc_ 1
    pushad
    push  1
    push  %1
    call calloc
    add esp, 8
    mov [pointer], eax
    popad
%endmacro
 ;*******************************************************MAIN*****************************************************************
main:
   
    mov ecx, [esp+4]    ; ecx = argc
    dec ecx
    mov ebx, 1
    finit ; initialize the x87 subsystem
args_loop:
    mov edx, [esp +8]   ;edx - pointer to argv**
    cmp ecx, 0          ;end loop
    je endl
    mov edx,[edx+4*ebx]     ;get next argument
    cmp ebx, 1
    je argNum 
    cmp ebx, 2
    je elimin
    cmp ebx, 3
    je print_step
    cmp ebx, 4
    je max_dis
    cmp ebx, 5
    je in_seed
    next:
    dec ecx
    inc ebx
    jmp args_loop
    argNum:
        sscanf_f edx, format_scan_digit
        brefak:
        mov edx, [temp]
        mov [numco], edx
        jmp next
    elimin:
        sscanf_f edx, format_scan_digit
        mov edx, [temp]
        mov [R], edx
        jmp next
    print_step:
        sscanf_f edx, format_scan_digit
        mov edx, [temp]
        mov [K], edx
        jmp next
    max_dis:
        sscanf_f edx, format_scan_float
        fld dword [temp]
        fst dword [max_dist]
       
jmp next
    in_seed:
        sscanf_f edx, format_scan_digit
        mov edx, [temp]
        mov [seed], edx
        jmp next
endl:

initiate_for_vars_lfsr:
    mov eax, 0
    mov eax, [seed]                
    mov [lfsr], eax

brr:
inutiate_drones_array:          ;(x,y,speed,angle,active,targets)
    mov eax, [numco]
    mov edx, 4
    mul edx
    calloc_ eax 
    mov eax, [pointer]
    mov [drones_arr], eax  ;pointer to array
    mov ebx, [drones_arr]
    mov ecx, 0
    array_loop:
        cmp ecx, [numco]
        je get_started
        calloc_ 24  ;x,y,speed,angle,non-active, num of targets destroyed
        mov eax, [pointer]
        mov [ebx+ecx*4], eax
        inc ecx
        jmp array_loop
    ;------------------start to drons cors------------------------------
get_started:
    mov eax, [numco]
    mov edx, 4
    mul edx
    calloc_ eax
    mov eax, [pointer]
    mov [CORS], eax
    mov ebx, [CORS]
    mov edx, 0
    init_loop:
        cmp [numco], edx
        je endLoop
        calloc_ 8
        mov eax, [pointer]
        mov [ebx + 4*edx], eax
        mov ecx, drones_function
        mov [eax], ecx  ; points to relevent function
        mov ecx, STKSZ 
        calloc_ ecx
        mov ecx, [pointer]
        add ecx, STKSZ
        mov [eax +4], ecx    ;point to stack 
        jmp initCo
    initCo:                                             ;********************************** SHOULD INITIALIZE FRON I=0 TO NUMCO CORUTINS 
        mov ecx, [4*edx + ebx]                      ; get pointer to COi struct
        mov eax, [ecx+CODEP]                         ; get initial EIP value – pointer to COi function
        mov [SPT], esp                               ; save ESP value
        mov esp, [ecx+SPP]                           ; get initial ESP value – pointer to COi stack
        push eax                                     ; push initial “return” address
        pushfd                                       ; push flags
        pushad                                       ; push all other registers
        mov [ecx+SPP], esp                           ; save new SPi value (after all the pushes)
        mov esp, [SPT]
        inc edx 
        jmp init_loop
        
    endLoop:    

    mov edx, 0
    ;-----------------------------------------initiate fo target-------------------------------------------------------
    initCo_one:
        cmp edx, 3
        je endinit
        cmp edx , 0 ;TARGET
        jne next_cmp
        mov ebx, target
        jmp initiat_cors
    next_cmp:
        cmp edx, 1
        jne next_cmp1
        mov ebx, printer
        jmp initiat_cors
    next_cmp1:
        mov ebx, scheduler
        jmp initiat_cors

        ;---------------------------------------initiate fo scheduler,target,printer--------------------------------------
initiat_cors:

    mov eax, [ebx+CODEP] ; get initial EIP value – pointer to COi function
    mov [SPT], esp ; save ESP value
    mov esp, [ebx+SPP] ; get initial ESP value – pointer to COi stack
    push eax ; push initial “return” address
    pushfd ; push flags
    pushad ; push all other registers
    mov [ebx+SPP], esp ; save new SPi value (after all the pushes)
    mov esp, [SPT] ; restore ESP value
    inc edx
    jmp initCo_one

endinit:

;----------------------------------------------start scheduler-------------------------------------------------

startCo:                               
    pushad ; save registers of main ()
    mov [SPMAIN], esp ; save ESP of main ()
    mov ebx, scheduler ; gets a pointer to a scheduler struct
    jmp do_resume ; resume a scheduler co-routine
        
;------------------------------------------resume co-routine(not from main)--------------------------------
resume: ; save state of current co-routine
    pushfd
    pushad
    mov EDX, [CURR]
    mov [EDX+SPP], ESP ; save current ESP
;-----------------------------------------do-resume(from main)---------------------------------------------
do_resume: ; load ESP for resumed co-routine
    mov esp, [ebx+SPP]
    mov [CURR], ebx
    popad ; restore resumed co-routine state
    popfd
    ret ; "return" to resumed co-routine

    
;-----------------------------------------end of co-routins(from scheduler)-------------------------------------------------------

endCo:
    mov ESP, [SPMAIN] ; restore ESP of main()
    popad ; restore registers of m
    mov eax,1 ;system call number (sys_exit)
    mov ebx, 0 ;exit status
    int 0x80 ;call kernel
    nop

;-----------end main-------------------------

;******************************************************helpers******************************************************

lfsr_function:

    mov ax,  [lfsr]
    mov dx, 1                         
    and dx, ax
    mov cx, 4                        
    and cx, ax
    shr cx, 2
    xor dx, cx
    mov cx, 8                         
    and cx, ax
    shr cx, 3
    xor dx, cx
    mov cx, 32                      
    and cx, ax
    shr cx, 5
    xor dx, cx
    shl dx, 15
    shr ax, 1
    or ax, dx
    mov [lfsr], ax
 ret
    
    
    
    
range_random:   
    call lfsr_function
    break_rand:
    fild dword [lfsr] ; load [radius] into st(0)
    fidiv dword [maxint]
    fild dword [temp_for_random]
    fmulp
    fild dword [min_range]
    fsubp
    fstp dword [range_res]
    ret
    

    
    
    
    
    
    
    
    
    
    
    
    
