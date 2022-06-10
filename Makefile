# Build Go bootstrap toolchains from the modern source.
# bash is expected to be on the PATH

GOROOT=		/usr/local/go

GOOS=		freebsd
ARCHS=		386 amd64 arm6 arm7 arm64 riscv64

all: ${ARCHS}

.for arch in ${ARCHS}
${arch}: clean-${arch} patch
	cd ${.CURDIR}/go/src ; \
		env GOROOT=${GOROOT} PATH=${GOROOT}/bin:$$PATH \
		GOOS=${GOOS} \
		GOARCH=${arch:C/^arm.$/arm/} \
		GOARM=${arch:Marm?:S/arm//} \
		GO386=${arch:M386:S/386/softfloat/} \
		CGO_ENABLED=0 \
		../../bootstrap.sh

clean-${arch}: unpatch
	rm -rf ${.CURDIR}/go-freebsd-${arch}-bootstrap

.PHONY: ${arch} clean-${arch}
.endfor

patch:
	[ ! -d ${.CURDIR}/patches -o -z "$(ls ${.CURDIR}/patches/*.patch)" ] || ( \
		cd ${.CURDIR}/go && \
		git apply ${.CURDIR}/patches/*.patch && \
		touch ${.CURDIR}/.patch-done \
	)

unpatch:
	[ ! -f ${.CURDIR}/.patch-done ] || ( \
		cd ${.CURDIR}/go && \
		git reset --hard && git clean -fd && \
		rm -f ${.CURDIR}/.patch-done \
	)

clean: unpatch
	rm -rf go-*-bootstrap go-*.tar.xz

upload:
	cp -pv go-*.tar.xz ~/ports/distfiles

scp:
	scp -P 8022 go-freebsd-riscv64-*.tar.xz localhost:.

.PHONY: all clean upload
