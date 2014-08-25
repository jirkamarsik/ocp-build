all: config/Makefile
	cd byterun; $(MAKE)

config/Makefile: configure
	./configure

clean:
	touch config/Makefile
	cd byterun; $(MAKE) clean
	rm -f config/Makefile config/s.h config/m.h	
