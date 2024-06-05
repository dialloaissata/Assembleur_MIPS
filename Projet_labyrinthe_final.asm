.data
RetChar: .asciiz "\n"
Tableau: .asciiz "Tableau de taille: "
Aladresse: .asciiz "à l'adresse: "
Adresse: .asciiz "Adresse du premier entier du tableau: "
Place: .asciiz "Place de l'entier dans le tableau: "
Espace: .asciiz " "
Demande_Taille_laby: .asciiz "Entrez la taille du labyrinthe: "

.text
.globl __start


######################################## 2. ALGORITHME ####################################

li $v0, 4				#$v0 vaut 4 pour afficher le chaine de character	
la $a0,Demande_Taille_laby		#Affiche le text de demander la taille du labyrinthe de l'utilisateur, $a0 vaut l'adrese de chaine qui doit afficher
syscall					#system call

li $v0, 5				# $v0 vaut 5 pour read_int 
syscall 
move $a0,$v0				#aprés syscall $v0 vaut l'entier que l'utilisateur a entré, on le copie dans $a0

jal creer_labyrinthe			#en appelant la fonction,Creer du laby avec le taille N dans $a0 que l'utilisateur a demandé
jal st_creer 				#Creer du pil avec N*N taille en appelanr la fonction

li $a3, 13				#$a3 est le cellule en haut à gauche du laby, la valeur passe à la fonction cell_mettre_bit_a1 
li $a1, 4				#4 est la position du depart , on passe la valeur 13 dontle 4iemie position change de 0 a 1
jal cell_mettre_bit_a1			#change le bit de depart de 0 a 1 pour que le cellule devient le cellule courante

move $a3, $s3				#$s contient la valeur retournée de la fonction cell_mettre_bit_a1, on le copie dans $a3 pour qu'il deviens la cellule visitée
li $a1, 7				#le bit de 7ieme cellule est le bit qu'indique si une cellule est visite (vaut 1) ou non (vaut 0)
jal cell_mettre_bit_a1			#appelle la fonction en passant la valeur 7, et le contenue de $s3

move $a1, $s3				#copier le contenue de $s3 (le cellule en haut à gauche qui est courant et visité) pour empiler dans le pil
jal st_empiler				#cette fontion empile le contenue dans $a1 dans le pil


Boucle_pil_nonVide:
beqz $v0, Exit				#Tant que la pile n’est pas vide, on répéte les etape suivant sinon on sort
jal cellules_Voisines_Non_Visitees	#Rechercher les cellules voisines de la cellule courante C qui n’aient pas encore été visitées

bnez $v0, Existe_voisin_visite		# S’il y en a au moins une cellule visité, on saute à 	Existe_voisin_visite

aucun_voisin_visite:			#s'il y en a aucun celule visite	
jal st_depiler				#on depile
jal st_sommet				#on prendre la sommet

move $a3, $v0				#$v0 contient la valeur de sommet, on le copie dans $a3 pour qu'il deviens la cellule visitée
li $a1, 4				#le bit de 4ieme cellule est le bit qu'indique si une cellule est visite (vaut 1) ou non (vaut 0)
jal cell_mettre_bit_a1			#appelle la fonction en passant la valeur 4, et le contenue de $t5
j fin_boucle_pil_nonVide		#on saute à la fin de cette boucle

Existe_voisin_visite:			#S’il y en a au moins une cellule visité
jal voisin_Au_Hasard			#choisir une de ces cellules voixine au hasard 
move $a1, $v0				#sauvgarder l'indice de cellule dans $t4					
jal obtenir_Valeur_Case															
										
move $a3, $v0				#la valeur de cellule avec l'indive $v0				
li $a1, 4				#le bit de 4ieme cellule est le bit qu'indique si une cellule est visite (vaut 1) ou non (vaut 0)
jal cell_mettre_bit_a1			#appelle la fonction en passant la valeur 4, et le contenue de $t5
					
move $a3, $s3				#$s3 contient la valeur retournée de la fonction cell_mettre_bit_a1, on le copie dans $a3 pour qu'il deviens la cellule visitée
li $a1, 7				#le bit de 7ieme cellule est le bit qu'indique si une cellule est visite (vaut 1) ou non (vaut 0)
jal cell_mettre_bit_a1			#appelle la fonction en passant la valeur 7, et le contenue de $s3
					
move $a1, $s3				#la valeur pour empiler
jal st_empiler

fin_boucle_pil_nonVide:
b Boucle_pil_nonVide			#saute à Boucle_pil_nonVide

j Exit					#exit de la program

__start:


##############################################################################################################################
##############################                                ################################################################
##############################     TEST DES FONTIONS CREES    ################################################################
#############################                                 ################################################################
##############################################################################################################################



############################## TEST FONCTION Creer laby et afficher le contenu (mis en commentaire) ##################

li $s0 5   # 5 taille du tableau 
move $a0 $s0  # sauvegarde de la taille dans a0

jal creer_labyrinthe  # Appel de la fonction qui permet de creer le tableau de labyrinthe
move $s1 $v0		# adresse du premier élément du labyrinthe -> $s1
move $s6 $v0

#move $s1, $v0
#move $a1, $s1
#jal AfficheTableau


############################### TEST FONCTION Affiche   Labyrinthe ###################

move $a0 $s0
move $a1 $s1
jal affiche_Labyrinthe  # Appel de la fonction affiche laby

#Deux saut de ligne
la $a0 RetChar
li $v0 4
syscall
la $a0 RetChar
li $v0 4
syscall

############################### Test FONCTION CELLULE Visite ########################

move $a0 $s1
li $s2 5	 # indice de la cellule 
move $a1 $s2	 # On stocke la valeur 5 dans a1
jal cellule_Visite

move $a0 $v0
jal AfficheEntier

la $a0 RetChar
li $v0 4
syscall

############################## Test FONCTION Marqué Visité  ##########################

move $a0 $s1  		# $a0 contient l'adresse du premier élément du tableau								
li $s2 4 		# indice de la cellule à marquer 
move $a1 $s2		# $a1 contient l'indice de la cellule a marqué
jal marque_Visite	# Marque une cellule comme visitée

move $a0 $s0
move $a1 $s1
jal affiche_Labyrinthe

la $a0 RetChar
li $v0 4
syscall

la $a0 RetChar
li $v0 4
syscall


############################ Test FONCTION Obtenir Valeur Case  #########################
move $a0 $a1    # $a0 contient l'adresse du premier élément du tableau
li $s2 24 	# inidice de la cellule
move $a1 $s2    # On stocke l'indice dans a1
jal obtenir_Valeur_Case
move $a0 $v0
jal AfficheEntier


############################# Test FONCTION Modifie Valeur d'une case  #########################

move $a0 $s1 # $a0 contient l'adresse du premier élément du tableau
li $s2 6      # inidice de la case
move $a1 $s2  # On stocke l'indice dans a1
li $a2 32     # On stocke la nouvelle valeur dans a2
jal modifie_Valeur_Case

move $a0 $s0
move $a1 $s1
jal affiche_Labyrinthe

#Deux saut
la $a0 RetChar
li $v0 4
syscall
la $a0 RetChar
li $v0 4
syscall


############################### Test FONCTION Indice Voisin  ###########################

move $a2 $s0  	# la valeur de la taille
li $a3 2 	# valeur de déplacement
move $a0 $s1    # $a0 contient l'adresse du premier élément du tableau
li $a1 5
jal indice_Voisin

move $a0 $v0
jal AfficheEntier

la $a0 RetChar
li $v0 4
syscall


############################### Test FONCTION Voisin Cellules Non Visitees #################

move $a2 $s0 		# la valeur de la taille
move $a0 $s1
move $a0 $s6		# $a0 contient l'adresse du premier élément du tableau
li $s2 15		# indice cellule ou on se trouve
move $a1 $s2
jal cellules_Voisines_Non_Visitees
move $s3 $v0 
move $s4 $v1

move $a0 $s4
jal AfficheEntier

la $a0 RetChar
li $v0 4
syscall

li $a0 4
move $a1 $s3
jal AfficheTableau


############################### Test  fonction Hasard Voisin  #######################
move $a2 $s0 		# la valeur de la taille
move $a0 $s1 		# $a0 contient l'adresse du premier élément du tableau
li $a1 5 		# indice cellule ou on se trouve
jal voisin_Au_Hasard

move $a0 , $v0
jal AfficheEntier

la $a0 RetChar
li $v0 4
syscall


############################### Test FONCTION Cellules voisines ######################

move $a2 $s0 	# la valeur de la taille
li $a3 0 	# valeur de déplacement
move $a0 $s1 	# $a0 contient l'adresse du premier élément du tableau
li $a1 20	# indice cellule ou on se trouve
jal cellules_Voisines
move $t1 $v0 

li $a0 4
move $a1 $t1
jal AfficheTableau

#####################################################################################
#####################################################################################

############################### Test FONCTION cell_lecture_bit ######################

li $a3, 30
li $a1, 5
jal cell_lecture_bit
move $a0, $s3

li $v0, 1
syscall

la $a0 RetChar
li $v0 4
syscall

############################### Test FONCTION cell_mettre_bit_a1 ######################

li $a3, 8
li $a1, 2
jal cell_mettre_bit_a1
move $a0, $s3

li $v0, 1
syscall

la $a0 RetChar
li $v0 4
syscall

############################### Test FONCTION cell_mettre_bit_a0 ######################

li $a3, 15
li $a1, 2
jal cell_mettre_bit_a0
move $a0, $s3

li $v0, 1
syscall

la $a0 RetChar
li $v0 4
syscall

j Exit 


##############################################################################################################################
##############################                                ################################################################
##############################     CREATION DES FONCTIONS     ################################################################
#############################                                 ################################################################
##############################################################################################################################


				###########################################
				############ FONCTIONS DE CELLULES  #######
				###########################################

cell_lecture_bit:		#cette fonction permet de lire le bit de chiffre ($a0) dans le position de i($a1)

#Prologue		 
addi $sp, $sp , -12		
sw $ra, 0($sp)
sw $a0, 4($sp)
sw $a1, 8($sp)	

#corps du fonction		
srlv $t1, $a0,$a1		#on decale $a1 fois les bits de chiffre $a0 et enregistre le nouveau chiffre dans le registre t1
and $s3, $t1, 1			# on utilise l'perateur de AND entre $t1 et 1 pour qu'il nous reste just le premier bit et mettre 0 dans les autres bits

#Epilogue
lw $a1, 8($sp)
lw $a0, 4($sp)
lw $ra, 0($sp)

addi $sp, $sp ,12

jr $ra


cell_mettre_bit_a1:		#mettre 1 dans le bit (qui contients 0) de position i($a1) 
#Prologue		 
addi $sp, $sp , -12		
sw $ra, 0($sp)
sw $a3, 4($sp)	
sw $a1, 8($sp)

#corps du fonction
li $t0, 1
sllv $t2,$t0, $a1		 #decalage a gaucheshift letf i fois, a1 = i fois , a3 = nombre
or $s3, $a3, $t2		#OR entre le $t2 et $a3 pour avoir 1 dans le bit 0 de position i($a1)

#Epilogue
lw $ra, 0($sp)
lw $a0, 4($sp)
lw $ra, 0($sp)
addi $sp, $sp ,12
jr $ra


cell_mettre_bit_a0:		#mettre 0 dans le bit (qui contients 1) de position i($a1) 
#Prologue		 
addi $sp, $sp , -12		
sw $ra, 0($sp)
sw $a0, 4($sp)
sw $a1, 8($sp)	

#corps du fonction
li $t0, 1
sllv $t2,$t0, $a1		#shift letf i fois, a1 = i fois , a0 = nombre
not $t2, $t2			#on utilise operande NOT pour avoir 0 dans le bit i et 1 dans les autre bit
and  $s3, $a3, $t2		#on utilise AND entre nouveau chiffre dans le $t2 et le chiffre dans $a0 pour qu'on ait 0 dans le bit demandé

#Epilogue
lw $a0, 8($sp)
lw $a0, 4($sp)
lw $ra, 0($sp)
addi $sp, $sp ,12
jr $ra


				###########################################			
				########### FONCTIONS DE LA PILE   #######
				###########################################

st_creer:
#prologue 
addi $sp, $sp , -12
sw $ra, 0($sp)
sw $a0, 4($sp)			#$a0 =  octets pour alloer dans le memoire
sw $s0, 8($sp)			#$s0= contients les octet de tableau

#corps du fonction
li $t1,4			#$t1 = 4 pour calculer l'octets de tableau
mul $s0, $a0, $a0		#$s0 contient N*N
move $t0, $s0
mul $s0,$s0, 4			#$s0 contient 4*N*N, calcule nombre d'cotects alloue
move $a0, $s0			#copier le contenue de $s0 dans $a0 pour alloue dans le memoire

li $v0, 9 			# l'instruction sbrk pour allouer le memoire dans le heap
syscall

move $s1,$a0			#$s1 aussi contien l'adresse de la premier element du tableau pour qu'il sera utiliser dans le programme
move $a0, $v0			#$a0 contient l’adresse de la pile


#Epilogue
lw $ra, 0($sp)
lw $a0, 4($sp)
lw $s0, 8($sp)
addi $sp, $sp , 12
jr $ra


st_est_vide:
#prologue 
addi $sp, $sp , -12
sw $ra, 0($sp)
sw $a0, 4($sp)			#$a0 contient l'adresse de la memoire
sw $s1, 8($sp)			#$s1 contiens l'adresse de la premier element du tableau


#corps_du_fonction
beq $s1, $a0,est_vide		#si $a0 et l'adresse de la premier element ($s1) de la tableau sera l'identique, tableau est vide et saute a fin_vide:
li $v0,0			#si le tableau contient au moins 1 element, $v0 veut 0
j fin_vide			#le fonction est fini et on saute a epilogue

est_vide:
li $v0,1			#si le tableau sera vide, $v0 veut 1

fin_vide:
#Epilogue
lw $s1, 8($sp)
lw $a0, 4($sp)
lw $ra, 0($sp)
addi $sp, $sp , 12
jr $ra


st_est_pleine:	
#Prologue		 
addi $sp, $sp , -16		
sw $ra, 0($sp)
sw $a0, 4($sp)			#$a0 = adresse de la memoire
sw $s0, 8($sp)			#$s0= contients les octet de tableau
sw $s1, 12($sp)			#$s1 contiens l'adresse de la premier element du tableau

#corps du fonction
add $t2, $s1, $s0		# $s1 + $s0 (les octets allouer dans le memoire 4*N*N) est l'adresse de fin du tableau, on l'enregistre dans $t2
beq $t2, $a0, est_pleine	#si le contenu de $a0 est egale a la fin du tableau , on saute à "est_pleine"

li $v0,0			#si le tableau n'est pas pleine , le $v0 veut 0
j fin_pleine			#on saute à fin_pleine (EPILOGUE)

est_pleine:			#si le tableau est pleine , le $v0 veut 1
li $v0, 1

fin_pleine:
#Epilogue
lw $s1, 12($sp)	
lw $s0, 8($sp)
lw $a0, 4($sp)
lw $ra, 0($sp)
addi $sp, $sp , 16
jr $ra

st_sommet:			
jal  st_est_vide		#avant que la fonction commence , on verifie la precondition en appellant la fonction st_est_vide
#Prologue		 
addi $sp, $sp , -8		
sw $ra, 0($sp)
sw $a0, 4($sp)			#$a0 = adresse de la memoire

#corps_du_fonction
beq $v0,1, fin_sommet		#on verifie si $v0 vaut 0 dans la fonction st_est_vide(si $v0 veut 0, c-à-d le tableau n'est pas vide
lw $v0, -4($a0)			#chaque element est 4 octets dans MIPS, on ajoute -4 à $a0 pour pointer sur le dernier element de la tableau 
				#et le copie dans $v0
fin_sommet:			#fin de la fonction
#Epilogue
lw $a0, 4($sp)
lw $ra, 0($sp)
addi $sp, $sp ,8
jr $ra



st_empiler :			#avant que la fonction commence , on verifie la precondition en appellant la fonction st_est_pleine
jal st_est_pleine		
Prologue:	 
addi $sp, $sp , -12		
sw $ra, 0($sp)
sw $a0, 4($sp)			#$a0 = adresse de la memoire
sw $a1, 8($sp)	

#corps de la fonction
beq $v0, 1, fin_emplier		#on verifie si $v0 devient 1 dans la fonction st_est_pleine($v0 = 0 c-à-d le tableau n'est pas plein)

sw $a1, 0($a0)			#On stocke le contenu de $a1 dans l'adresse que le $a0 pointer
addi $a0, $a0, 4		#on ajoute 4 a $a0 pour que $a0  cointens l'adresse de la prochaine element de la tableau

fin_emplier:			#fin de la fonction

#Epilogue
lw $a1, 8($sp)
lw $a0, 4($sp)
lw $ra, 0($sp)
addi $sp, $sp , 12
jr $ra


st_depiler :
jal  st_est_vide		#avant que la fonction commence , on verifie la precondition en appellant la fonction st_est_vide
#Prologue		 
addi $sp, $sp , -8		
sw $ra, 0($sp)
sw $a0, 4($sp)			#$a0 = adresse de la memoire

#corps de la fonction
beq $v0,1, fin_depiler		#si le tabvleau etais vide, on saute à fin_depiler
addi $a0, $a0, -4		#pour suprrimer le dernier element du tableau  on sub 4 octets de $a0 qui contiens l'adresse de la tableau

fin_depiler:			#fin de la fonction
#Epilogue
lw $a0, 4($sp)
lw $ra, 0($sp)
addi $sp, $sp ,8
jr $ra



				###########################################
				############ FONCTIONS DU LABYRYNTHE  #####
				###########################################

############################################################# FONCTION CREER_Labyrinthe ##########################################

# Permet de créer un tableau pour stocker le labyrinthe, en mettant des murs partout pour chaque case: valeur 15

creer_labyrinthe:

# prologue
addi $sp, $sp -16
sw $s0 , 12($sp)
sw $s1 , 8($sp)
sw $a0 , 4($sp)  			 #  taille du tableau à afficher
sw $ra ,  0($sp)

#Corps
mul $a0 $a0 $a0  			# Multiplier la taille 5*5 pour obtenir un tableau a deux dimensions 
li $v0 9 				# v0 recupere l'adresse du 1er element du tableau 
syscall

li $t0, 0 				# Initialisation du compteur
li $t1, 15
loop: beq $t0, $a0, end     		# si t0 >=a0 (0>=taille)
	mul $t3, $t0, 4     		# Calcul d'adresse pour acceder au cellule suivante i * 4
	add $t3, $t3, $v0   		# t + i*4
	
	sw $t1, 0($t3)    		# On rempli la case tab[i]=15
	addi $t0, $t0, 1

j loop
end:

#Epilogue 
lw $s0 , 12($sp)
    lw $s1 , 8($sp)
    lw $a0 , 4($sp)
    lw $ra , 0($sp)
    addi $sp , $sp , 16
    
jr $ra


#################################   FONCTION Affiche Labyrinthe   ##########################

### Permet d'afficher le contenu d'un tableau carré (N*N)
###Pré-conditions: Il faut que la taille du tableau soit superieur ou egal a 0

affiche_Labyrinthe :
# Prologue
    addi $sp, $sp -20
    sw $s0 , 16($sp)
    sw $s1 , 12($sp)
    sw $a0 , 8($sp)   		#  taille du tableau à afficher
    sw $a1 , 4($sp)   		# l'addresse du tableau à afficher
    sw $ra ,  0($sp)

# corps de la fonction 
    li $v0 1
    syscall
    move $s0 $a0            	# $s0 : nombre de cases 
    mul $t0 $a0 $a0         	# $t0 : nombre total de cases
    move $t1 $s0            	# $t1 : ième colonne (initialisé à la taille, dans le but de commencer par un saut de ligne)
    li $t2 0                	# $t2 : offset de la case courante du tableau
    li $t4 , 4 		    
    
boucle_Affiche_Labyrinthe : 
	beq $t2 $t0 end_Affiche_Laby 		# Si on a parcouru toutes les cases du tableau, on sort de la boucle

# Saut de ligne

PourEspace:
    bge $t1 $s0 Saut_Ligne  			# Si on est pas encore en fin de ligne, on ne saute pas de ligne
    mul $t5 , $t2 , $t4  
    add $t5, $t5 , $a1 				# $t5 : adresse de la case courante 
    
    # afficheEntier 
    lw $a0, 0($t5)
    li $v0 1
    syscall
    
    li $v0 4
    la $a0 , Espace            
    syscall
    
    addi $t2 $t2 1          # On incrémente $t2 de 1 (on avance d'une case du tableau, l'offset augmente donc de 1)
    addi $t1 $t1 1          # On incrémente $t1 de 1 (on avance d'une colonne)
    
    j boucle_Affiche_Labyrinthe 

 # On traite ici le cas des espaces entre les nombres
Saut_Ligne:
    li $t1 0 
    la $a0 RetChar
    li $v0 4
    syscall
    beq $t1 0 PourEspace   	# Si on est en début de ligne, pas besoin d'insérer d'espace

    
end_Affiche_Laby:  

 # Epilogue
    lw $s0 , 16($sp)
    lw $s1 , 12($sp)
    lw $a0 , 8($sp)
    lw $a1 , 4($sp)
    lw $ra , 0($sp)
    addi $sp , $sp , 20

    jr $ra



################################ FONCTION CELLULE VISITE #####################################

# Permet voir si une case a été visitée ou non 
## entrée :   # $a0 : adresse du premier élément du tableau
##	      # $a1 : indice de la case à marquer comme visitée
## Sortie :  $v0 (=1 si visitée, =0 sinon)

cellule_Visite :

#Prologue
addi $sp, $sp, -28
sw $ra , 0($sp)
sw $a0 , 4($sp)     		# $a0 : adresse du premier élément du tableau
sw $a1 , 8($sp)     		# $a1 : indice de la case à marquer comme visitée
sw $a2 , 12($sp)  
sw $s0 , 16($sp)
sw $s1 , 20($sp)
sw $s2, 24($sp)

# Corps de la fonction
li $t0 , 4
mul $t2 , $t0, $a1
add $t2 , $t2 , $a0           		# Adresse de la case à tester
lw $a0 , 0($t2)               		# Valeur de la case à tester

move $a1, $a0 		      		#Nouveau
li $a0 7 		      		#Nouveau
li $v0 , 0                    		# par défaut que la case n'a pas été visitée
bge $a0 , $zero , FinTestVisite  	# Si la valeur de la case est effectivement positive, on a fini
li $v0 1                    		# Sinon c'est que la case a été visitée

# Epilogue
FinTestVisite:
lw $ra , 0($sp)
lw $a0 , 4($sp)
lw $a1 , 8($sp)
lw $a2 , 12($sp)
lw $s0 , 16($sp)
lw $s1 , 20($sp)
lw $s2, 24($sp)
addi $sp $sp 28

jr $ra


################## FONTION QUI MARQUE UNE CASE SI ELLE EST VISITÉ ###############

# Permet de marquer une case comme visitée
marque_Visite :

# Prologue
addi $sp, $sp, -28
sw $ra , 0($sp)
sw $a0 , 4($sp)
sw $a1 , 8($sp)
sw $a2 , 12($sp)
sw $s0 , 16($sp)
sw $s1 , 20($sp)
sw $s2, 24($sp)


# Corps de la fonction
    
move $s0 $a0 			# adresse du premier élément du labyrinthe -> $s0
move $s1 $a1			# indice de la case à marquer comme visitée -> $s1
    
li $t0 , 4 								
mul $s2 , $s1, $t0
add $s2, $s2, $s0     		# Bonne adresse pour la case à modifier
lw $a1 , 0($s2)       		# obtention de la valeur de la case désiré
    #li $a0 , 0			# bit à modifier 
    #jal cell_mettre_bit_a1
    
addi $a1 $a1 -128   		# Choix du dernier bit de poids fort (128)
    
li $t0 , 4 								
mul $s2 , $s1, $t0
add $s2, $s2, $s0     		# Bonne adresse pour la case à modifier
sw $a1 , 0($s2)       		# On met la case désirée à la nouvelle valeur

# Epilogue
lw $ra , 0($sp)
lw $a0 , 4($sp)
lw $a1 , 8($sp)
lw $a2 , 12($sp)
lw $s0 , 16($sp)
lw $s1 , 20($sp)
lw $s2, 24($sp)
addi $sp $sp 28

jr $ra


###################  FONCTION  Obtenir la valeur d'une case du labyrinthe  ###############    

##sortie $v0 : valeur indiqué par l'indice 

obtenir_Valeur_Case :

# Prologue
addi $sp, $sp -12
sw $ra , 0($sp)
sw $a0 , 4($sp)  		# $a0 = adresse du 1er élément du tableau
sw $a1 , 8($sp)  		# $a1 = indice du premier élément à modifier
    

# Corps 
li $t0 , 4 
mul $t1 , $a1, $t0
add $t1, $t1, $a0     		# Bonne adresse pour la case à modifier
lw $v0 , 0($t1)       		# obtention de la valeur de la case désiré

# Epilogue
   
lw $ra , 0($sp)
lw $a0 , 4($sp)
lw $a1 , 8($sp)
addi $sp $sp 12

jr $ra


#################  FONCTION Modifier la valeur d'une case ###########################
#$a0 = adresse du 1er élément du tableau
#$a1 = indice du premier élément à modifier
#$a2 = nouvelle valeur
# Permet de modifier une valeur d'une case du labyrinthe     
modifie_Valeur_Case :

# Prologue
addi $sp, $sp, -28
sw $ra , 0($sp)
sw $a0 , 4($sp)
sw $a1 , 8($sp)
sw $a2 , 12($sp)
sw $s0 , 16($sp)
sw $s1 , 20($sp)
sw $s2, 24($sp)

# Corps de la fonction
li $t0 , 4
mul $t1 , $a1, $t0
add $t1, $t1, $a0     		# Adresse pour la case à modifier
sw $a2 , 0($t1)       		# On met dans $a2 la nouvelle valeur 

# Epilogue   
lw $ra , 0($sp)
lw $a0 , 4($sp)
lw $a1 , 8($sp)
lw $a2 , 12($sp)
lw $s0 , 16($sp)
lw $s1 , 20($sp)
lw $s2, 24($sp)
addi $sp $sp 28

jr $ra
 
################################################ FONCTION INDICE DE LA CELLULE VOISINE ###################

# Retourne l'indice d'un des voisins
## Sortie : $v0 : l’indice de la cellule à laquelle on parvient en partant de c et en avançant d’une
##cellule dans la direction d | si aucun voisin alors on retoune la même indice 

indice_Voisin : 

#prologue
addi $sp, $sp, -32
sw $ra , 0($sp)
sw $a0 , 4($sp)     #  adresse du premier élément du tableau contenant le labyrinthe
sw $a1 , 8($sp)	    # indice X de la case courante (La case dans la quelle on se trouve)
sw $a2 , 12($sp)    # valeur de N entrée au début par l'utilisateur
sw $a3 , 16($sp)    # valeur pour identifier la direction (0 : haut, 1 : droite, 2 : bas, 3 : gauche)
sw $s0 , 20($sp)   
sw $s1 , 24($sp)  
sw $s2 , 28($sp)  
# corps 

move $t0 $a1                    # soit X
move $t1 $a2                    # soit N
div $t2 $t0 $t1   		# X/N
mfhi $t2                        # X%N recupere le modulo reste de la division

# Valeurs pour les tests
subi $t3 $t1 1                  # $t3=N-1
mul $t4 $t1 $t3                 # $t4=N*(N-1)
    
beq $a3 0 VoisinHaut
beq $a3 1 VoisinDroite
beq $a3 2 VoisinBas
beq $a3 3 VoisinGauche

VoisinHaut : 
blt $t0 $t1 FinVoisin       # Si X<N alors il n'y a pas de voisin en haut
sub $a1 $t0 $t1             # Sinon l'indice vaut X-N
j FinVoisin

VoisinDroite :
beq $t3 $t2 FinVoisin     # Si X%N = N-1 alors pas de voisin à droite
addi $a1 $t0 1            # Sinon l'indice vaut X+1
j FinVoisin

VoisinBas : 
bge $t0 $t4 FinVoisin        # Si X >= N*(N-1) alors il n'y a pas de voisin en bas
add $a1 $t0 $t1              # Sinon l'infice vaut X+N
j FinVoisin

VoisinGauche :
beq $t2 0 FinVoisin       # Si X%N = 0 alors pas de voisin à gauche
subi $a1 $t0 1            # Sinon l'indice vaut X-1

FinVoisin : 
move $v0 $a1

# Epilogue  
lw $ra , 0($sp)
lw $a0 , 4($sp)
lw $a1 , 8($sp)
lw $a2 , 12($sp)
lw $s0 , 16($sp)
lw $s1 , 20($sp)
lw $s2, 24($sp)
lw $a3, 28($sp)
addi $sp $sp 32

jr $ra
 
 
#################################### FONCTION QUI AFFICHE TOUTES LES CELLULES VOISINES ############

cellules_Voisines:
#prologue
addi $sp, $sp, -36
sw $ra , 0($sp)
sw $a0 , 4($sp)    #adresse du premier élément du tableau contenant le labyrinthe
sw $a1 , 8($sp)    #indice X de la case courante
sw $a2 , 12($sp)   #valeur de N entrée au début par l'utilisateur
sw $a3,  16($sp)   #$a3 : valeur pour identifier la direction (0 : haut, 1 : droite, 2 : bas, 3 : gauche)
sw $s0,  20($sp)
sw $s1,  24($sp)
sw $s2,  28($sp)
sw $s3,  32($sp)

# corps 
li $t0 4 # nombre total de direction  
mul $a0 , $t0 , $t0 

li $v0 9
Syscall
move $s0 $v0 # adresse du premier élément du tableau contenant les indices des cellules voisines de cell


move $t0 $a1                    # X
move $t1 $a2                    # N
div $t2 $t0 $t1
mfhi $t2                        # X%N

# Valeurs pour les tests
subi $t3 $t1 1                  # $t3=N-1
mul $t4 $t1 $t3                 # $t4=N*(N-1)


li $t5 0 # indice
li $t6 4 # dataSize

# VoisinHaut  
blt $t0 $t1 FinVoisinHaut       # Si X<N alors il n'y a pas de voisin en haut
sub $a1 $t0 $t1             	# Sinon l'indice vaut X-N

mul $t7, $t5 , $t6
add $t7, $t7, $s0
sw $a1, 0($t7)

FinVoisinHaut : 

# VoisinDroite
beq $t3 $t2 FinVoisinDroite     # Si X%N = N-1 alors pas de voisin à droite
addi $a1 $t0 1           	 # Sinon l'indice vaut X+1

addi $t5 , $t5 , 1

mul $t7, $t5 , $t6
add $t7, $t7, $s0
sw $a1, 0($t7)

FinVoisinDroite :

# VoisinBas
bge $t0 $t4 FinVoisinBas         # Si X >= N*(N-1) alors il n'y a pas de voisin en bas
add $a1 $t0 $t1              	# Sinon l'infice vaut X+N

addi $t5 , $t5 , 1

mul $t7, $t5 , $t6
add $t7, $t7, $s0
sw $a1, 0($t7)

FinVoisinBas :

# VoisinGauche
beq $t2 0 FinVoisinGauche        # Si X%N = 0 alors pas de voisin à gauche
subi $a1 $t0 1           	 # Sinon l'indice vaut X-1

addi $t5 , $t5 , 1

mul $t7, $t5 , $t6
add $t7, $t7, $s0
sw $a1, 0($t7)

FinVoisinGauche  :
move $v0 $s0

# Epilogue  
lw $ra , 0($sp)
lw $a0 , 4($sp)
lw $a1 , 8($sp)
lw $a2 , 12($sp)
lw $s0 , 16($sp)
lw $s1 , 20($sp)
lw $s2,  24($sp)
lw $s3 , 28($sp)
lw $s3,  32($sp)
addi $sp $sp 36
jr $ra


############################### FONTION QUI AFFICHE TOUTES LES CELLULES VOISINES NON VISITEES   ########################

## Sortie : $v1 : le nombre de case qui n'ont pas encore été visitees et qui sont des voisins de la cellule courante
##	    $v0 : adresse du premier élément du tableau contenant les voisins de la cellule courante

cellules_Voisines_Non_Visitees :

#prologue
addi $sp, $sp, -32
sw $ra , 0($sp)
sw $a0 , 4($sp)    # adresse du premier élément du tableau contenant le labyrinthe
sw $a1 , 8($sp)    # indice X de la case courante
sw $a2 , 12($sp)   #valeur de N entrée au début par l'utilisateur
sw $s0 , 16($sp)
sw $s1 , 20($sp)
sw $s2, 24($sp)
sw $s3, 28($sp)


# corps 
li $t0 4      # nombre total de direction  
mul $a0 , $t0 , $t0 

li $v0 9
Syscall
move $s0 $v0 # adresse du premier élément du tableau contenant les indices des cellules voisines de cell

move $t0 $a1                    # X
move $t1 $a2                    # N
div $t2 $t0 $t1
mfhi $t2                        # X%N

# Valeurs pour les tests
subi $t3 $t1 1                  # $t3=N-1
mul $t4 $t1 $t3                 # $t4=N*(N-1)


li $t5 0 # indice
li $t6 4 # dataSize

lw $a0, 4($sp) # récupération de l'adresse du tableau 


# VoisinHaut  
blt $t0 $t1 FinVoisinHaut1       # Si X<N alors il n'y a pas de voisin en haut
sub $a1 $t0 $t1                 # Sinon l'indice vaut X-N
jal cellule_Visite              # On vérifie si la case a déjà été visitée
beq $v0 1 FinVoisinHaut1         # Si c'est le cas, ce voisin n'est plus disponible

mul $t7, $t5 , $t6
add $t7, $t7, $s0
sw $a1, 0($t7)

FinVoisinHaut1 : 

# VoisinDroite
beq $t3 $t2 FinVoisinDroite1     # Si X%N = N-1 alors pas de voisin à droite
addi $a1 $t0 1            	 # Sinon l'indice vaut X+1
jal cellule_Visite               # On vérifie si la case a déjà été visitée
beq $v0 1 FinVoisinDroite1       # Si c'est le cas, ce voisin n'est plus disponible

addi $t5 , $t5 , 1

mul $t7, $t5 , $t6
add $t7, $t7, $s0
sw $a1, 0($t7)

FinVoisinDroite1 :

# VoisinBas
bge $t0 $t4 FinVoisinBas1          # Si X >= N*(N-1) alors il n'y a pas de voisin en bas
add $a1 $t0 $t1              	   # Sinon l'infice vaut X+N
jal cellule_Visite                 # On vérifie si la case a déjà été visitée
beq $v0 1 FinVoisinBas1          # Si c'est le cas, ce voisin n'est plus disponible

addi $t5 , $t5 , 1

mul $t7, $t5 , $t6
add $t7, $t7, $s0
sw $a1, 0($t7)

FinVoisinBas1 :

# VoisinGauche
beq $t2 0 FinVoisinGauche1        # Si X%N = 0 alors pas de voisin à gauche
subi $a1 $t0 1            	  # Sinon l'indice vaut X-1
jal cellule_Visite                # On vérifie si la case a déjà été visitée
beq $v0 1 FinVoisinGauche1       # Si c'est le cas, ce voisin n'est plus disponible

addi $t5 , $t5 , 1

mul $t7, $t5 , $t6
add $t7, $t7, $s0
sw $a1, 0($t7)

FinVoisinGauche1  :
move $v0 $s0

# Epilogue  
lw $ra , 0($sp)
lw $a0 , 4($sp)
lw $a1 , 8($sp)
lw $a2 , 12($sp)
lw $s0 , 16($sp)
lw $s1 , 20($sp)
lw $s2, 24($sp)
lw $s3 , 28($sp)
addi $sp $sp 32

jr $ra

#################################### FONCTION QUI RETOURNE L'INDICE AU Hasard D'UN Voisin   #############	    
## Sortie : $v0 : indice d'une cellule voisine tiré au hasard

voisin_Au_Hasard: 
#prologue
addi $sp, $sp, -32
sw $ra , 0($sp)
sw $a0 , 4($sp)
sw $a1 , 8($sp)
sw $a2 , 12($sp)
sw $s0 , 16($sp)
sw $s1 , 20($sp)
sw $s2, 24($sp)
sw $s3 , 28($sp)

# Corps
jal cellules_Voisines           # appel à la fonction cellules_Voisines
move $s0 $v0                    # $s0 contient l'adresse du premier élément du tableau contenant les voisins de la cellule courante

li $a0 0 
li $a1 4                        # Borne sup = $s1
    
li $v0 42                       # Génère un nombre aléatoire dans $a0, 0 <= $a0 < $a1
syscall
    
mul $t1 , $a1 , $a0             # On calcule l'offset pour récupérer le bon voisin
add $t1 , $t1 , $s0 
lw $v0 , 0($t1)                 # $v0 contient désormais l'indice d'un voisin choisi aléatoirement

#epilogue
lw $ra , 0($sp)
lw $a0 , 4($sp)
lw $a1 , 8($sp)
lw $a2 , 12($sp)
lw $s0 , 16($sp)
lw $s1 , 20($sp)
lw $s2, 24($sp)
sw $s3 , 28($sp)
addi $sp $sp 32

jr $ra   


#####################################################################################################################################

#################################  Fonction AfficheTableau ######################################"
###entrées: 
###   $a0: taille (en nombre d'entiers) du tableau à afficher
###   $a1: l'addresse du tableau à afficher
###Pré-conditions: $a0 >=0
###Sorties:
###Post-conditions: les registres temp. $si sont rétablies si utilisées
AfficheTableau:
    #prologue:
    subu $sp $sp 24
    sw $s0 20($sp)
    sw $s1 16($sp)
    sw $s2 12($sp)
    sw $a0 8($sp)
    sw $a1 4($sp)
    sw $ra 0($sp)

    #corps de la fonction:
    la $a0 Tableau
    li $v0 4
    syscall
    lw $a0 8($sp)
    jal AfficheEntier
    la $a0 Aladresse
    li $v0 4
    syscall
    lw $a0 4($sp)
    jal AfficheEntier

    lw $a0 8($sp)
    lw $a1 4($sp)

    li $s0 4
    mul $s2 $a0 $s0 		#$a0: nombre d'octets occupés par le tableau
    li $s1 0 			#s1: variable incrémentée: offset
    LoopAffichage:
        bge $s1 $s2 FinLoopAffichage
        lw $a1 4($sp)
        add $t0 $a1 $s1 	#adresse de l'entier: adresse de début du tableau + offset
        lw $a0 0($t0)
        jal AfficheEntier
        addi $s1 $s1 4 		#on incrémente la variable
        j LoopAffichage

    FinLoopAffichage:
        la $a0 RetChar
        li $v0 4
        syscall

        #épilogue:
        lw $s0 20($sp)
        lw $s1 16($sp)
        lw $s2 12($sp)
        lw $a0 8($sp)
        lw $a1 4($sp)
        lw $ra 0($sp)
        addu $sp $sp 24
        jr $ra
###########################################################################

#################################Fonction AfficheEntier
###entrées: $a0: entier à afficher
###Pré-conditions:
###Sorties:
###Post-conditions:
AfficheEntier:
    #prologue:
    subu $sp $sp 8
    sw $a0 4($sp)
    sw $ra 0($sp)

    #corps de la fonction:
    li $v0 1
    syscall

    la $a0 RetChar
    li $v0 4
    syscall

    #épilogue:
    lw $a0 4($sp)
    lw $ra 0($sp)
    addu $sp $sp 8
    jr $ra
#########################################################

Exit: # fin du programme
    li $v0 10
    syscall
