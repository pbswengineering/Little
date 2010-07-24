CC = c++
CFLAGS = -Wall -O2
DEST = /usr/local/bin

.PHONY: all doc prg clean install pkg

all: nuweb/nuweb doc prg

nuweb/nuweb:
	cd nuweb && make nuweb

doc: doc/little.pdf

doc/little.pdf: doc/little.ps
	cd doc && ps2pdf -dPDFSETTINGS=/screen little.ps

doc/little.ps: doc/little.dvi
	cd doc && dvips -z -t a4 -Ppdf -G0 little.dvi

doc/little.dvi: doc/little.tex pics/unipg.eps nuweb/nuweb
	cd doc && latex little.tex
	cd doc && ../nuweb/nuweb -o ../little.w
	cd doc && latex little.tex

doc/little.tex: little.w nuweb/nuweb
	cd doc && ../nuweb/nuweb -o ../little.w

prg: src/little

src/little: src/little.cpp
	cd src && $(CC) $(CFLAGS) -o little little.cpp
	which strip > /dev/null 2>&1 && ( cd src && strip little ) || true

src/little.cpp: little.w nuweb/nuweb
	cd src && ../nuweb/nuweb -t ../little.w
	mv src/*.lil examples
	which indent > /dev/null 2>&1 && ( cd src && indent -kr -i8 little.cpp ) || true
	cd src && rm -f little.cpp~

install: prg
	cd src && install -m 755 little $(DEST)

pkg: clean doc src/little.cpp
# Just in case the previous packaging failed
	rm -fr /tmp/little
	mkdir /tmp/little
	cp -r * /tmp/little
	rm -r /tmp/little/auto
# Why find fails?
	rm -fr /tmp/little/src/.svn
	rm -fr /tmp/little/doc/.svn
	rm -fr /tmp/little/pics/.svn
	rm -fr /tmp/little/.svn
	rm -fr /tmp/little/examples/.svn
	cd /tmp && tar cjf little.tar.bz2 little
	rm -fr /tmp/little
	mv /tmp/little.tar.bz2 .

clean:
	( cd nuweb && make clean && rm -f nuweb )
	rm -f *~ doc/* src/* examples/* little.tar.bz2

# That's all, folks!
