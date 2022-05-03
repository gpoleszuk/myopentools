#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5SRULE
#EINRGUISCRIPT###
#!/bin/bash
#
### HDRSection ##
#*******************************************************************************
# Filename  : printable.sh
# Purpose   : Print some printable chars and its hex codes
# Input     : none
# Output    : printable chars between 20 to 127 ASCII chars
# Author    : rgui g3osytemx
# ToDo      :  0.
# Bugs      : Chr(127) does not print an ASCII char on screen
# Version   : 0.0.1
# LastUpdate: 2022.05.03Z22:10:52 *
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
bfStrHex=""; bfStrChr=""; c=0;
#
### CODSection ##
for d in 1 2 3 4 5 6 7; do
  for u in 0 1 2 3 4 5 6 7 8 9 A B C D E F; do
    c=$((${c}+1)); if [ ${c} -gt 16 ]; then
      bfStrHex="${bfStrHex}${d}${u} "; bfStrChr="${bfStrChr} \\x${d}${u} "
    fi;
    m=$((${c}%10)); if [ ${m} -eq 0 ]; then
      bfStrHex="${bfStrHex}\\x0a"; bfStrChr="${bfStrChr}\\x0a"
    fi;
  done;
done;
echo -ne "${bfStrHex}${bfStrChr}\\x0AENDE\\x0A"; exit 0;
#
### ENDSection ##
echo "ENDE"; exit 0;
#
#ENDRGUISCRIPT
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5ERULE
### SHASection ##
Hash: SHA256

eaa96d639c7a2ebfdac0de3aaaa969bd9cfe03194e67795a98328da1f339d8e6  -
Hash replaced automatically by sed at 2022.05.03Z22:10:52
#
