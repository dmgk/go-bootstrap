# Build Go bootstrap toolchains from the modern source.
# bash is expected to be on PATH

GOROOT=		/usr/local/go

GOOS=		freebsd
GOARCH=		amd64 386 arm
GOARM=		6 7

all:
.for goarch in ${GOARCH}
.  if ${goarch} == arm
.    for goarm in ${GOARM}
	cd ${.CURDIR}/go/src ; \
		env GOROOT=${GOROOT} PATH=${GOROOT}/bin:$$PATH \
		GOOS=${GOOS} GOARCH=${goarch} GOARM=${goarm} CGO_ENABLED=0 \
		../../bootstrap.sh
.    endfor
.  else
	cd ${.CURDIR}/go/src ; \
		env GOROOT=${GOROOT} PATH=${GOROOT}/bin:$$PATH \
		GOOS=${GOOS} GOARCH=${goarch} GO386=387 CGO_ENABLED=0 \
		../../bootstrap.sh
.  endif
.endfor

clean:
	rm -rf go-*-bootstrap go-*.tar.xz

upload:
	# todo
	cp -pv go-*.tar.xz ~/ports/distfiles

.PHONY: all clean upload
