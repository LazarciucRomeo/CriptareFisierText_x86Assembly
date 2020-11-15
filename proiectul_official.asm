.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;include libraries, and declare what functions we want to import
includelib msvcrt.lib
extern printf: proc
extern fscanf: proc
extern fopen: proc
extern fprintf: proc
extern fclose: proc
extern printf: proc
extern scanf: proc
extern exit: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

public start
;declare the start symbol as public - from there the execution begins
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sections of the program, data or code
.data

	filename db "text.txt", 0
	filename2 db "dictionar.txt", 0
	filename3 db "rezultat.txt", 0
	
	
	format db "%s", 0
	format_citire db "%s", 0
	format_dictionar db " %d", 0
	format_caracter db " %c", 0
	
	
	mode_read db "r", 0
	mode_write db "w",0
	
	buffer db 100 dup(0)
	
	DICTIONAR struct
	cuvant db 10 dup(0)
	contor dw 0
	DICTIONAR ends
	
	var DICTIONAR 10 dup({})  
	
	numar db 0
	rez db 10 dup(0)
	index db 0
	fptr dd 0

.code
start:
	
	push offset mode_write
	push offset filename3
	call fopen
	add ESP,8
	mov fptr, eax

	push offset mode_read
	push offset filename
	call fopen
	add esp, 8
	mov ebx, eax 
    mov eax, esi
    lea edi, var[0].cuvant

    
bucla_citire:
	push offset buffer
	push offset format_citire
	push ebx
	call fscanf
	mov edx,edi
	add eax,1
	test eax, eax ;verific daca eax este bine setat
	jz inchidere_fisier
	xor eax, eax    ;eax devine 0
	xor ecx,ecx    
	mov cl,numar       ;numarul de cuvinte
	add cl,1        ;incepem de la 1
	mov edi,edx
	lea edx,var[0].cuvant ;punem offsetul cuvantului

adunare:
	lea esi,buffer  ;in esi punem offset bufferului
	dec edx   ;decrementam edx
	xor ebp,ebp ;curat ebp
	dec ebp  ;decrementam ebp

comparare:
	inc edx
	inc ebp
	lodsb ;load byte at address DS:(E)SI into AL
	cmp [edx],al ;litera
	jne diferit
	cmp al,0
	je egal      ;exista cuvant in dictionar
	jne comparare

diferit:
	sub edx,ebp ;edx=0
	add edx,12	
	loop adunare
	mov edx,edi
	lea esi,buffer
	xor ebp,ebp

adaugare_dictionar:	
	inc ebp
	mov al,[esi]
	cmp al,0
	je adaugat
	mov [edx],al
	inc esi
	inc edx
	jmp adaugare_dictionar

adaugat:
	sub edx,ebp ;scadem din edx ebp
	inc edx
	add [numar],1
	add edx,10
	mov cl,numar ; 
	add cl,48 ; cod ascii caracter 0
	mov [edx],cl
	add edx,2
	mov edi,edx
	lea eax,rez
	add al,index
	mov [eax],cl
	add [index],1
	jmp bucla_citire

egal:
	sub edx,ebp
	mov ebp,edx
	add edx,10
	lea eax,rez
	add al,index
	mov cl,[edx]
	mov [eax],cl
	add [index],1
	jmp bucla_citire

	
inchidere_fisier:
	push ebx
	call fclose
	add esp, 4
	push offset mode_write
	push offset filename2
	call fopen

	push offset rez
	push offset format
	push fptr
    call fprintf

	add esp, 12


	;scriere in dictionar
	push offset mode_write
	push offset filename2
	call fopen
	mov ebx,eax
	xor ecx,ecx
	mov cl,numar
	mov edi,ecx
	lea ebp,var[0].cuvant
	
	
scriere_dictionar:
	push ebp
	push offset format
	push ebx
	call fprintf
	add ebp,10
	xor eax,eax
	mov ax,[ebp]
	sub eax, 48 ;valoare 0
	push eax
	push offset format_dictionar
	push ebx
	call fprintf
	add ebp,2
	mov eax, 10
	push eax
	push offset format_caracter
	push ebx
	call fprintf
	dec edi
	cmp edi,0
	jne scriere_dictionar

	push ebx
	call fclose
	
;end
	push 0
	call exit
end start


