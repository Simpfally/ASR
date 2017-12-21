leti r0 0
sub2i r0 1
sub2i r0 1
sub2i r0 1

leti r0 0xFF
shift 0 r0 6
setctr a0 r0
leti r1 -1
write a0 64 r1
leti r1 2

setctr a0 r0
readze a0 64 r1
jump -13
