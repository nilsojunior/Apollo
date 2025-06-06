#!/usr/bin/env bash

set -e

NAME=$1

rm -f *.java *.class

jflex "$NAME.flex"
java java_cup.Main "$NAME.cup"
javac *.java
