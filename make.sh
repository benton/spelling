#!/usr/bin/env bash
# builds on OS X
set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace

pdir=`cd $(dirname "$0") && pwd`
url='https://github.com/gosu/ruby-app/releases/latest'

if ! [ -f "$pdir/build/Ruby.app.zip" ] ; then 
	echo "ERROR: First, download Ruby.app.zip into build, from $url"
  exit 1
fi
rm -rf "$pdir/build/MES Spelling Trainer.app"
unzip "$pdir/build/Ruby.app.zip" -d "$pdir/build" >/dev/null
mv "$pdir/build/Ruby.app" "$pdir/build/MES Spelling Trainer.app" 
cp -v Info.plist "$pdir/build/MES Spelling Trainer.app/Contents"
cp -vr *.rb data "$pdir/build/MES Spelling Trainer.app/Contents/Resources"
ls -lt build/
echo "Done buliding. To run:"
echo "   open '$pdir/build/MES Spelling Trainer.app'"
