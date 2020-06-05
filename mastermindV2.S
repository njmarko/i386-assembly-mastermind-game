#autor: Marko Njegomir sw-38-2018	
.section .data
crveni: .long 0
zuti: .long 0
sve_kombinacije: .fill 1296,4,0
preostale_kombinacije: .fill 1296,4,0
broj_preostalih: .long 1296
trazena_kombinacija: .long 0
delioc: .long 6
znakovi: .ascii "\n\033[1;32mSKOCKO[1] TREF[2] PIK[3] HERC[4] KARO[5] ZVEZDA[6] (ENTER za izlazak)\033[0m\n\0"
znakovi_len = .-znakovi
reset: .ascii "\033[0m\n"
green: .ascii "\033[1;32m"
unesena_komb: .fill 100,1,0
pokusaj: .long 0
pogodjena_kombinacija: .long 0
multi_line_display: .ascii "\n|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|   |%1s|%1s|%1s|%1s|\n|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|   |%1s|%1s|%1s|%1s|\n|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|   |%1s|%1s|%1s|%1s|\n|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|   |%1s|%1s|%1s|%1s|\n|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|   |%1s|%1s|%1s|%1s|\n|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|   |%1s|%1s|%1s|%1s|\n\0"
one_line_display: .ascii "|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|   |%1s|%1s|%1s|%1s|\n\0"
brojac_stack: .long 48
znak_skocko: .ascii "SKOCKO\0"
znak_tref: .ascii "TREF\0"
znak_pik: .ascii "PIK\0"
znak_herc: .ascii "HERC\0"
znak_karo: .ascii "KARO\0"
znak_zvezda: .ascii "ZVEZDA\033[0m\0"
znak_crveni: .ascii "\033[1;31mO\033[0m\0"
znak_zuti: .ascii "\033[1;33mO\033[0m\0"
znak_prazan: .ascii "\0"
poruka_prazan: .ascii "Odustali ste od igre. \nDovidjenja!\n\n\0"
poruka_prazan_len = .-poruka_prazan
poruka_pogresan_input: .ascii "Pogresno unesena kombinacija! (unesite 4 broja bez razmaka, npr. 1122)\n\0"
poruka_pogresan_input_len = .-poruka_pogresan_input
poruka_pogodjena_ispis: .ascii "\nCESITITAMO! Pronasli ste trazenu kombinaciju!\n\n\0"
poruka_pogodjena_len = .-poruka_pogodjena_ispis
poruka_promasena_ispis: .ascii "Nazalost niste uspeli da pronadjete trazenu kombinaciju.\nTrazena kombinacija je:\n|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\033[1;34m%-6s\033[0m|\n\n\0"
poruka_promasena_len = .-poruka_promasena_ispis
.section .text
.globl main

#popunjava niz sa svim kombinacijama
#koristi: %eax, %ebx, %ecx, %edx, %esi, %edi
napravi_kombinacije:
	xorl %eax, %eax
	xorl %ebx, %ebx
	xorl %ecx, %ecx	
	xorl %edx, %edx
	movb $0b00000100, %bh #maska za brojanje do 6
	movb $0b10000000, %ah #pocetna maska
	movb $1, %cl #broj za shiftovanje
	movb %ah, %al 
	movb %ah, %bl
	movb %ah, %ch
	movb %ah, %dl
	leal sve_kombinacije, %esi
	xorl %edi, %edi
komb_petlja1:
	cmpb %bh, %al
	jb komb_povratak
	movb %ah, %bl
komb_petlja2:
	cmpb %bh, %bl
	jb komb_brojac1
	movb %ah, %ch
komb_petlja3:
	cmpb %bh, %ch
	jb komb_brojac2
	movb %ah, %dl
komb_petlja4:
	cmpb %bh, %dl
	jb komb_brojac3
	movb %al, (%esi,%edi,4)
	movb %bl, 1(%esi,%edi,4)
	movb %ch, 2(%esi,%edi,4)
	movb %dl, 3(%esi,%edi,4)
	incl %edi
	shrb %cl, %dl
	jmp komb_petlja4
komb_brojac3:
	shrb %cl, %ch
	jmp komb_petlja3
komb_brojac2:
	shrb %cl, %bl
	jmp komb_petlja2
komb_brojac1:
	shrb %cl, %al
	jmp komb_petlja1
komb_povratak:
	ret

#racuna koliko ima znakova na tacnim mestima(crvenih) i koliko znakova nije na pravom mestu
#koristi: %eax(prva komb), %ebx(druga komb), %ecx, %edx, %esi(ret:crveni), %edi(ret:zuti)
histogram:
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx
	xorl %esi, %esi
	movl %ebx, %edx
	andl %eax, %edx
	movl %edx, %ecx
	jz proveri_zute
petlja:
	cmpb $0, %dl
	jne brojac
	cmpl $0, %edx
	je proveri_zute
	shrl $8, %edx
	jmp petlja
brojac:
	shrl $8, %edx
	incl %esi
	jmp petlja
proveri_zute:
	xorl %ecx, %ebx
	xorl %ecx, %eax
	xorl %edi, %edi
petlja2:
	cmpb $0, %bl
	je brojac2
	movl $4, %edx
petlja3:
	decl %edx
	js brojac2
	testb %bl, %al
	jz brojac3
	xorb %bl, %al
	incl %edi
	jmp brojac2
brojac3:
	rorl $8, %eax
	jmp petlja3
brojac2:
	shrl $8, %ebx
	jnz petlja2
povratak:
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax
	ret
#zapisuje preostale moguce kombinacije u niz preostale_kombinacije, i pamti njihov broj u %ebx
#koristi ciljanu kombinaciju u %eax, registre %ebx(trenutna kombinacija iz niza),%ecx(brojac),  %edx(broj pronadjenih kombinacija)
izracunaj_preostale_1:
	movl $0b10000000100000000100000001000000, %eax
	xorl %ebx, %ebx
	xorl %ecx, %ecx
	xorl %edx, %edx
preostali_petlja1:
	cmpl broj_preostalih, %ecx
	je preostali_povratak1
	movl sve_kombinacije(,%ecx,4), %ebx
	cmpl $0, %ebx
	je preostali_povratak1
	call histogram
	cmpl crveni, %esi
	jne preostali_brojac1
	cmpl zuti, %edi
	jne preostali_brojac1
	movl %ebx, preostale_kombinacije(,%edx,4)
	incl %edx
preostali_brojac1:
	incl %ecx
	jmp preostali_petlja1
preostali_povratak1:
	movl %edx, broj_preostalih
	ret

#zapisuje preostale moguce kombinacije u niz preostale_kombinacije, i pamti njihov broj u %ebx
#koristi ciljanu kombinaciju u %eax, registre %ebx(trenutna kombinacija iz niza),%ecx(brojac),  %edx(broj pronadjenih kombinacija)
izracunaj_preostale:
	movl $0b10000000100000000100000001000000, %eax
	xorl %ebx, %ebx
	xorl %ecx, %ecx
	xorl %edx, %edx
preostali_petlja:
	cmpl broj_preostalih, %ecx
	je preostali_povratak
	movl preostale_kombinacije(,%ecx,4), %ebx #jedina razlika
	cmpl $0, %ebx
	je preostali_povratak
	call histogram
	cmpl crveni, %esi
	jne preostali_brojac
	cmpl zuti, %edi
	jne preostali_brojac
	movl %ebx, preostale_kombinacije(,%edx,4)
	incl %edx
preostali_brojac:
	incl %ecx
	jmp preostali_petlja
preostali_povratak:
	movl %edx, broj_preostalih
	ret

generisi_trazenu_kombinaciju:
	pushl $0
	call time #time(null)
	addl $4, %esp
	pushl %eax
	call srand #srand(time(null)) postavlja seed koji ce rand() da koristi
	addl $4, %esp
	movl $0b10000000100000001000000010000000, %ebx
	movl $5, %edi
	movl $6, %esi
petlja_random:
	decl %edi
	jz povratak_random
	call rand #generise pseudorandom broj
	xorl %edx, %edx
	divl delioc #ostatak u %edx
	movb %dl, %cl
	rorb %cl,%bl
	rorl $8, %ebx
	jmp petlja_random
povratak_random:
	movl %ebx, trazena_kombinacija
	ret

pp_pronadji_sledeceg:
	cmpb $' ', (%edx)
	jne povratak_pronadji_sledeceg
	incl %edx
	jmp pp_pronadji_sledeceg
povratak_pronadji_sledeceg:ret

prazan_string: #kod unosa praznog stringa se igra prekida
	movl $4, %eax
	movl $1, %ebx
	leal poruka_prazan, %ecx
	movl $poruka_prazan_len, %edx
	int $0x80
	jmp kraj
pogresan_input:
	movl $4, %eax
	movl $1, %ebx
	leal poruka_pogresan_input, %ecx
	movl $poruka_pogresan_input_len, %edx
	int $0x80
	jmp input_kombinacija
	
input_kombinacija:
	movl $4, %eax
	movl $1, %ebx
	leal znakovi, %ecx
	movl $znakovi_len, %edx
	int $0x80

	movl $3, %eax
	movl $0, %ebx
	leal unesena_komb, %ecx
	movl $100, %edx
	int $0x80

	cmpl $1, %eax
	je prazan_string #prekid igre
	leal unesena_komb, %edx
	call pp_pronadji_sledeceg
	xorl %ebx, %ebx
petlja_input:
	cmpl $4, %ebx
	je povratak_input
	shll $8, pokusaj
	movb (%edx,%ebx,1), %cl
	cmpb $'1', %cl
	jb pogresan_input
	cmpb $'6', %cl
	ja pogresan_input
	subb $'1', %cl #oduzimam 1 posto se u slucaju jedinice ne rotira maska
	movb $0b10000000, %ah #pocetna maska
	rorb %cl, %ah
	xorb %ah, pokusaj
brojac_input:
	incl %ebx
	jmp petlja_input
povratak_input:	ret


main:
	movl $znak_prazan, %eax #nula za stack
	movl brojac_stack, %ebx #brojac za stack br.48
pripremi_stack: #gura 48 praznih stringova na stack zbog nacina koriscenja printf funkcije
	pushl %eax
	decl %ebx
	jnz pripremi_stack
	pushl $multi_line_display
	call printf
	movl $36, brojac_stack #postavlja se vrednost brojaca stack pomnozena sa 4 (velicina long)

	call napravi_kombinacije
	call generisi_trazenu_kombinaciju
#-------celina za unos i racunanje
	call input_kombinacija
	movl pokusaj, %eax
	movl trazena_kombinacija, %ebx
	call histogram
	movl %esi, crveni
	movl %edi, zuti
	call izracunaj_preostale_1
	cmpl $4, crveni
	jne ispis1
	movl $1, pogodjena_kombinacija

#-------celina za ispis
ispis1:
	addl brojac_stack, %esp #vracanje stack pointera na prvi sledeci koji nije prazan
	#racunanje praznih znakova
	movl $4, %eax
	subl zuti, %eax
	subl crveni, %eax
	movl $4, %ebx
	mull %ebx
	subl %eax, %esp #ovako se ostavljaju prazna mesta na stacku za prikaz praznih mesta
petlja_zuti1:
	decl zuti
	js petlja_crveni1
	pushl $znak_zuti
	jmp petlja_zuti1
petlja_crveni1:
	decl crveni
	js kombinacija1
	pushl $znak_crveni
	jmp petlja_crveni1
kombinacija1:
	movl $4, %eax #brojac
petlja_komb1:
	decl %eax
	js druga_kombinacija
	cmpb $0b01000000, pokusaj
	ja upisi_skocko1
	je upisi_tref1
	cmpb $0b00010000, pokusaj
	ja upisi_pik1
	je upisi_herc1
	cmpb $0b00000100, pokusaj
	ja upisi_karo1
upisi_zvezda1:
	pushl $znak_zvezda
	jmp brojac_petlja_komb1
upisi_skocko1:
	pushl $znak_skocko
	jmp brojac_petlja_komb1
upisi_tref1:
	pushl $znak_tref
	jmp brojac_petlja_komb1
upisi_pik1:
	pushl $znak_pik
	jmp brojac_petlja_komb1
upisi_herc1:
	pushl $znak_herc
	jmp brojac_petlja_komb1
upisi_karo1:
	pushl $znak_karo
brojac_petlja_komb1:
	shrl $8, pokusaj
	jmp petlja_komb1

druga_kombinacija:
	subl $32, brojac_stack #posto je pushovano 8 argumenata
	subl brojac_stack, %esp #vraca se stack pointer na vrh stack-a
	call printf
	cmpl $1, pogodjena_kombinacija
	je poruka_pogodjena
	
#-------celina za unos i racunanje 2
	call input_kombinacija
	movl pokusaj, %eax
	movl trazena_kombinacija, %ebx
	call histogram
	movl %esi, crveni
	movl %edi, zuti
	call izracunaj_preostale
	cmpl $4, crveni
	jne ispis2
	movl $1, pogodjena_kombinacija

#-------celina za ispis 2
ispis2:
	movl $68, brojac_stack #drugi red pocinje odatle
	addl brojac_stack, %esp #vracanje stack pointera na prvi sledeci koji nije prazan
	#racunanje praznih znakova
	movl $4, %eax
	subl zuti, %eax
	subl crveni, %eax
	movl $4, %ebx
	mull %ebx
	subl %eax, %esp #ovako se ostavljaju prazna mesta na stacku za prikaz praznih mesta
petlja_zuti2:
	decl zuti
	js petlja_crveni2
	pushl $znak_zuti
	jmp petlja_zuti2
petlja_crveni2:
	decl crveni
	js kombinacija2
	pushl $znak_crveni
	jmp petlja_crveni2
kombinacija2:
	movl $4, %eax #brojac
petlja_komb2:
	decl %eax
	js treca_kombinacija
	cmpb $0b01000000, pokusaj
	ja upisi_skocko2
	je upisi_tref2
	cmpb $0b00010000, pokusaj
	ja upisi_pik2
	je upisi_herc2
	cmpb $0b00000100, pokusaj
	ja upisi_karo2
upisi_zvezda2:
	pushl $znak_zvezda
	jmp brojac_petlja_komb2
upisi_skocko2:
	pushl $znak_skocko
	jmp brojac_petlja_komb2
upisi_tref2:
	pushl $znak_tref
	jmp brojac_petlja_komb2
upisi_pik2:
	pushl $znak_pik
	jmp brojac_petlja_komb2
upisi_herc2:
	pushl $znak_herc
	jmp brojac_petlja_komb2
upisi_karo2:
	pushl $znak_karo
brojac_petlja_komb2:
	shrl $8, pokusaj
	jmp petlja_komb2

treca_kombinacija:
	subl $32, brojac_stack #posto je pushovano 8 argumenata
	subl brojac_stack, %esp #vraca se stack pointer na vrh stack-a
	call printf
	cmpl $1, pogodjena_kombinacija
	je poruka_pogodjena

#-------celina za unos i racunanje 3
	call input_kombinacija
	movl pokusaj, %eax
	movl trazena_kombinacija, %ebx
	call histogram
	movl %esi, crveni
	movl %edi, zuti
	call izracunaj_preostale
	cmpl $4, crveni
	jne ispis3
	movl $1, pogodjena_kombinacija

#-------celina za ispis 3
ispis3:
	movl $100, brojac_stack #treci red pocinje odatle (u brojac_stack je ostala vrednost 4)
	addl brojac_stack, %esp #vracanje stack pointera na prvi sledeci koji nije prazan
	#racunanje praznih znakova
	movl $4, %eax
	subl zuti, %eax
	subl crveni, %eax
	movl $4, %ebx
	mull %ebx
	subl %eax, %esp #ovako se ostavljaju prazna mesta na stacku za prikaz praznih mesta
petlja_zuti3:
	decl zuti
	js petlja_crveni3
	pushl $znak_zuti
	jmp petlja_zuti3
petlja_crveni3:
	decl crveni
	js kombinacija3
	pushl $znak_crveni
	jmp petlja_crveni3
kombinacija3:
	movl $4, %eax #brojac
petlja_komb3:
	decl %eax
	js cetvrta_kombinacija
	cmpb $0b01000000, pokusaj
	ja upisi_skocko3
	je upisi_tref3
	cmpb $0b00010000, pokusaj
	ja upisi_pik3
	je upisi_herc3
	cmpb $0b00000100, pokusaj
	ja upisi_karo3
upisi_zvezda3:
	pushl $znak_zvezda
	jmp brojac_petlja_komb3
upisi_skocko3:
	pushl $znak_skocko
	jmp brojac_petlja_komb3
upisi_tref3:
	pushl $znak_tref
	jmp brojac_petlja_komb3
upisi_pik3:
	pushl $znak_pik
	jmp brojac_petlja_komb3
upisi_herc3:
	pushl $znak_herc
	jmp brojac_petlja_komb3
upisi_karo3:
	pushl $znak_karo
brojac_petlja_komb3:
	shrl $8, pokusaj
	jmp petlja_komb3

cetvrta_kombinacija:
	subl $32, brojac_stack #posto je pushovano 8 argumenata
	subl brojac_stack, %esp #vraca se stack pointer na vrh stack-a
	call printf
	cmpl $1, pogodjena_kombinacija
	je poruka_pogodjena
#-------celina za unos i racunanje 4
	call input_kombinacija
	movl pokusaj, %eax
	movl trazena_kombinacija, %ebx
	call histogram
	movl %esi, crveni
	movl %edi, zuti
	call izracunaj_preostale
	cmpl $4, crveni
	jne ispis4
	movl $1, pogodjena_kombinacija

#-------celina za ispis 4
ispis4:
	movl $132, brojac_stack #treci red pocinje odatle (u brojac_stack je ostala vrednost 4)
	addl brojac_stack, %esp #vracanje stack pointera na prvi sledeci koji nije prazan
	#racunanje praznih znakova
	movl $4, %eax
	subl zuti, %eax
	subl crveni, %eax
	movl $4, %ebx
	mull %ebx
	subl %eax, %esp #ovako se ostavljaju prazna mesta na stacku za prikaz praznih mesta
petlja_zuti4:
	decl zuti
	js petlja_crveni4
	pushl $znak_zuti
	jmp petlja_zuti4
petlja_crveni4:
	decl crveni
	js kombinacija4
	pushl $znak_crveni
	jmp petlja_crveni4
kombinacija4:
	movl $4, %eax #brojac
petlja_komb4:
	decl %eax
	js peta_kombinacija
	cmpb $0b01000000, pokusaj
	ja upisi_skocko4
	je upisi_tref4
	cmpb $0b00010000, pokusaj
	ja upisi_pik4
	je upisi_herc4
	cmpb $0b00000100, pokusaj
	ja upisi_karo4
upisi_zvezda4:
	pushl $znak_zvezda
	jmp brojac_petlja_komb4
upisi_skocko4:
	pushl $znak_skocko
	jmp brojac_petlja_komb4
upisi_tref4:
	pushl $znak_tref
	jmp brojac_petlja_komb4
upisi_pik4:
	pushl $znak_pik
	jmp brojac_petlja_komb4
upisi_herc4:
	pushl $znak_herc
	jmp brojac_petlja_komb4
upisi_karo4:
	pushl $znak_karo
brojac_petlja_komb4:
	shrl $8, pokusaj
	jmp petlja_komb4

peta_kombinacija:
	subl $32, brojac_stack #posto je pushovano 8 argumenata
	subl brojac_stack, %esp #vraca se stack pointer na vrh stack-a
	call printf
	cmpl $1, pogodjena_kombinacija
	je poruka_pogodjena
#-------celina za unos i racunanje 5
	call input_kombinacija
	movl pokusaj, %eax
	movl trazena_kombinacija, %ebx
	call histogram
	movl %esi, crveni
	movl %edi, zuti
	call izracunaj_preostale
	cmpl $4, crveni
	jne ispis5
	movl $1, pogodjena_kombinacija

#-------celina za ispis 5
ispis5:
	movl $164, brojac_stack #treci red pocinje odatle (u brojac_stack je ostala vrednost 4)
	addl brojac_stack, %esp #vracanje stack pointera na prvi sledeci koji nije prazan
	#racunanje praznih znakova
	movl $4, %eax
	subl zuti, %eax
	subl crveni, %eax
	movl $4, %ebx
	mull %ebx
	subl %eax, %esp #ovako se ostavljaju prazna mesta na stacku za prikaz praznih mesta
petlja_zuti5:
	decl zuti
	js petlja_crveni5
	pushl $znak_zuti
	jmp petlja_zuti5
petlja_crveni5:
	decl crveni
	js kombinacija5
	pushl $znak_crveni
	jmp petlja_crveni5
kombinacija5:
	movl $4, %eax #brojac
petlja_komb5:
	decl %eax
	js sesta_kombinacija
	cmpb $0b01000000, pokusaj
	ja upisi_skocko5
	je upisi_tref5
	cmpb $0b00010000, pokusaj
	ja upisi_pik5
	je upisi_herc5
	cmpb $0b00000100, pokusaj
	ja upisi_karo5
upisi_zvezda5:
	pushl $znak_zvezda
	jmp brojac_petlja_komb5
upisi_skocko5:
	pushl $znak_skocko
	jmp brojac_petlja_komb5
upisi_tref5:
	pushl $znak_tref
	jmp brojac_petlja_komb5
upisi_pik5:
	pushl $znak_pik
	jmp brojac_petlja_komb5
upisi_herc5:
	pushl $znak_herc
	jmp brojac_petlja_komb5
upisi_karo5:
	pushl $znak_karo
brojac_petlja_komb5:
	shrl $8, pokusaj
	jmp petlja_komb5

sesta_kombinacija:
	subl $32, brojac_stack #posto je pushovano 8 argumenata
	subl brojac_stack, %esp #vraca se stack pointer na vrh stack-a
	call printf
	cmpl $1, pogodjena_kombinacija
	je poruka_pogodjena
#-------celina za unos i racunanje 6
	call input_kombinacija
	movl pokusaj, %eax
	movl trazena_kombinacija, %ebx
	call histogram
	movl %esi, crveni
	movl %edi, zuti
	call izracunaj_preostale
	cmpl $4, crveni
	jne ispis6
	movl $1, pogodjena_kombinacija

#-------celina za ispis 6
ispis6:
	movl $196, brojac_stack #treci red pocinje odatle (u brojac_stack je ostala vrednost 4)
	addl brojac_stack, %esp #vracanje stack pointera na prvi sledeci koji nije prazan
	#racunanje praznih znakova
	movl $4, %eax
	subl zuti, %eax
	subl crveni, %eax
	movl $4, %ebx
	mull %ebx
	subl %eax, %esp #ovako se ostavljaju prazna mesta na stacku za prikaz praznih mesta
petlja_zuti6:
	decl zuti
	js petlja_crveni6
	pushl $znak_zuti
	jmp petlja_zuti6
petlja_crveni6:
	decl crveni
	js kombinacija6
	pushl $znak_crveni
	jmp petlja_crveni6
kombinacija6:
	movl $4, %eax #brojac
petlja_komb6:
	decl %eax
	js finalna_kombinacija
	cmpb $0b01000000, pokusaj
	ja upisi_skocko6
	je upisi_tref6
	cmpb $0b00010000, pokusaj
	ja upisi_pik6
	je upisi_herc6
	cmpb $0b00000100, pokusaj
	ja upisi_karo6
upisi_zvezda6:
	pushl $znak_zvezda
	jmp brojac_petlja_komb6
upisi_skocko6:
	pushl $znak_skocko
	jmp brojac_petlja_komb6
upisi_tref6:
	pushl $znak_tref
	jmp brojac_petlja_komb6
upisi_pik6:
	pushl $znak_pik
	jmp brojac_petlja_komb6
upisi_herc6:
	pushl $znak_herc
	jmp brojac_petlja_komb6
upisi_karo6:
	pushl $znak_karo
brojac_petlja_komb6:
	shrl $8, pokusaj
	jmp petlja_komb6

finalna_kombinacija:
	subl $32, brojac_stack #posto je pushovano 8 argumenata
	subl brojac_stack, %esp #vraca se stack pointer na vrh stack-a
	call printf
	cmpl $1, pogodjena_kombinacija
	je poruka_pogodjena
poruka_promasena:
	movl $4, %eax #brojac
petlja_komb7:
	decl %eax
	js ispisi_pogresnu_kombinaciju
	cmpb $0b01000000, trazena_kombinacija
	ja upisi_skocko7
	je upisi_tref7
	cmpb $0b00010000, trazena_kombinacija
	ja upisi_pik7
	je upisi_herc7
	cmpb $0b00000100, trazena_kombinacija
	ja upisi_karo7
upisi_zvezda7:
	pushl $znak_zvezda
	jmp brojac_petlja_komb7
upisi_skocko7:
	pushl $znak_skocko
	jmp brojac_petlja_komb7
upisi_tref7:
	pushl $znak_tref
	jmp brojac_petlja_komb7
upisi_pik7:
	pushl $znak_pik
	jmp brojac_petlja_komb7
upisi_herc7:
	pushl $znak_herc
	jmp brojac_petlja_komb7
upisi_karo7:
	pushl $znak_karo
brojac_petlja_komb7:
	shrl $8, trazena_kombinacija
	jmp petlja_komb7
ispisi_pogresnu_kombinaciju:
	pushl $poruka_promasena_ispis
	call printf
	jmp kraj


poruka_pogodjena:
	movl $4, %eax
	movl $1, %ebx
	leal poruka_pogodjena_ispis, %ecx
	movl $poruka_pogodjena_len, %edx 
	int $0x80
	jmp kraj
	
kraj:
	movl $1, %eax
	movl $0, %ebx
	int $0x80
