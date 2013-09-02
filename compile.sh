#!/bin/bash
rm -R release
mkdir release
filesdir=`pwd`
coffeepath=`which coffee`
find ./ \( ! -path '*/.*' \) | while read a
do 
	filename="${a:3}"
	isExcluded=`echo $filename | egrep "node_modules|^\.|^test|^release|^samples"`
	if [[ -z $isExcluded ]] && [[ -n $filename ]]
	then
		#filename="\"${filename}\""
		if [[ -d $filename ]]
		then
			mkdir release/$filename
		else
			isCoffee=`echo $filename | egrep "\.coffee$"`
			echo $filename
			if [[ -n $isCoffee ]]
			then
				dir=`dirname $filename`
				filepath="\"$filesdir/${filename}\""
				releasepath="\"$filesdir/release/${dir}\""
				cmd="$coffeepath -o $releasepath -c $filepath"
				eval $cmd
			else
				dir=`dirname $filename`
				filepath="\"$filesdir/${filename}\""
				releasepath="\"$filesdir/release/${dir}\""
				cmd="cp $filepath $releasepath"
				eval $cmd	
			fi
		fi
	fi
done
