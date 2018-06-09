.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "T.E.T.R.I.S",0
area_width EQU 640
area_height EQU 640
area DD 0
linie DD 0
coloana DD 256
symbol DD 'L'
sters dd 0
rotor DD 4
valid DD 1
dificultate DD 3
score dd 0
game_over dd 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
piece_height EQU 96
piece_width EQU 96
include digits.inc
include letters.inc
include pieces.inc
include pieces1.inc
include pieces2.inc
include pieces3.inc
include pieces4.inc
include pieces5.inc
include pieces6.inc
include pieces7.inc
;include file.inc
.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	;mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_piece proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'X'
	jne comp
	mov eax, symbol
	add eax,1
comp:
	cmp eax, 'I'
	je I
	cmp eax, 'J'
	je J
	cmp eax, 'T'
	je T
	cmp eax, 'U'
	je U
	cmp eax, 'O'
	je O
	cmp eax, 'P'
	je P
	cmp eax, 'L'
	je L
	cmp eax, 'M'
	je M
	cmp eax, 'A'
	je A
	cmp eax, 'B'
	je B
	cmp eax, 'S'
	je S
	cmp eax, 'R'
	je R
	cmp eax, 'Y'
	je Y
	cmp eax, 'Z'
	je Z
	cmp eax, 'C'
	je Ce
	cmp eax, 'D'
	je D
	
P:	mov eax, 0
	lea esi, square
	jmp draw_piece
O:	mov eax, 4
	lea esi, square
	jmp draw_piece
B:	mov eax, 0
	lea esi, piece4
	jmp draw_piece
A:	mov eax, 4
	lea esi, piece4
	jmp draw_piece
M:	mov eax, rotor
	sub eax,4
	lea esi, piece1
	jmp draw_piece
L:	mov eax, rotor
	lea esi, piece1
	jmp draw_piece
U:	mov eax, rotor
	sub eax,4
	lea esi, piece2
	jmp draw_piece
T:	mov eax, rotor
	lea esi, piece2
	jmp draw_piece
J:	mov eax, rotor
	sub eax,4
	lea esi, piece3
	jmp draw_piece
I:	mov eax, rotor
	lea esi, piece3
	jmp draw_piece
S:	mov eax, rotor
	sub eax,4
	lea esi, piece5
	jmp draw_piece
R:	mov eax, rotor
	lea esi, piece5
	jmp draw_piece
Z:	mov eax, rotor
	sub eax,4
	lea esi, piece6
	jmp draw_piece
Y:	mov eax, rotor
	lea esi, piece6
	jmp draw_piece
D:	mov eax, rotor
	sub eax,4
	lea esi, piece7
	jmp draw_piece
Ce:	mov eax, rotor
	lea esi, piece7
	jmp draw_piece
	
draw_piece:
	mov ebx, piece_width
	mul ebx
	mov ebx, piece_height
	mul ebx
	add esi, eax
	mov ecx, piece_height
bucla_piece_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, piece_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, piece_width
	
bucla_piece_coloane:
	cmp dword ptr [edi], 0C0C0C0h
	je piece_pixel_next
	cmp dword ptr [esi],0h
	je piece_pixel_next
	cmp dword ptr [esi],01h
	je piece_pixel_alb
	push ecx
	mov ecx, dword ptr [esi]
	mov dword ptr [edi], ecx
	pop ecx	
	jmp piece_pixel_next
piece_pixel_alb:
	mov dword ptr [edi], 0000000h
piece_pixel_next:
	add esi,4
	add edi, 4
	loop bucla_piece_coloane
	pop ecx
	loop bucla_piece_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_piece endp

; un macro ca sa apelam mai usor desenarea simbolului
make_piece_macro macro symbol_piece, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol_piece
	call make_piece
	add esp, 16
endm

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol_text, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol_text
	call make_text
	add esp, 16
endm
verify proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	
	cmp eax, 'O'
	je O1
	cmp eax, 'P'
	je P1
	cmp eax, 'L'
	je L1
	cmp eax, 'M'
	je M1
	cmp eax, 'T'
	je T1
	cmp eax, 'U'
	je U1
	cmp eax, 'I'
	je I1
	cmp eax, 'J'
	je J1
	cmp eax, 'A'
	je A1
	cmp eax, 'B'
	je B1
	cmp eax, 'R'
	je R1
	cmp eax, 'S'
	je S1
	cmp eax, 'Y'
	je Y1
	cmp eax, 'Z'
	je Z1
	cmp eax, 'C'
	je C1
	cmp eax, 'D'
	je D1
	
P1:	mov eax, 0
	lea esi, square
	jmp draw_verify
O1:	mov eax, 4
	lea esi, square
	jmp draw_verify
B1:	mov eax, 0
	lea esi, piece4
	jmp draw_verify
A1:	mov eax, 4
	lea esi, piece4
	jmp draw_verify
M1:	mov eax, rotor
	sub eax,4
	lea esi, piece1
	jmp draw_verify
L1:	mov eax, rotor
	lea esi, piece1
	jmp draw_verify
U1:	mov eax, rotor
	sub eax,4
	lea esi, piece2
	jmp draw_verify
T1:	mov eax, rotor
	lea esi, piece2
	jmp draw_verify
J1:	mov eax, rotor
	sub eax,4
	lea esi, piece3
	jmp draw_verify
I1:	mov eax, rotor
	lea esi, piece3
	jmp draw_verify
S1:	mov eax, rotor
	sub eax,4
	lea esi, piece5
	jmp draw_verify
R1:	mov eax, rotor
	lea esi, piece5
	jmp draw_verify
Z1:	mov eax, rotor
	sub eax,4
	lea esi, piece6
	jmp draw_verify
Y1:	mov eax, rotor
	lea esi, piece6
	jmp draw_verify
D1:	mov eax, rotor
	sub eax,4
	lea esi, piece7
	jmp draw_verify
C1:	mov eax, rotor
	lea esi, piece7
	jmp draw_verify
	
draw_verify:
	mov ebx, piece_width
	mul ebx
	mov ebx, piece_height
	mul ebx
	add esi, eax
	mov ecx, piece_height
bucla_verify_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, piece_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, piece_width
	
bucla_verify_coloane:

	cmp dword ptr [esi],0h
	je verify_pixel_next
	cmp dword ptr [esi],0000000h
	jne verify_pixel_alb
	
	jmp verify_pixel_next
verify_pixel_alb:
	cmp dword ptr [edi],0h
	je verify_pixel_next
	pop ecx
	mov [valid],0
	jmp ending
verify_pixel_next:
	add esi,4
	add edi, 4
	loop bucla_verify_coloane
	pop ecx
	loop bucla_verify_linii
ending:
	popa
	mov esp, ebp
	pop ebp
	ret
verify endp


verify_macro macro verify_symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push verify_symbol
	call verify
	add esp, 16
endm
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255 																																			
	push area
	call memset
	add esp, 12
initializez:
	mov [symbol],'L'
	mov [rotor],4
	mov [valid],1
	mov [dificultate],3
	mov [score],0
	mov [game_over],0
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	mov ecx,eax
	mov eax, area
	fort:
		mov dword ptr [eax], 0C0C0C0h					;culoare fundal
		add eax, 4
	loop fort
;negru
	mov eax, area
	mov ebx, area
	add eax, area_width
	add ebx, area_width
	add ebx, area_width
	add ebx, area_width
	mov edx,area_width
	shl edx, 2	
	mov ecx,area_height
	sub ecx,32
	asdf:
		lop:
			mov dword ptr [eax], 000000h
			add eax, 4
			cmp ebx,eax
		jg lop
		shr edx, 1
		add eax, edx
		shl edx, 1
		add ebx, edx
	loop asdf

	jmp final_draw
	
evt_click:
	cmp game_over,0
	jne initializez
	
	make_piece_macro 'X', area, coloana, linie
	
	mov eax,[ebp+arg2];x
	cmp eax, 160
	jle stanga
	cmp eax, 480
	jge dreapta	
	jmp rotate
stanga:
	mov [valid],1
	mov eax, coloana
    sub eax, 32	
	verify_macro symbol, area, eax, linie
	cmp valid,1
	je nextstanga
	make_piece_macro symbol, area, coloana, linie
	cmp symbol,'L'
	je Lstanga
	cmp symbol,'O'
	je Ostanga
	cmp symbol,'T'
	je Tstanga
	cmp symbol,'R'
	je Rstanga
	cmp symbol,'Y'
	je Ystanga
	cmp symbol,'A'
	je Astanga
	cmp symbol,'C'
	je Cstanga
	jmp Istanga
Lstanga:
	mov [symbol],'O'
	jmp Fstanga
Ostanga:	
	mov [symbol],'T'
	jmp Fstanga
Tstanga:	
	mov [symbol],'A'
	jmp Fstanga
Astanga:	
	mov [symbol],'R'
	jmp Fstanga
Rstanga:	
	mov [symbol],'Y'
	jmp Fstanga
Ystanga:	
	mov [symbol],'C'
	jmp Fstanga
Cstanga:	
	mov [symbol],'I'
	jmp Fstanga
Istanga:	
	mov [symbol],'L'
	jmp Fstanga
Fstanga:	
	mov [linie],0
	mov [coloana],256
	mov [rotor],4
	mov [valid],1
	jmp final_draw
nextstanga:	
	push ecx
	mov ecx, coloana
    sub ecx, 32	
	mov [coloana], ecx
	jmp make1
dreapta:
	mov [valid],1
	mov eax, coloana
	add eax, 32	
	verify_macro symbol, area, eax, linie
	cmp valid,1
	je nextdreapta
	make_piece_macro symbol, area, coloana, linie
	cmp symbol,'L'
	je Ldreapta
	cmp symbol,'O'
	je Odreapta
	cmp symbol,'T'
	je Tdreapta
	cmp symbol,'R'
	je Rdreapta
	cmp symbol,'Y'
	je Ydreapta
	cmp symbol,'A'
	je Adreapta
	cmp symbol,'C'
	je Cdreapta
	jmp Idreapta
Ldreapta: 
	mov [symbol],'O'
	jmp Fdreapta
Odreapta:	
	mov [symbol],'T'
	jmp Fdreapta
Tdreapta:	
	mov [symbol],'A'
	jmp Fdreapta
Adreapta:	
	mov [symbol],'R'
	jmp Fdreapta
Rdreapta:	
	mov [symbol],'Y'
	jmp Fdreapta
Ydreapta:	
	mov [symbol],'C'
	jmp Fdreapta
Cdreapta:	
	mov [symbol],'I'
	jmp Fdreapta
Idreapta:	
	mov [symbol],'L'
	jmp Fdreapta
Fdreapta:	
	mov [linie],0
	mov [coloana],256
	mov [rotor],4
	mov [valid],1
	jmp final_draw
nextdreapta:	
	push ecx
	mov ecx, coloana
    add ecx, 32	
	mov [coloana], ecx
	jmp make1
rotate:
	mov [valid],1
	mov eax, rotor
	add eax, 8
	cmp eax,28
	jng rot_v
	mov eax,4
rot_v:
	push [rotor]
	mov [rotor],eax
	verify_macro symbol, area, coloana, linie
	cmp valid,1
	je nextrotate
	pop [rotor]
	make_piece_macro symbol, area, coloana, linie
	cmp symbol,'L'
	je Lrotare
	cmp symbol,'O'
	je Orotare
	cmp symbol,'T'
	je Trotare
	cmp symbol,'R'
	je Rrotare
	cmp symbol,'Y'
	je Yrotare
	cmp symbol,'A'
	je Arotare
	cmp symbol,'C'
	je Crotare
	jmp Irotare
Lrotare:
	mov [symbol],'O'
	jmp Frotare
Orotare:	
	mov [symbol],'T'
	jmp Frotare
Trotare:	
	mov [symbol],'A'
	jmp Frotare
Arotare:	
	mov [symbol],'R'
	jmp Frotare
Rrotare:	
	mov [symbol],'Y'
	jmp Frotare
Yrotare:	
	mov [symbol],'C'
	jmp Frotare
Crotare:	
	mov [symbol],'I'
	jmp Frotare
Irotare:	
	mov [symbol],'L'
	jmp Frotare
Frotare:	
	mov [linie],0
	mov [coloana],256
	mov [rotor],4
	mov [valid],1
	jmp final_draw
nextrotate:	
	pop [rotor]
	push ecx 
	mov ecx, rotor
	add ecx, 8
	cmp ecx,28
	jng rot
	mov ecx,4
rot:
	mov [rotor],ecx
	
make1:
	pop ecx
	make_piece_macro symbol, area, coloana, linie
evt_timer:
	cmp game_over,0
	jne over
	
	mov eax, area_height
	sub eax, 34
	mov ebx, area_width
	mul ebx
	shl eax,2
	add eax,area
	mov ecx,17
loop_rand:
	push ecx
	mov ecx,area_width
	mov edx,0
	rand:
		cmp dword ptr [eax],0h
		jne nxt
		inc edx
		nxt:
		add eax,4
		loop rand
	cmp edx,20
	jg net
		pop ecx
		jmp delete_row
	net:
	mov ecx,area_width
	shl ecx,2
	sub eax,ecx
	shl ecx, 5
	sub eax,ecx
	pop ecx
	loop loop_rand
	
	jmp normal
delete_row:
	
	
	; mov ecx,area_width
	; shl ecx,2
	; sub eax,ecx
	
	mov ebx, area_width
	shl ebx,2
	shl ebx,5
	
	;sub eax,ebx
	
	mov ecx,eax
	sub ecx, area
	
	sub ecx,ebx
	shr ecx,2
loop_delete:
	push ecx
	mov ecx,eax
	sub ecx,ebx
	mov edx, dword ptr [ecx]	
	mov dword ptr [eax],edx
	sub eax,4
	pop ecx
	loop loop_delete
	
	; mov eax,linie
	; add eax,32
	; mov [linie],eax
	
	mov eax, score
	add eax,10
	mov [score], eax
	
	cmp score,30
	jne urm
	mov [dificultate],2
	jmp urm2
urm:
	cmp score,50
	jne urm1
	mov [dificultate],1
	jmp urm2
urm1:
	cmp score,70
	jne urm2
	mov [dificultate],0
urm2:
	jmp deleted
normal:
	mov eax,615
	mov ebx,area_width
	mul ebx
	shl eax,2
	mov ebx,area
	add eax, area
	mov ecx,20
del:
	push ecx
	mov ecx,area_width
	de1:
		mov dword ptr [eax],0C0C0C0h
		add eax,4
		loop de1
	POP ecx
	loop del
	make_text_macro 'S',area,5,615
	make_text_macro 'C',area,15,615
	make_text_macro 'O',area,25,615
	make_text_macro 'R',area,35,615
	make_text_macro 'E',area,45,615
	mov eax, score
	mov ebx,140
	mov ecx,9
scor:
	push ecx
	mov ecx,10
	mov edx,0
	div ecx
	add edx,'0'
	make_text_macro edx,area,ebx,615
	sub ebx,10
	pop ecx
	loop scor

	inc [counter]
	mov eax, dificultate
	cmp counter,eax
	jl final_draw
	mov [counter],0
	make_piece_macro 'X', area, coloana, linie
	
	mov [valid],1
	mov eax, linie
    add eax, 32	
	verify_macro symbol, area, coloana, eax
	cmp valid,1
	je next
	make_piece_macro symbol, area, coloana, linie
deleted:
	cmp symbol,'L'
	je Ltimer
	cmp symbol,'O'
	je Otimer
	cmp symbol,'T'
	je Ttimer
	cmp symbol,'R'
	je Rtimer
	cmp symbol,'Y'
	je Ytimer
	cmp symbol,'A'
	je Atimer
	cmp symbol,'C'
	je Ctimer
	jmp Itimer
Ltimer:
	mov [symbol],'O'
	jmp Ftimer
Otimer:	
	mov [symbol],'T'
	jmp Ftimer
Ttimer:	
	mov [symbol],'A'
	jmp Ftimer
Atimer:	
	mov [symbol],'R'
	jmp Ftimer
Rtimer:	
	mov [symbol],'Y'
	jmp Ftimer
Ytimer:	
	mov [symbol],'C'
	jmp Ftimer
Ctimer:	
	mov [symbol],'I'
	jmp Ftimer
Itimer:	
	mov [symbol],'L'
	jmp Ftimer
Ftimer:	

	mov [linie],0
	mov [coloana],256
	mov [rotor],4
	mov [valid],1
	verify_macro symbol, area, coloana, linie
	cmp valid,1
	je final_draw
	mov [game_over],1
next:
	push ecx
	mov ecx, linie
    add ecx, 32	
	mov [linie], ecx
	pop ecx
make:
	make_piece_macro symbol, area, coloana, linie
	
over:
	cmp game_over,0
	je final_draw
	mov eax,area_height
	mov ecx,area_width
	mul ecx
	mov ecx,eax
	mov eax, area
over_loop:
	mov dword ptr [eax],0ff0000h
	add eax,4
	loop over_loop
	
	make_text_macro 'S',area,220,310
	make_text_macro 'S',area,260,310
	make_text_macro 'Y',area,200,280
	make_text_macro 'O',area,210,280
	make_text_macro 'E',area,260,280
	make_text_macro 'J',area,240,310
	make_text_macro 'U',area,250,310
	make_text_macro 'T',area,140,310
	make_text_macro 'E',area,150,310
	make_text_macro 'S',area,190,310
	make_text_macro 'I',area,210,310
	make_text_macro 'T',area,270,310
	make_text_macro 'N',area,350,340
	make_text_macro 'E',area,370,310
	make_text_macro 'I',area,390,310
	make_text_macro 'T',area,400,310
	make_text_macro 'L',area,290,310
	make_text_macro 'I',area,300,310
	make_text_macro 'K',area,310,310
	make_text_macro 'E',area,320,310
	make_text_macro 'L',area,340,310
	make_text_macro 'U',area,220,280
	make_text_macro 'S',area,240,280
	make_text_macro 'E',area,250,280
	make_text_macro 'I',area,350,310
	make_text_macro 'T',area,160,310
	make_text_macro 'E',area,420,310
	make_text_macro 'L',area,430,310
	make_text_macro 'F',area,440,310
	make_text_macro 'W',area,440,340
	make_text_macro 'M',area,320,340
	make_text_macro 'R',area,170,310
	make_text_macro 'I',area,180,310
	make_text_macro 'F',area,360,310
	make_text_macro 'O',area,290,340
	make_text_macro 'T',area,300,340
	make_text_macro 'A',area,340,340
	make_text_macro 'O',area,390,340
	make_text_macro 'B',area,410,340
	make_text_macro 'S',area,410,310
	make_text_macro 'E',area,330,340
	make_text_macro 'O',area,450,340
	make_text_macro 'N',area,460,340
	make_text_macro 'I',area,220,340
	make_text_macro 'T',area,230,340
	make_text_macro 'I',area,250,340
	make_text_macro 'S',area,260,340
	make_text_macro 'N',area,280,340
	make_text_macro 'T',area,360,340
	make_text_macro 'T',area,380,340
	make_text_macro 'E',area,420,340
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
