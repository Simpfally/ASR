leti r0 1
leti r1 -40
cmp r0 r1 ; 1000 1=1 1>=1

jumpif 16 neq error
jumpif 16 sgt error
jumpif 16 slt error
jumpif 16 gt error
jumpif 16 lt error
jumpif 16 v error

leti r0 2
leti r1 1
cmp r0 r1 ; 0000 2>1(signed and unsigned) 2>=1

jumpif 16 eq error
jumpif 16 slt error
jumpif 16 lt error
jumpif 16 v error

leti r0 1
leti r1 2
cmp r0 r1 ; 0111 2<1(signed and unsigned) 2<=1

jumpif 16 eq error
jumpif 16 sgt error
jumpif 16 gt error
jumpif 16 ge error

leti r0 -1
leti r1 2
cmp r0 r1 ; 0111 -1 < 2

jumpif 16 slt error
jumpif 16 eq error
jumpif 16 sgt error
jumpif 16 gt error
jumpif 16 ge error


jump -13
error:
leti r2 666
jump -13
