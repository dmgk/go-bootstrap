# Build Go bootstrap toolchains from the modern source.
# bash is expected to be on PATH

GOOS=		freebsd
GOARCH=		arm amd64 386
GOARM=		6 7

UPLOAD_TARGET=	dmgk@freefall.freebsd.org:public_distfiles/go/

all:
.for goarch in ${GOARCH}
.  if ${goarch} == arm
.    for goarm in ${GOARM}
	cd ${.CURDIR}/go/src ; \
		env GOOS=${GOOS} GOARCH=${goarch} GOARM=${goarm} CGO_ENABLED=0 \
		../../bootstrap.sh
.    endfor
.  else
	cd ${.CURDIR}/go/src ; \
		env GOOS=${GOOS} GOARCH=${goarch} GO386=387 CGO_ENABLED=0 \
		../../bootstrap.sh
.  endif
.endfor

clean:
	rm -rf go-*-bootstrap go-*.tar.xz

upload:
	cp -v go-*.tar.xz ~/ports/distfiles
	# scp -p go-*.tar.xz ${UPLOAD_TARGET}

.PHONY: all clean upload
