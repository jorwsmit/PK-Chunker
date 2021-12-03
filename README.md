# PK Chuker

## Features

- Automatically initiate bulk API jobs in Salesforce
- query large ammounts of data and export them into csv files

## Installation: _Ensure script is executable_

- cd into directory with pk_chunker.sh
- chmod +x to the script

```sh
cd /PK\ Chunker/pk_chunker.sh
chmod +x pk_chunker.sh
```

## Usage

###### Get Session Id

- Log into Salesforce
- Open developer console
- Degub log the reversed session Id
  `SYSTEM.DEBUG('Session Id : '+Userinfo.getSessionId().reverse()); `
- Reverse the session Id with Excel
  `=CONCAT(MID(A1,SEQUENCE(LEN(A1),,LEN(A1),-1),1)) `

###### Run the PK Chunker

- Open up terminal
- CD into the directory
- Run the chunker

```sh
cd /PK\ Chunker/pk_chunker.sh
./pk_chunker.sh
Enter your session Id
*** Paste in a valid session Id ***
Enter your org domain (examples: kah--qa, kah, kah--hhdev, kah2)
*** Type in an org domain (i.e. kah) ***
```
