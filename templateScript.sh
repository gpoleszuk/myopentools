#...5....|....5....|....5....|....5....|....5....|....5....|....5....|....5SRULE
#EINRGUISCRIPT
#!/bin/bash
#
### HDRSection ##
#*******************************************************************************
# Filename  : templateScript.sh
# Purpose   : A template with some lines
# Input     : none
# Output    : none
# Author    : rgui g3osytemx
# ToDo      :  1. check if all dependencies are solved
#           :  2. update the "LastUpdate" field automatically
# Bugs      : dependencies are not checked
# Version   : 0.0.1
# LastUpdate: 03May2022 21:06:19Z
#*******************************************************************************
#
### INISection ##
scrFName=$0; if [ ! -e ${scrFName} ]; then echo "${scrFName} lost"; exit 1; fi
#
### FUNSection ##
function doSomeThing {
  inputVar=$1;
  echo "${inputVar}";
}
#
### CHKSection ##
shaopts="--status --check"
grep "....5ERULE$"   -B 999999   ${scrFName} | sha256sum ${shaopts} ${scrFName}
if [ $? -eq 0 ]; then
  echo "Checksum OK";
else
  oldCheckSum=$(grep '^###.SHASection.##$' -A      3 ${scrFName} | tail -1  )
  newCheckSum=$(grep "....5ERULE$"         -B 999999 ${scrFName} | sha256sum)
  echo "Bad checksum. Replaced it [Y/N]?";
  read replaceCheckSum
  if [ "${replaceCheckSum}" == "Y" ]; then
    timeStampS=$(date -u +"%Y%m%dT%H%M%SZ")
    addAutoMsg="\nHash replaced automatically by sed at ${timeStampS}"
    sed -i "s/${oldCheckSum}/${newCheckSum}${addAutoMsg}/g" ${scrFName}
  else
    echo "Script aborted."; exit 1;
  fi
fi
#
### DATSection ##
someVariable=0
#
### CODSection ##
doSomeThing ${someVariable}
#
#ENDRGUISCRIPT
echo "ENDE"; exit 0;
#...5....|....5....|....5....|....5....|....5....|....5....|....5....|....5ERULE
### SHASection ##
Hash: SHA256

cd50a9e8ffcb69038439a1222ec877368dea347af3d7ecc3d859f2ad197a2cb5  -
#
