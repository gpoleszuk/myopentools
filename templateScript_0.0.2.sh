#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5SRULE
#EINRGUISCRIPT###
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
# Bugs      : dependencies are not checked
# Version   : 0.0.2 - Auto update the "^# LastUpdate: " field
#           : 0.0.1 - Initial idea and code
# LastUpdate: 2022.05.03Z22:07:12 *
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
  echo "Bad checksum. Replaced it [Y/N]?";
  read replaceCheckSum
  if [ "${replaceCheckSum}" == "Y" ]; then
    oldCheckSum=$(grep '^###.SHASection.##$' -A      3 ${scrFName} | tail -1  )
    timeStampS=$(date -u +'%Y.%m.%dZ%H:%M:%S')
    sed -i "/^# LastUpdate: /c\# LastUpdate: ${timeStampS} *" ${scrFName}
    newCheckSum=$(grep "....5ERULE$"         -B 999999 ${scrFName} | sha256sum)
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
### ENDSection ##
echo "ENDE"; exit 0;
#
#ENDRGUISCRIPT###
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5ERULE
### SHASection ##
Hash: SHA256

e97309f7b9d4bc871f1c8fd2ab21de73f6fa0efcf2a14deb63de55277346e608  -
Hash replaced automatically by sed at 2022.05.03Z22:07:12
#
