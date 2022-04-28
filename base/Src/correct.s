	.text
	.syntax unified
	.global int2float
	.global addfloat

@ conversion d'un entier en flottant
int2float:
	push {r4}

zero:				@ si = 0 retourne 0
	cmp r0, #0
	beq retour

signe:				@ test du signe
	cmp r0, #0
	itte lt
	movlt r4, #0x80000000	@ r4 stocke le signe
	rsblt r0, r0, #0		@ on prend l'opposé du nombre
	movge r4, #0

exposant:
	@ on commence par l'exposant, on cherche dans le du nombre (r0)
	@ la plus grande puissance de 2 non nul -> donnera l'exposant (dans r2)
	@ recherche du premier bit non nul en partant du poids fort
	@ note : instruction CLZ effectue la même chose en une instruction
	mov r1, #0x40000000		@ constante avec le 1 sur le bit 30 reste à 0
	mov r2, #30				@ plus grand exposant possible (bit 30 à 1)
while1:
	tst r0, r1
	ittt eq
	lsreq r1, r1, #1
	subeq r2, r2, #1
	beq while1

	@ suppression du 1 implicite
	bic r0, r0, r1

	@décalage pour aligner le nombre : 2 cas
	@ si nombre sup à 2^23 il faut décaler à droite de exp-23, il y a alors
	@ perte des bits de poids faible
	@ si nombre inférieur à 2exp 23 il faut décaler à gauche de 23-exp
	cmp r2, #23
	ittee ge
	subge r3, r2, #23
	lsrge r0, r0, r3
	rsblt r3, r2, #23
	lsllt r0, r0, r3

	@ r0 contient la mantisse

	@ l'exposant est formaté en 127 exessif et placé sur les bits 23 à 30
	add r2, r2, #127
	lsl r2, r2, #23

	@ le mot est formé avec signe, exposant, mantisse
	orr r0, r0, r2
	orr r0, r0, r4

retour:
	pop {r4}
	bx lr


@ addtion logicielle de 2 flottant float0 et float1 (uniquement normalisés)
@ alignement des exposant puis addition des mantisses dénormalisées



addfloat:
		push {r4-r8,lr}

		@ un test des nombre flottant entrant pourrait être fait :
		@ 0
		@ NAN
		@ dénormalisés

extract_exp_mantisse:
	@ les exposants sont placé dans r4, r5 (en format 127 excessif)
	@ les mantisses sont placées dans r6 et r7 format entier signé
	lsrs r4, r0, #23			@ extait l'exposant de float0 (aligne à droite)
	ands r4, r4, #0xFF			@ suprimme signe du flottant
	lsrs r5, r1, #23			@ extait l'exposant de float1 alignement à doite
	ands r5, r5, #0xFF			@ suprimme signe du flottant

	bics r6, r0, #0xFF000000	@ extrait la mantisse de float0
	orrs r6, r6, #0x800000		@ ajoute le 1 implicite, absorbe le bit pd faible exp
	tst r0, #0x80000000			@ test du signe de float0
	it ne
	rsbne r6, r6, #0			@ transformation en entier signe

	bics r7, r1, #0xFF000000	@ extrait la mantisse de float1
	orrs r7, r7, #0x800000		@ ajoute le 1, absorbe le bit pd faible exp
	tst r1, #0x80000000			@ test du signe de float1
	it ne
	rsbne r7, r7, #0			@ transformation en entier signe


compare_exp:
	subs r2, r4, r5		@substract exp (non signés)
	bhs r4_sup_r5
	blo r4_inf_r5

r4_sup_r5:
	@test de l'ecart d'exposant  si > 23, r1 est trop petit pour l'addition
	cmp r2, #23
	bgt ret
	@ sinon on cale la mantisse de r1 et on additionne
	asrs r7, r7, r2		@ decalage à droite arithmétique de l'écart d'exposant
	adds r6, r6, r7		@ addition des mantisse
	@ il faut maintenant tester le résultat de la mantisse :
	@	si 0 renvoyer 0 sinon tester
	@   signe
	@ 	mantisse pour aligner correctement le 1 de poids fort
	@

	@ test du 0
	cmp r6, #0
	it eq			@ si égal à 0 le nombre est 0, en flottant c'est 0
	moveq r0, 0
	beq ret

	@ une autre solution est de faire appel à la fonction conversion entier
	@ vers flottant déjà écrit, En effet la mantisse correspond à un nombre
	@ entier * 2^-23
	@ le flottant retourné devra donc être multiplié par 2^-23 ce
	@ qui correspond à décrémenter l'exposant de 23.
	@ ensuite cet exposant sera additionné à le l'exposant de float0
	movs r0, r6
	bl int2float
	@ extraction du signe
	ands r8, r0, #0x80000000
	@ extraction de la mantisse, en 2 temps en raison de l'argument imm.
	bics r2, r0, 0xFF000000
	bics r2, r2, 0x00800000
	orr r8, r8, r2				@ mantisse rangée dans résultat
	@ extraction de l'exposant et ajustement
	lsrs r1, r0, #23			@ extait l'exposant de r0 (aligne à droite)
	ands r1, r1, #0xFF			@ suprimme signe du flottant r0
	subs r1, r1, #23			@ soustrait 23 à l'exposant retourné
	subs r1, r1, #127			@ converti en signé l'exposant
	adds r1, r4, r1				@ addtition avec exposant de float0
	lsls r1, r1, #23			@ on cale l'exposant
	orr r8, r8, r1				@ on le place dans le résultat
	mov r0, r8
	b ret

r4_inf_r5:
	@ l'écart d'exposant est inversé
	rsbs r2, r2, #0
	@test de l'ecart d'exposant  si > 32, r1 est trop petit pour l'addition
	cmp r2, #23
	mov r0, r1		@ résultat = float1
	bgt ret
	@ sinon on cale la mantisse de r1 et on additionne
	asrs r6, r6, r2		@ decalage à droite arithmétique de l'écart d'exposant
	adds r7, r7, r6		@ addition des mantisse
	@ il faut maintenant tester le résultat de la mantisse :
	@	signe
	@ 	mantisse pour aligner correctement le 1 de poids fort
	@
	@ une autre solution est de faire appel à la fonction conversion entier
	@ vers flottant déjà écrit et récupérer la valeur flottante de la mantisse
	@ il suffit alors d'additionner les exposants
	movs r0, r7
	bl int2float
	@ extraction du signe
	ands r8, r0, #0x80000000
	@ extraction de la mantisse, en 2 temps en raison de l'argument imm.
	bics r2, r0, 0xFF000000
	bics r2, r2, 0x800000
	orr r8, r8, r2				@ mantisse rangée dans résultat
	@ extraction de l'exposant et ajustement
	lsrs r1, r0, #23			@ extait l'exposant de r0 (aligne à droite)
	ands r1, r1, #0xFF			@ suprimme signe du flottant r0
	subs r1, r1, #23			@ soustrait 23 à l'exposant retourné
	subs r1, r1, #127			@ converti en signé l'exposant
	add r1, r5, r1				@ addtition avec exposant de float0
	lsls r1, r1, #23			@ on cale l'exposant
	orr r8, r8, r1				@ on le place dans le résultat
	mov r0, r8


ret:
	pop {r4-r8,lr}
	bx lr


