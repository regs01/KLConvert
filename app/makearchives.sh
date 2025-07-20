#!/bin/bash

(( $# <> 1  )) && exit

script=$(realpath "$0")
basedir=$(dirname "$script")
releasecompiledir="$basedir/.releasecompile"
version="$1"
mkdir "archives"

function copyfile
{
  local sourcefile="$1"
  local destdir="$2"
  echo  "cp $sourcefile $destdir"
  mkdir -p "$destdir"
  cp $sourcefile $destdir || { echo 'Error copying files' ; exit 1; }
}

function makearchive
{

  local release="$1"

  rm -rf $releasecompiledir
  mkdir -p $releasecompiledir

  copyfile "./../bin/release/$release/klconvert" "$releasecompiledir/usr/bin"
  copyfile "./../res/icons/hicolor/16x16/apps/klconvert.png" "$releasecompiledir/usr/share/icons/hicolor/16x16/apps"
  copyfile "./../res/icons/hicolor/24x24/apps/klconvert.png" "$releasecompiledir/usr/share/icons/hicolor/24x24/apps"
  copyfile "./../res/icons/hicolor/32x32/apps/klconvert.png" "$releasecompiledir/usr/share/icons/hicolor/32x32/apps"
  copyfile "./../res/icons/hicolor/48x48/apps/klconvert.png" "$releasecompiledir/usr/share/icons/hicolor/48x48/apps"
  copyfile "./../res/icons/hicolor/64x64/apps/klconvert.png" "$releasecompiledir/usr/share/icons/hicolor/64x64/apps"
  copyfile "./../res/icons/hicolor/256x256/apps/klconvert.png" "$releasecompiledir/usr/share/icons/hicolor/256x256/apps"
  copyfile "./../res/icons/hicolor/scalable/apps/klconvert.svg" "$releasecompiledir/usr/share/icons/hicolor/scalable/apps"
  copyfile "./klconvert.desktop" "$releasecompiledir/usr/share/applications"

  cd $releasecompiledir
  echo "Packing $release..."
  XZ_OPT="-e" tar -cJf $basedir/archives/klconvert_${release}_${version}.txz ./
  cd ..
  rm -rf $releasecompiledir

}

makearchive "linux-x86_64-gtk2"
makearchive "linux-x86_64-qt5"
makearchive "linux-x86_64-qt6"

makearchive "linux-aarch64-gtk2"
makearchive "linux-aarch64-qt5"
makearchive "linux-aarch64-qt6"

makearchive "freebsd-x86_64-gtk2"
makearchive "freebsd-x86_64-qt5"
makearchive "freebsd-x86_64-qt6"

makearchive "freebsd-aarch64-gtk2"
makearchive "freebsd-aarch64-qt5"
makearchive "freebsd-aarch64-qt6"

makearchive "linux-loongarch64-gtk2"
makearchive "linux-loongarch64-qt6"

makearchive "linux-riscv64-gtk2"
makearchive "linux-riscv64-qt6"
