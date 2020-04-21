#!/usr/bin/env bash

cd $(dirname $(realpath $0))

[ ! -f External.zip ]                \
    && echo "Copy External.zip here" \
    && exit 0

unzip -q External.zip \
    External/osx/nRF-Command-Line-Tools_*_OSX.tar \
    External/linux/am64/nRF-Command-Line-Tools_*_Linux-amd64.tar.gz \
    External/win/x64/nrfjprog.zip \
    External/win/x86/nrfjprog.zip \
    External/win/x64/IndividualInstallers.zip

pushd External > /dev/null

function join_by { local IFS="$1"; shift; echo "$*"; }

ver=(`ls osx/nRF-Command-Line-Tools_*_OSX.tar | cut -d _ -f 2,3,4 | sed 's/_/ /g'`)
version=$(join_by _ ${ver[*]})
dotVersion=$(join_by . ${ver[*]})

mv linux/am64 linux_x64
mv osx darwin_x64
mv win/x86 win32_ia32
mv win/x64 win32_x64
rm -r win linux

pushd darwin_x64 > /dev/null
tar xf nRF-Command-Line-Tools_*_OSX.tar *.tar$
rm nRF-Command-Line-Tools_*_OSX.tar
tar xf nRF-Command-Line-Tools_*.tar nrfjprog/
rm *.tar
popd > /dev/null

pushd linux_x64 > /dev/null
tar xzf nRF-Command-Line-Tools_*_Linux-amd64.tar.gz *.tar$
tar xf nRF-Command-Line-Tools_*.tar nrfjprog/
rm *.tar*
popd > /dev/null

for dir in win32_* ; do \
    pushd ${dir} > /dev/null
    unzip -q nrfjprog.zip -d nrfjprog
    rm nrfjprog.zip
    popd > /dev/null
done

rm */nrfjprog/*.manifest \
    */nrfjprog/*.ini \
    */nrfjprog/nrfjprog \
    */nrfjprog/nrfjprog.exe \
    */nrfjprog/nrfjprog_release_notes.txt \
    */nrfjprog/jlinkarm_*.lib \
    */nrfjprog/nrfjprog.lib \
    */nrfjprog/nrfdfu.lib

for dir in linux_x64 darwin_x64 win32_* ; do
    pushd ${dir} > /dev/null
    tar cf ../../nrfjprog-${dotVersion}-${dir}.tar.gz nrfjprog
    popd > /dev/null
done

popd > /dev/null

unzip External/win32_x64/IndividualInstallers.zip JLink_Windows_*.exe

rm -r External

for artifact in nrfjprog-${dotVersion}-*.tar.gz JLink_Windows_*.exe ; do
    md5sum ${artifact} > ${artifact}.md5
done
