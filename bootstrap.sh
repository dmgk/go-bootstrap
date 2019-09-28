#!/usr/bin/env bash

# This is a hacked version of ./go/src/bootstrap.bash
# Must be run from ./go/src directory

set -e

if [ "$GOOS" = "" -o "$GOARCH" = "" ]; then
	echo "usage: GOOS=os GOARCH=arch bootstrap.sh" >&2
	exit 2
fi

tgt="go-${GOOS}-${GOARCH}${GOARM}-bootstrap"
tpath="../../${tgt}"
if [ -e "${tpath}" ]; then
	echo "${tgt} already exists; remove before continuing"
	exit 2
fi

echo
echo "### Building for ${GOOS}/${GOARCH}${GOARM}"
echo

unset GOROOT
src=$(cd .. && pwd)
echo "Copying to ${tgt}"
cp -R "${src}" "${tpath}"
cd "${tpath}"
echo "Building ${tgt}"
cd src
./make.bash --no-banner
gohostos="$(../bin/go env GOHOSTOS)"
gohostarch="$(../bin/go env GOHOSTARCH)"
goos="$(../bin/go env GOOS)"
goarch="$(../bin/go env GOARCH)"

# We're about to delete all but the cross-compiled binaries.
cd ..
if [ "${goos}" = "${gohostos}" -a "${goarch}" = "${gohostarch}" ]; then
    # cross-compile for local system. nothing to copy.
    # useful if you've bootstrapped yourself but want to
    # prepare a clean toolchain for others.
    true
else
	mv bin/*_*/* bin
	rmdir bin/*_*
	rm -rf "pkg/${gohostos}_${gohostarch}" "pkg/tool/${gohostos}_${gohostarch}"
fi

# Fetch git revision before rm -rf .git.
GITREV=$(git describe --tags HEAD)

OUTXZ="go-${GOOS}-${GOARCH}${GOARM}-${GITREV}.tar.xz"
echo "Preparing to generate ${OUTXZ}; cleaning ..."
rm -rf bin/gofmt
rm -rf src/runtime/race/race_*.syso
rm -rf api test doc misc/cgo/test misc/trace
rm -rf pkg/bootstrap pkg/obj .git .gitignore .github
rm -rf .gitattributes favicon.ico robots.txt
rm -rf pkg/tool/*_*/{addr2line,api,cgo,cover,doc,fix,nm,objdump,pack,pprof,test2json,trace,vet}
rm -rf pkg/*_*/{image,database,cmd}
rm -rf $(find . -type d -name testdata)
find . -type f -name '*_test.go' -exec rm {} \;

echo "Writing ${OUTXZ} ..."
cd ..
tar cf - "${tgt}" | xz -9 > ${OUTXZ}
ls -l "$(pwd)/${OUTXZ}"
echo

exit 0
