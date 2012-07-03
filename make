#!/bin/bash

## change this for your application
NAME=SchemeOGL
PACKAGE=at.nexoid.schemeogl

## change this for your system
SDK=/opt/android-sdk/
PROGUARD=/usr/share/proguard/proguard.jar
KEYSTORE=/home/nex/.android/debug.keystore
KEYALIAS=androiddebugkey
KEYPASS=android
STOREPASS=android
KAWA=kawa/kawa-1.12.jar

## do not change below this line
PLATFORM=$SDK/platforms/android-14/
AAPT=$SDK/platform-tools/aapt
ADB=$SDK/platform-tools/adb
DX=$SDK/platform-tools/dx
AJAR=$PLATFORM/android.jar
PKRES=bin/resource.ap_
OUT=$NAME-unalign.apk
ALIGNOUT=$NAME.apk

if [ "$1" == "install" ] ;
then
echo Installing $Name
$ADB install -r bin/$NAME.apk
else


set -e #exit on error
rm -fR bin gen
mkdir -p bin/classes gen

$AAPT package -f -m -J gen -M AndroidManifest.xml -S res -A assets -I $AJAR -F $PKRES

echo Compiling Java
echo $(find -L . -name *.java)
javac -d bin/classes -classpath bin/classes -target 1.6 -source 1.6 -bootclasspath $AJAR -g  $(find -L . -name *.java)

echo Compiling Scheme
CLASSPATH=$KAWA:$AJAR:bin/classes/ java kawa.repl -d bin/classes -P ${PACKAGE}. --module-static-run --warn-undefined-variable --warn-unknown-member --warn-invoke-unknown-method --warn-as-error -C $(find src -name *.scm)


if [ "$1" == "debug" ] ;
then
#jar cf bin/obfuscated.jar -C kawa/ .
cp $KAWA bin/obfuscated.jar
jar -uf bin/obfuscated.jar -C bin/classes/ .
else
echo Running ProGuard
java -jar $PROGUARD @proguard.cfg
fi

echo Running Dex
echo $DX --dex --output=bin/classes.dex bin/obfuscated.jar
$DX --dex --output=bin/classes.dex bin/obfuscated.jar

echo Building Package
java -Xmx128M -classpath "$SDK/tools/lib/sdklib.jar" com.android.sdklib.build.ApkBuilderMain bin/$OUT -u -z $PKRES -f bin/classes.dex
#apkbuilder 

echo Signing Jar
jarsigner -sigalg MD5withRSA -digestalg SHA1 -keystore $KEYSTORE -storepass $STOREPASS -keypass $KEYPASS bin/$OUT $KEYALIAS

echo Aligning Zip
echo zipalign -f 4 bin/$OUT bin/$ALIGNOUT
"$SDK/tools/zipalign" -f 4 bin/$OUT bin/$ALIGNOUT
fi
