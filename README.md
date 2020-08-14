# Rand Image
This is just a silly little project, written in C, that servers a random PNG
image over localhost:8080. It started as a way to try out the
[swill](https://github.com/dspinellis/swill) library. It was supposed to be
more interesting than a random image, but I am giving up on it.


The potentially interesting aspects of this code are: the makefile has a little
bit of fancyness, it uses the [lodepng](https://github.com/lvandeve/lodepng),
and [logc](https://github.com/rxi/log.c) libraries together, and it does end up
using swill. Perhaps this will just be a reference for me one day when I want
to use swill in anger.


## Simple C Libraries
For some reason, I am fascinated by small C libraries. I like to collect these
tiny libraries and combine into programs on occasion, sometimes for fun and
sometimes quite nicely for work.


This is not limited to header-only libraries. Those are neat, but I don't mind
putting a few files into my build as long as its not too many or if they
require special handling to build them.


When I copy small libraries into my projects, I don't necessarily copy the full
project- I just copy the files I need and the licsense, and make sure its clear
that I did not write them.



### Swill
I ran across 'swill' the other day, and I think it is interesting- it provides
a simple web server that you can embed within a C program to serve static
content. The idea is to give some insight into long-running programs without
being intrusive or taking over control from the host program.


I think swill is interesting in several ways: 

  * It serves a specific need- scientists that wanted some insight into their programs. I
  like code that gets things done and is bathed in the fires of practicality, so this
  piques my interest.
  * It seems to value simplicity- the documentation is a single file, and I understand how it
  use it from a single reading.
  * The features it does provide make sense- they are not intrusive if you just want the
  simplest thing, but they provide extra functionality for more complex use cases.
  * It is aware of its boundaries- it does not solve all problems, and does not try.
  More complete solutions are possible (full webservers for example), so swill can
  occupy its niche confortably and provide value within it.
  * Its clearly cared for- the authors wrote documentation, comments, examples, and packaged.
  

With these things in mind, I wanted to add this to my list of libraries I can
break out if I need to. The fact that is only serves static content is
certainly a limitation, but sometimes you just need a little insight and
nothing fancy.

I will talk about building swill a bit later- its not as trivial as the other
libraries, but its completely conventional and easy.

### Log.c
The log.c library is a small logging library that I have gotten a lot of use
out of lately.  I throw it into just about all of my C programs- its better
then printf, and its just a few files with nothing special to worry about.


I don't even use the more advanced callback features- I just set a logging
level, sometimes in an ini file parsed by another library by the same author
([ini](https://github.com/rxi/ini)) and I get colored output and log levels for
filtering how much information I see.

### LodePng
I use lodepng when I need to create images from a C program. This is great at
work when dealing with detectors- I get their data as raw binary counts, and I
want to see them as an image.  I don't use most of the library, as I rarely
need anything fancy from my images, but its a great way to get images into and
out of a C program if are able to use png for their format.


## Make Files
I have been building more complex software recently, so I thought I would try
some slightly non-trivial things in my Makefile, just for fun. Whether they are
a good idea is another matter.


### Downloading a Dependency
While logc and lodepng are easy enough to download and include in my source
tree (along with their liscense, and this readme explaining where I got them),
swill is a little more complicated. I didn't want to include the entire thing
in my source tree, but I did want to use swill instead of a simpler solution
like [sandbird](https://github.com/rxi/sandbird).


To solve this problem, the Makefile uses git to clone out the swill repository,
and then checks out a specific commit (so I know it will continue to work if
swill were updated).


The solution I came up with was:
```bash
.ONESHELL:
dep/swill/libswill.a:
	cd dep 
	-git clone https://github.com/dspinellis/swill
	cd dep/swill
	git checkout fafde7646c39bfc3b30521dbcda9efaa94396b0e
	./configure
	make -j
```
The ".ONESHELL" part is interesting- it tells make to run all commands in the
same shell instead of separate ones. The problem that this solves here is
changing directories- by default if you 'cd' on one line, or are back to the
original directory on another. You can merge lines with "&&", but this becomes
tedious quickly if you have multiple commands to run.


The second thing to note here, if you are new to make, is that the git command
does not cause this rule to fail. I did this because it may run even if you
have swill cloned (in case it doesn't finish building at first), and you will
not keep downloading it. This may cause some confusion, if the repo doesn't
clone and you end up trying to check out the given commit, but I figured it was
worth it.


### Multiple Builds
I occasionally want to build this project with debug info "-g". While its simply enough to 
write "CFLAGS=-g make -j", I want to create separate builds- a debug build and a release build.


There are several ways to do this in make, but a trick I found the other day
was to use variable expansion to construct a variable name, and then expand
that name, to select which of several versions of a variable to use. For
example:
```
BUILD ?= release

build.release:=-O3
build.debug:=-O0 -g3
BUILD_FLAGS:=$(build.$(BUILD))
```
This uses optimization in the release build ("-O3"), and no optimization and
turns on debugging in the debug build ("-O0 -g3"). I then use BUILD\_FLAGS in
my CFLAGS to include the chosen flags.

The way this works is the the BUILD variable can be set on the command line
with "make BUILD=release" or "make BUILD=debug", and if it is not set, it will
be release.

When BUILD\_FLAGS is expanded if creates the name "build." with either "debug"
or "release", creating the variable "build.release" or "build.debug", which is
then expanded in turn to either "-O3" or "-O0 -g3".


This is not elegant, its hacky. However, at least I understand what the
makefile does (I'm looking at you cmake...).


### .PHONY
The last thing to mention is ".PHONY". This is a good trick to use in
makefiles- it indicates to make that a rule does not create a file of the given
name. Usually the rule name should be a file, and the rule constructs that
file. In some cases, the rule is just a collection of commands. This will
usually work anyway, but if you created a file call 'all', the 'all' rule may
not fire. Is is annoying, implicit behavior that is better explcitly avoided.


### Out of Source Builds
I did not implement out-of-source builds this time. I've done it before, using
some combinations of builtin in make functions to control file paths and
extensions. I didn't do that in this case.  Its not just a big deal for a
little project.


### Linking Object Files
I decided to not compile each file individually and link them together in this
project. Usually you would have pattern matching files like "%.o" which build all
object files, and link them in the end. Actually, make has builtin rules for
this kind of thing- you seem to only need your own if you want to control
file locations.


In this project, I'm linking swill as a static library (".a"), and just giving
all source code to gcc at once. This is slower then building dependencies
separately and linking. I intended to try using
[tcc](https://github.com/TinyCC/tinycc), which is fast enough that it wouldn't
matter, but I didn't work out the include paths. Instead I used gcc, which is
much slower.


The main reason for this decision was that I would have worked out the
out-of-source build stuff, but I decided to not go forward on this project, so
I left the easier solution in. Future work? Perhaps.

## Compiler Flags
In all recent C I have written, I've been using:
```
-Wall -Werror -Wextra -pedantic
```
to get all warnings, extra warnings above even "-Wall", and to make any warning an error.
I'm used to writing C code where correctness is important, and I want as much
help as possible, so I don't mind the strictness one bit. I did have to add 
"-Wno-cast-function-type" due to a function cast in swill, but no big deal.


I didn't enable "-O0" for release builds in this case, mostly to make them
different from debug builds, but that is common practice at work- correctness
is more important then throughput as long as you meet your latency requirements.


## Conclusion
This was a fun project, even though I didn't end up making the images it serves
interesting. 


I did try to include [fann](https://github.com/libfann/fann), and
then when I had problems building it I tried [genann](https://github.com/codeplea/genann).


Genann is quite simple, and I like that you can just build and use a simple ANN
in a few lines of code with just two files (.h and .c).


I did have a problem with a large network where it segfaulted due to integer
overflow. It does use some unsafe practices like significant
use of pointer arithmatic. I'm not putting it down- this is normal C practice
and its not safety-critical code or anything, but it is something I ran into.

