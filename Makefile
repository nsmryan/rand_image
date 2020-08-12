

.ONESHELL:
swill.a: dep/swill/README
	cd dep/swill
	git checkout fafde7646c39bfc3b30521dbcda9efaa94396b0e
	./configure
	make

.ONESHELL:
dep/swill/README:
	cd dep 
	-git clone https://github.com/dspinellis/swill



