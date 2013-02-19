@echo off

if EXIST Built\build.ninja GOTO DoBuild
Make.pl

:DoBuild
pushd Built
ninja %*
popd

