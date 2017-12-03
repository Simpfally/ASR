jump 16 main

func:
asr3 r0 r1 1
return

main:
leti r0 1
leti r1 1
loop:
call func
jump 16 loop
