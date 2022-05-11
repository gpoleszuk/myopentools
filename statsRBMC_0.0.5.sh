#-------------------------------------------------------------------------------
#              !!!!!!!   DON'T CHANGE THE NEXT 10 LINES   !!!!!!!
#-------------------------------------------------------------------------------
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5SRULE
#EINRGUISCRIPTEN###
#!/bin/bash
#
### HDRSection ##
#*******************************************************************************
# Filename  : statsRBMC.sh
# Purpose   : Create a listing file of IBGE GeoFTP related to RBMC RNX2 files
# Input     : none
# Output    : A structured listing on standard output and infos on stderr output
# Author    : rgui g3osytemx
# ToDo      : 1. recover the doys from FTP listing. It is more efficient
#           : 2. commentar for functions, explain them
#           : 3. include prn2err.sh code instead to call it '>&2 echo -ne "$1"'
# Dependency: CHK: date grep sed sha256sum tail
#           : COD: cat cut date ftp grep prn2err.sh seq
#           : COD: sleep* sort tail uniq wc
#           : * with ms resolution like usleep
# Vulnerab. : So far unknown
# Bugs      : 1. dependency list does not check the version of sleep (usleep)
#           : 2. does not check the username and password recovered from .netrc
# Version   : 0.0.5 - Removed unnecessary codes
#           : 0.0.4 - Now uses colors for labels
#           : 0.0.3 - Check dependencies before to start. Abort if not found
#           : 0.0.2 - Auto update the "^# LastUpdate: " field
#           : 0.0.1 - Initial idea and code
# LastUpdate: 2022.05.11Z06:14:21 *
#*******************************************************************************
#
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5....|
### INISection ##
scrFName=$0; if [ ! -e ${scrFName} ]; then echo "${scrFName} lost"; exit 1; fi
dependencyList="awk cat cut date grep ftp ping prn2err.sh \
                sed seq sha256sum sleep sort tail teqc uniq wc"
#doFTPlisting="YES"
doFTPlisting="NO"

lbl_OK_="[\033[1;32m.OK.\033[0m]"  ;lblErro="[\033[1;31mERRO\033[0m]"
lblWarn="[\033[1;34mWARN\033[0m]"  ;lblStop="[\033[1;35mSTOP\033[0m]"
lblTimg="[\033[1;37mTIMG\033[0m]"
#
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5....|
### FUNSection ##
#   Section with all generic functions
#------------------------------------------------------------------------------
# Do nothing!
#------------------------------------------------------------------------------
function doSomeThing {
  inputVar=$1; echo "${inputVar}";
}
#------------------------------------------------------------------------------
# Check for dependencies
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
#------------------------------------------------------------------------------
# Check for internet connection
#------------------------------------------------------------------------------
function checkInternetConnection {
  ping -a -c 1 -W 2 8.8.4.4 > /dev/null 2> /dev/null
  local retCode=$?
  if [ ${retCode} -eq 0 ]; then
>&2 echo "[INFO] Internet is up"
    return ${retCode}
  else
>&2 echo -e "[\033[1;31mERRO\033[0m] Internet is down"
    return ${retCode}
  fi
}
#------------------------------------------------------------------------------
# Print the progress char
#------------------------------------------------------------------------------
function progressChar {
  local itemNumber=$1;  local progressChars=('/' '-' '\' '|');
  local i=$((${itemNumber}%${#progressChars[@]}));
  echo "[${progressChars[${i}]}]";
}
#------------------------------------------------------------------------------
# Generate an animated counter
#------------------------------------------------------------------------------
function progressBar {
  local maxIterations=$1;  local progressChars=('/' '-' '\' '|');
  for iteration in $(seq 0 1 ${maxIterations}); do
    local i=$((${iteration}%${#progressChars[@]}));
>&2 echo -ne "$(progressChar ${i}) ${iteration}\\x0d"
    sleep .1;
  done;  echo ""
}
#
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5....|
### CHKSection ##
#   Section with a special routine to chech the checksum of the script
#------------------------------------------------------------------------------
checkDependencyList "${dependencyList}"

shaopts="--status --check"
grep "....5ERULE$"   -B 999999   ${scrFName} | sha256sum ${shaopts} ${scrFName}
if [ $? -eq 0 ]; then
>&2  echo "[CHKS] Checksum OK";
else
>&2  echo -ne "[CHKS] Bad checksum. Replaced it [Y/N]? ";
  read replaceCheckSum
  if [ "${replaceCheckSum}" == "Y" ]; then
    oldCheckSum=$(grep '^###.SHASection.##$' -A      3 ${scrFName} | tail -1  )
    timeStampS=$(date -u +'%Y.%m.%dZ%H:%M:%S')
    sed -i "/^# LastUpdate: /c\# LastUpdate: ${timeStampS} *" ${scrFName}
    newCheckSum=$(grep "....5ERULE$"         -B 999999 ${scrFName} | sha256sum)
    addAutoMsg="\nHash replaced automatically by sed at ${timeStampS}"
    sed -i "s/${oldCheckSum}/${newCheckSum}${addAutoMsg}/g" ${scrFName}
  else
>&2    echo "[CHKS] Script aborted."; exit 1;
  fi
fi
#
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5....|
### DATSection ##
#   Section where is declared all global variables and its content
#------------------------------------------------------------------------------
ftpServer=geoftp.ibge.gov.br
if [ -e ~/.netrc ]; then
>&2 echo "[INFO] .netrc found."
# There is a potential bug here case .netrc does not contains the credentials
  username=$(grep "geoftp.ibge.gov.br" ~/.netrc | cut -d' ' -f4)
  password=$(grep "geoftp.ibge.gov.br" ~/.netrc | cut -d' ' -f6)
else
>&2 echo -e "${lblWarn} .netrc not found."
>&2 echo -e "${lblWarn} Setting a username as anonymous and a password to FTP client";
  username=anonymous
  password=anonymous@domain.tld
fi
# This site list contains all site identifiers, one per line
siteListFile=sitelist.txt

#years=$(seq -f"%04.0f" 2010 1 2022)
years=2022
for year in ${years}; do
  startTimeStamp=$(date +"%s.%N")
>&2   echo -e "${lblTimg} StartTimeStamp  : ${startTimeStamp}"
>&2   echo "[INFO] --.---------.---------.---------.---------.---------.---------.---------."
  minDoyToStart=1
  maxDoyPerYear=129
  if [ ${maxDoyPerYear} -eq 365 ]; then
    if [ $((${year}%4)) -eq 0 ]; then
      maxDoyPerYear=366
    else
      maxDoyPerYear=365
    fi
  fi
>&2   echo "[INFO] ${year} ${maxDoyPerYear}"
  sleep 1

  commandFile=ftpComandList_${year}_${minDoyToStart}_${maxDoyPerYear}.txt
  rbmcFileList=filelist_${year}_${minDoyToStart}_${maxDoyPerYear}.txt
#
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5....|
### CODSection ##
#   Section where all main code is declared
#------------------------------------------------------------------------------
#
#----------------------------------------------------------------------
# Create a file with commands for FTP client
# ToDo: How to pack it better
#----------------------------------------------------------------------
  if [ -e ${commandFile} ]; then
>&2     echo "[INFO] ${commandFile} exists."
  else
>&2     echo "[INFO] ${commandFile} does not exist. Creating it..."
    echo -ne ""     >  ${commandFile}

    echo "user ${username} ${password}" >> ${commandFile}
    echo "rhelp"    >> ${commandFile}
    echo "status"   >> ${commandFile}
    echo "rstatus"  >> ${commandFile}
    echo "mode"     >> ${commandFile}
    echo "ls"       >> ${commandFile}
    echo "cd informacoes_sobre_posicionamento_geodesico" >> ${commandFile}
    echo "ls"       >> ${commandFile}
    echo "cd rbmc"  >> ${commandFile}
    echo "ls"       >> ${commandFile}
    echo "cd dados" >> ${commandFile}
    echo "ls"       >> ${commandFile}
    echo "cd ${year}" >> ${commandFile}
    echo "ls"       >> ${commandFile}
    ctr=0
    for doy in $(seq -f"%03.0f" ${minDoyToStart} 1 ${maxDoyPerYear}); do
      ctr=$((${ctr}+1))
      echo "!prn2err.sh '[INFO] ${doy}\\x0d'" >> ${commandFile}
      echo "ls ${doy}" >> ${commandFile}
      if [ $((${ctr} % 20)) -eq 0 ]
      then
        echo "!prn2err.sh '[INFO] ${doy}\\x0a'" >> ${commandFile}
        echo "!prn2err.sh '[INFO] Sleep 10 seconds...\\x0a'" >> ${commandFile}
        echo '!sleep 10' >> ${commandFile}
        echo 'pwd'       >> ${commandFile}
      else
        echo '!sleep 1' >> ${commandFile}
      fi
    done
    if [ -e ${commandFile} ]; then
      echo "bye" >> ${commandFile}
>&2   echo "[INFO] Done!"
    fi
  fi
#----------------------------------------------------------------------
# Create the FTP listing by using a FTP client. Be careful!!!
#----------------------------------------------------------------------
  if [ -e ${rbmcFileList} ]; then
>&2     echo "[INFO] ${rbmcFileList} exist. FTP listing is unnecessary"
  else
>&2     echo -ne "${lblWarn} ${rbmcFileList} does not exist. "
>&2     echo "Starting FTP listing ${ftpServer}..."
    if [ "${doFTPlisting}" == "YES" ]; then
>&2   echo -ne "${lblWarn} Proceed with FTP listing [Y/N]? ";
      read -t 5 doFTPlist
      if [ "${doFTPlist}" == "Y" ]; then
        checkInternetConnection
        retCode=$?
        if [ ${retCode} -eq 0 ]; then
          ftp -inv ${ftpServer} < ${commandFile} > ${rbmcFileList}
        else
>&2       echo -e "${lblErro} No internet connection! Script aborted";
          exit 1;
        fi
      else
>&2     echo ""
>&2     echo -ne "${lblErro} Timeout: Script aborted"
        exit 1;
      fi
      sleep 1
    else
      sleep 1
>&2   echo -e "${lblStop} FTP listing stopped. "
>&2   echo -e "${lblStop} This functionality was intentionally disabled."
>&2   echo -e "${lblStop} Change the key 'doFTPlisting' to 'YES' case it is really necessary!"
>&2   echo -e "${lblErro} Script aborted";
      exit 1; read; sleep 86400;
    fi
  fi
#----------------------------------------------------------------------
# Check if the ftp listing resulting contains the sequence of DoYs
# Case some DoY is not found, ask before to continue
#----------------------------------------------------------------------
>&2   echo "[INFO] Checking availability in the provided DOY sequence"
  ndoys=0;
  for doy in $(seq -f"%03.0f" ${minDoyToStart} 1 ${maxDoyPerYear}); do
    ndoy=$((${ndoy}+1))
    >&2 echo -ne "[INFO] $(progressChar ${ndoy}) ${ndoy}\\x0d";

    nFiles=$(grep "${doy}1.zip" ${rbmcFileList} | wc -l)
    if [ $? -eq 0 ]; then
      if [ ${nFiles} -eq 0 ]; then
>&2          echo -e "${lblWarn} ${doy}? "; read;
      fi
    fi
  done
>&2   echo "[INFO]"
#----------------------------------------------------------------------
# Check if the file containing a list of sites exists in the current
# folder. Otherwise, try to extract the site names from the resulting
# file from FTP query
#----------------------------------------------------------------------
>&2   echo "[INFO] Printing summary of data package availability"
  if [ -e ${siteListFile} ]; then
>&2     echo "[INFO] Sitelist file ${siteListFile} provided by user."
    sites=$(cat ${siteListFile})
  else
>&2     echo -ne "${lblWarn} Sitelist file ${siteListFile} does not exist. "
>&2     echo "Extracting it from report of year ${year}"
    sites=$(grep "....[0-3][0-9][0-9]1\.zip" ${rbmcFileList} | cut \
                                                        -c57-60 | sort | uniq )
  fi
>&2   echo -e "${lblTimg} PartialTimeStamp: $(date +'%s.%N')"
# ---------------------------------------------------------------------
# Count the number of sites and print the name of them on the terminal
# screen in blocks with 15 names
# ---------------------------------------------------------------------
  ctrSites=0; bufferString=""
  for site in ${sites}; do
    ctrSites=$((${ctrSites}+1))
    bufferString="${bufferString}${site} "
    if [ $(((${ctrSites})%15)) -eq 0 ]; then
>&2   echo "[INFO] ${bufferString}"
      bufferString=""
    fi
  done
>&2   echo "[INFO] Sites: ${bufferString}"
>&2   echo "[INFO] Total of sites in ${year}: ${ctrSites}"
# ---------------------------------------------------------------------
# Do the header of the ASCII graph, since it grows from top to bottom
# of the screen, with site names in the columns and doys in the rows
# ---------------------------------------------------------------------
  for char in 0 1 2 3; do
    echo -ne ">: .. ... : "
    for site in ${sites}; do echo -ne "${site:${char}:1}"; done
    echo " : ... : .........."
  done

  iteration=0
  for doy in $(seq -f"%03.0f" ${minDoyToStart} 1 ${maxDoyPerYear}); do
    if [ ! -e ${rbmcFileList} ]; then
>&2   echo -ne "${lblErro} ${rbmcFileList} disappeared!!! Aborting....";
      exit 1;
    fi;

    sitesFound=$(grep "${doy}1.zip" ${rbmcFileList} | cut -c57-60)
    echo -ne ">: ${year:2} ${doy} : "

    bufferFlags=""
    for site in ${sites}; do
      echo ${sitesFound} | grep "${site}" 2>&1 > /dev/null
      if [ $? -eq 0 ]; then
        bufferFlags=${bufferFlags}"#"
      else
        bufferFlags=${bufferFlags}"-"
      fi
    done

    sizeAwk=$(grep "....${doy}1.zip" ${rbmcFileList} | awk \
        'BEGIN{i=0; sum=0;}{i++;sum+=$5;} END{printf("%3d : %10d\n", i, sum)}')
    echo "${bufferFlags} : ${sizeAwk}"

    iteration=$((${iteration}+1));
>&2 echo -ne "[INFO] $(progressChar ${iteration}) ${iteration}\\x0d";
  done

#----------------------------------------------------------------------
# Evaluate the elapsed time to complete the task
#----------------------------------------------------------------------
  endTimeStamp=$(date +"%s.%N")
>&2   echo -e "${lblTimg} EndTimeStamp    : ${endTimeStamp}"
  elapsedTime=$(echo ${endTimeStamp} ${startTimeStamp} | awk \
                                                   '{printf("%20.9f", $1-$2)}')
>&2   echo -e "${lblTimg} ${year} :: It took ${elapsedTime} seconds to finish"
done
#----------------------------------------------------------------------
#
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5....|
### ENDSection ##
#   Section with the ending information to present when the script finishes
#------------------------------------------------------------------------------
>&2 echo "[INFO] ENDE"; exit 0
#
#-------------------------------------------------------------------------------
#    !!!!!!!   DON'T CHANGE THE 5 LINES AFTER #AUSRGUISCRIPTEN### TAG   !!!!!!!
#-------------------------------------------------------------------------------
#AUSRGUISCRIPTEN###
#...5....|....5...2|0...5....|....5...4|0...5....|....5...6|0...5....|....5ERULE
### SHASection ##
Hash: SHA256

c628ae9d4832ad08e51a1692853cff602fe8d711c340cbeda38d0d46996421e6  -
Hash replaced automatically by sed at 2022.05.11Z06:14:21
#
