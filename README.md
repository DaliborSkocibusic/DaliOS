# DaliOS
My Attempt at coding an OS based on the course - Udemy Developing a Multithreaded Kernel From Scratch!

https://www.udemy.com/course/developing-a-multithreaded-kernel-from-scratch/


Note this is GPL2.0 as per the original author Daniel McCarthy's PeachOS course. This content is (In a perfect world) going to end up the same as the repo below. 
In an even better world I might figure out how to do this on my own and make some modifications. This however wont happen any time soon if at all. 

https://github.com/nibblebits/PeachOS

Please note, while I did write this code, it is 100% from the course Deveveoping a Multithreaded Kernel From Scratch!

If you want to clone / fork, you are much better off doing so from the PeachOS link above as Daniel authored the course.

I more then likely will make many mistakes.

Please support Daniel if you can, the course is amazing and Daniel realy knows OS / Kernel development

Modify

-------
Summary of Commits: 

Loads sector from a txt file. e6bfdde4d758918e9d136fdd11c2999fc6760cd6
https://github.com/DaliborSkocibusic/DaliOS/tree/e6bfdde4d758918e9d136fdd11c2999fc6760cd6

Loads protected mode: 93f3fc81b163062e4c3f2ae5e293efe707a5d04e
https://github.com/DaliborSkocibusic/DaliOS/tree/93f3fc81b163062e4c3f2ae5e293efe707a5d04e

Loads A20 line: 

Create cc as per https://wiki.osdev.org/GCC_Cross-Compiler

20: Created a cross compiler
https://wiki.osdev.org/GCC_Cross-Compiler#Binutils

21: seperates it into a kernal and a 32bit mode. 