#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5SRULE
#EINRGUISCRIPT###
#!/bin/bash
#
### HDRSection ##
#*******************************************************************************
# Filename  : statRinex
# Purpose   : Check each 15minutes windows of a 15s daily RINEX
# Input     : year      : with 4 digits
#           : doy number: with 0 padded or 'doy numbers list'
#           : section   : the section code (e.g.: 1)
#           : site      : or site list protected by "aaaa bbbb"
#           : flag      : to activate a tip or '' to deactivate it
# Output    : ASCII graph on stdout
# Author    : rgui g3osytemx
# ToDo      :  1. Improve the menu of options and capture user input
# Dependency: CHK: awk, date, grep, md5sum, sed, tail
#           : COD: awk, crx2rnx, date, grep, stty, teqc, tput, unzip
# Bugs      : So far are unknown
# Version   : 0.0.3 - Check for dependencies
#           : 0.0.2 - Buffer string to reduce size
#           : 0.0.1 - Initial idea and code
# LastUpdate: 2022.05.11Z06:56:17 *
#*******************************************************************************
#
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5....|
### INISection ##
#   Section that contains all global definitions not related to core script
#------------------------------------------------------------------------------
scrFName=$0; if [ ! -e ${scrFName} ]; then echo "${scrFName} lost"; exit 1; fi
dependencyList="awk cat crx2rnx cut date grep sed seq sha256sum sleep tail \
                teqc tput unzip wc"

# Get the terminal dimensions, set global variables TERMLINES and TERMCOLUMNS
# declare arr=( $(stty size) ); TERMLINES=${arr[0]}; TERMCOLUMNS=${arr[1]};
read -r TERMLINES TERMCOLUMNS < <(stty size)

lblInfo="[\033[1;30mINFO\033[0m]";  lbl_OK_="[\033[1;32m.OK.\033[0m]"
lblErro="[\033[1;31mERRO\033[0m]";  lblWarn="[\033[1;34mWARN\033[0m]"
lblStop="[\033[1;35mSTOP\033[0m]";  lblTimg="[\033[1;37mTIMG\033[0m]"

#
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5....|
### FUNSection ##
#   Section with all generic functions
#------------------------------------------------------------------------------
#
#------------------------------------------------------------------------------
# Function  : checkDependencyList
# Purpose   : Check for dependencies
# Input     : A list of program names
# Output    : Print on the stderr the status. In case a dependency is not found
#           : abort the script
#------------------------------------------------------------------------------
function checkDependencyList {
  local depList=$1;
  local dependenciesFound=""
  for dependency in ${depList}; do
    result=$(which ${dependency})
    local retCode=$?
    if [ ${retCode} -eq 0 ]; then
      dependenciesFound="${dependenciesFound}${dependency} "
    else
>&2 echo -e "${lblErro} ${dependency} dependency not found"
      exit 1
    fi
  done
>&2 echo -e "${lbl_OK_} ${dependenciesFound}"
}
#-------------------------------------------------------------------------------
# Function  : outputHzSectionSeparator
# Purpose   : Print a horizontal separator (from the first to the last column)
# Input     : None
# Output    : A hardcoded separator is "."
#-------------------------------------------------------------------------------
function outputHzSectionSeparator {
  separator=".";   yes ${separator} | head -n$(($(tput cols))) | tr -d '\n'
}
#
#-------------------------------------------------------------------------------
# Function  : outputVtSectionSeparator
# Purpose   : Print a vertical separator (from them first line to the last line)
# Input     : None
# Output    : A hardcoded separator is "."
#-------------------------------------------------------------------------------
function outputVtSectionSeparator {
  separator="."; yes ${separator} | head -n$(($(tput lines)))
}
#
#-------------------------------------------------------------------------------
# Function  : fillScreen
# Purpose   : Fill all screen with a predefined symbol
# Input     : None
# Output    : A hardcoded symbol is "."
# Vulnerab. : eval is the evil
#-------------------------------------------------------------------------------
function fillScreen {
  echo "Screen size: cols: ${TERMCOLUMNS}  lines: ${TERMLINES}"
  #  totalBytesOnScreen=$(( ${TERMCOLUMNS} * ${TERMLINES} ))
  eval printf '=%.0s' {1..$[$TERMCOLUMNS*$TERMLINES]}
}
#
#-------------------------------------------------------------------------------
# Function  : printTip
# Purpose   : Print a tip
# Input     : Null or 1 parameter
# Output    : A hardcoded tip
#-------------------------------------------------------------------------------
function printTip {
# Print a tip on stderr
# Takes advantage of all defined variables
  txtBuff="Download it from wget --verbose --continue --no-passive-ftp "
# !Never save user:password in a script. Retrieve it for a external db instead!
  txtBuff=${txtBuff}"--user=anonymous --password=login@domain.com "
  txtBuff=${txtBuff}"ftp://geoftp.ibge.gov.br/"
  txtBuff=${txtBuff}"informacoes_sobre_posicionamento_geodesico/rbmc/dados/"
  txtBuff=${txtBuff}"${year}/${doy}/${zipFName}"
  if [ $# -eq 1 ]; then
    # Print to error    output
    >&2 echo "${txtBuff}";
#  else
#    # Print to standard output
#    echo "${txtBuff}";
  fi
}
#
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5....|
### CHKSection ##
#   Section with a special routine to chech the checksum of the script
#------------------------------------------------------------------------------
#fillScreen
checkDependencyList "${dependencyList}"
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
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5....|
### DATSection ##
#   Section where is declared all global variables and its content
#------------------------------------------------------------------------------
if [ $# -gt 4 ]; then
  year=$1;  doys=$2;  section=$3;  sites=$4;  flag4tip=$5
else
  if [ $# -le 4 ]; then
    echo "Usage: $0 yyyy|'years' doy|'doys' section site|'sites' 'flag'"
    echo ""; exit 1
#  else
#    echo "Provide at least one argument"; exit 1
  fi
fi
# Number of items in the "sites" variable
nsites=( $(echo ${sites} | wc) )
nsites=${nsites[1]}

# Dont change it
hours="00 01 02 03 04 05 06 07 08 09 10 11 12 \
       13 14 15 16 17 18 19 20 21 22 23"
minutes="00 15 30 45"

#
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5....|
### CODSection ##
#   Section where all main code is declared
#------------------------------------------------------------------------------
iniScrTime=$(date +'%s.%N')
#for year in ${years}; do
  for doy in ${doys}; do
    for site in ${sites}; do
      iniTime=$(date +'%s.%N')
      baseFName=${site}${doy}${section};   zipFName=${baseFName}.zip
      crxFName=${baseFName}.${year:2}d;    rnxFName=${baseFName}.${year:2}o

      echo -ne "${rnxFName} "
      if [ -e ${zipFName} ]; then
#       echo "unzip -p ${zipFName} ${crxFName} | crx2rnx > ${rnxFName}"
        unzip -p ${zipFName} ${crxFName} | crx2rnx > ${rnxFName}
      else
        printTip ${flag4tip}
        txtBuff="---- ---- ---- ---- ---- ---- ---- ---- "
        echo -ne "${txtBuff}${txtBuff}${txtBuff}"
        endTime=$(date +'%s.%N')
        echo  ${endTime} ${iniTime} | awk '{printf("%10.3f\n", $1-$2)}';
        continue
      fi

      for hh in ${hours}; do
        for mm in ${minutes}; do
          echo -ne $(teqc +qc -plot -report -R -E -C -S -O.int 15 \
               -st ${hh}${mm}00 \
               -e ${hh}$((${mm}+14))45 ${rnxFName} 2> /dev/null | grep \
               -e '\(^Epochs w/ observations  :\|Poss. . of obs epochs   :\)' \
               | cut -d':' -f2) \
               | awk '{total=100*$2/$1;printf("%s",(total>=100)?"#":"-")}'
        done
        echo -ne " "
      done
      rm ${rnxFName}
      endTime=$(date +'%s.%N');
      echo ${endTime} ${iniTime} | awk '{printf("%10.3f\n", $1-$2)}'
    done
  done
#done
#
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5....|
### ENDSection ##
#   Section with the ending information to present when the script finishes
#------------------------------------------------------------------------------
endScrTime=$(date +'%s.%N');
echo ${endScrTime} ${iniScrTime} | awk '{printf("\nENDE: %10.3f s\n", $1-$2)}'
exit 0;
#
#AUSRGUISCRIPT###
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5ERULE
### SHASection ##
Hash: SHA256

770544f11af9c5b3bad974287854811b11d1b5edda7a5dc47c093ff80cde1725  -
Hash replaced automatically by sed at 2022.05.11Z06:56:17
#
