# Build Go bootstrap toolchains from the modern source.
# bash is expected to be on the PATH

GOROOT=		/usr/local/go

GOOS=		freebsd
ARCHS=		386 amd64 arm6 arm7 arm64

all: ${ARCHS}

.for arch in ${ARCHS}
${arch}: clean-${arch}
	cd ${.CURDIR}/go/src ; \
		env GOROOT=${GOROOT} PATH=${GOROOT}/bin:$$PATH \
		GOOS=${GOOS} \
		GOARCH=${arch:C/^arm.$/arm/} \
		GOARM=${arch:Marm?:S/arm//} \
		GO386=${arch:M386:S/386/387/} \
		CGO_ENABLED=0 \
		../../bootstrap.sh

clean-${arch}:
	rm -rf ${.CURDIR}/go-freebsd-${arch}-bootstrap

.PHONY: ${arch} clean-${arch}
.endfor

clean:
	rm -rf go-*-bootstrap go-*.tar.xz

upload:
	# TODO: make Github release and upload assets
	cp -pv go-*.tar.xz ~/ports/distfiles

.PHONY: all clean upload
