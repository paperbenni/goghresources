PREFIX = /usr/

all: install

install:
	install -Dm 755 goghresources.sh ${DESTDIR}${PREFIX}bin/goghresources

uninstall:
	rm ${DESTDIR}${PREFIX}bin/goghresources
