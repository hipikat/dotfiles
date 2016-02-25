#!/bin/bash
#pkginstalls.sh
#creates text file with a list of all packages installed by date

#first append all info from archived logs

i=2
mycount=$(ls -l /var/log/dpkg.log.*.gz | wc -l)
nlogs=$(( $mycount + 1 ))

while [ $i -le $nlogs ]
do
if [ -e /var/log/dpkg.log.$i.gz ]; then
zcat /var/log/dpkg.log.$i.gz | grep "\ install\ " >> $HOME/pkgtmp.txt
fi
i=$(( $i+1 ))

done

#next append all info from unarchived logs

i=1
nulogs=$(ls -l /var/log/dpkg.log.* | wc -l)
nulogs=$(( $nulogs - $nlogs + 1 ))
while [ $i -le $nulogs ]
do
if [ -e /var/log/dpkg.log.$i ]; then
cat /var/log/dpkg.log.$i | grep "\ install\ " >> $HOME/pkgtmp.txt
fi
i=$(( $i+1 ))

done

#next append current log

cat /var/log/dpkg.log | grep "\ install\ " >> $HOME/pkgtmp.txt

#sort text file by date

sort -n $HOME/pkgtmp.txt > $HOME/pkginstalls.txt

rm $HOME/pkgtmp.txt

exit 0
