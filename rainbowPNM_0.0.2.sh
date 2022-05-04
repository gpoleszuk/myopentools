#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5SRULE
#EINRGUISCRIPT###
#!/bin/bash
#
### HDRSection ##
#*******************************************************************************
# Filename  : rainbowPNM.sh
# Purpose   : Create a rainbow PNM file
# Input     : none
# Output    : print the stream on standard output
# Author    : rgui g3osytemx
# ToDo      :  1. check if all dependencies are solved
#              2. implement the main algorithm in C since it is more efficient
#                 Start: 2022.05.04Z01:55:11
#                 End  : 2022.05.04Z02:01:45    It takes 06:34 on i5
# Bugs      : dependencies are not checked
# Version   : 0.0.2 - Use a vector with all bytes instead nibles
#           : 0.0.1 - Initial idea and code
# LastUpdate: 2022.05.04Z02:26:09 *
#*******************************************************************************
#
### INISection ##
scrFName=$0; if [ ! -e ${scrFName} ]; then echo "${scrFName} lost"; exit 1; fi
#
### FUNSection ##
# -----------------------------------------------------------------------------
function doSeparator {
  if [ $# -ge 1 ]; then maxValue=$1; else maxValue=0; fi
  if [ $# -ge 2 ]; then char=$2; else char="="; fi
#  strBuffer="\\x0A"
  local strBuff=""
  for iter in $(seq 1 1 ${maxValue}); do
    local strBuffer="${strBuffer}${char}";
  done;
#  echo -ne "${strBuffer}"
  echo -ne "${strBuffer}\\x0A"
}
#
# -----------------------------------------------------------------------------
function doPNMhdr {
  if [ $# -ge 1 ]; then width=$1;  else width=1;   fi
  if [ $# -ge 2 ]; then height=$2; else height=1;  fi
  if [ $# -eq 3 ]; then pnmt=$3;   else pnmt="P5"; fi
  echo -ne "${pnmt}\\x0A${width}\\x20${height}\\x0A255\\x0A"
}
#
# -----------------------------------------------------------------------------
function printTimeStamp2StdError {
#>&2 echo "$(date -u +'%Y.%m.%dZ%H:%M:%S')"
#  echo "$(date -u +'%Y.%m.%dZ%H:%M:%S')" >> /dev/stderr
  echo "$(date -u +'%Y.%m.%dZ%H:%M:%S')" >&2
}
# -----------------------------------------------------------------------------
#
### CHKSection ##
shaopts="--status --check"
grep "....5ERULE$"   -B 999999   ${scrFName} | sha256sum ${shaopts} ${scrFName}
if [ $? -eq 0 ]; then
  echo "Checksum OK" >&2;
else
  echo -ne "Bad checksum. Replaced it [Y/N]?: " >&2;
  read replaceCheckSum
  if [ "${replaceCheckSum}" == "Y" ]; then
    oldCheckSum=$(grep '^###.SHASection.##$' -A      3 ${scrFName} | tail -1  )
    timeStampS=$(date -u +'%Y.%m.%dZ%H:%M:%S')
    sed -i "/^# LastUpdate: /c\# LastUpdate: ${timeStampS} *" ${scrFName}
    newCheckSum=$(grep "....5ERULE$"         -B 999999 ${scrFName} | sha256sum)
    addAutoMsg="\nHash replaced automatically by sed at ${timeStampS}"
    sed -i "s/${oldCheckSum}/${newCheckSum}${addAutoMsg}/g" ${scrFName}
  else
    echo "Script aborted." >&2; exit 1;
  fi
fi
#
### DATSection ##
someVariable=40
color="B"
hexAlg="0 1 2 3 4 5 6 7 8 9 A B C D E F";
#
### CODSection ##
# All messages to std output was supressed since from std output comes the
# binary stream of a PNM image
#doSeparator 40 '*'
>&2 echo "Starting in 5 seconds for ${color}"
sleep 5
printTimeStamp2StdError
#
# Create vector with all bytes
hexBytes=""
for ch2 in ${hexAlg}; do
  for ch1 in ${hexAlg}; do
    hexBytes="${hexBytes} ${ch2}${ch1}";
  done;
done;

if [ "${color}" == "B" ]; then
  doPNMhdr 16 16 "P5"
  strBuff=""
  for tone in ${hexBytes}; do
    strBuff="${strBuff}\\x${tone}";
  done;
  echo -ne "${strBuff}"
fi

if [ "${color}" == "C" ]; then
  doPNMhdr 4096 4096 "P6"
  for red in ${hexBytes}; do
    for green in ${hexBytes}; do
      clrBuff=""
      for blue in ${hexBytes}; do
        clrBuff="${clrBuff}\\x${red}\\x${green}\\x${blue}";
      done;
      echo -ne "${clrBuff}"
    done;
  done;
fi
#doSeparator 40 '*'
printTimeStamp2StdError
>&2 echo "Tip: type it on command line (check dependencies first!)"
>&2 echo "pnmtopng -verbose -compression 0 pnmFile.png > pngFile.png"
#
### ENDSection ##
#echo "ENDE"; exit 0;
>&2 echo "ENDE"; exit 0;
#
#ENDRGUISCRIPT###
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5ERULE
### SHASection ##
Hash: SHA256

2c08a0c1dab6751e96442501cf430452f04857242e1a3cb4ad93f9e74995d99e  -
Hash replaced automatically by sed at 2022.05.04Z02:26:09
#
