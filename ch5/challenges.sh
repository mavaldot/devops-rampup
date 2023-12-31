#!/bin/bash

#Display only the even numbers from 1 to 100.

for i in {1..100}; do
    if [[ $(( $i % 2 )) -eq 0 ]]; then
        echo $i
    fi
done

#Compare natural numbers and display "X is greater than Y", "X is equal to Y" or "X is less than Y".

read -p "Enter x: " x
read -p "Enter y: " y

if [[ x -gt y ]]; then
	echo "X is greater than Y"
elif [[ x -lt y ]]; then
	echo "X is less than Y"
else
	echo "X is equal to Y"
fi

#Read N numbers from the stdio and compute their average.

read -p "Please enter N: " x
total=0
div=$x
avg=0

while (( x > 0 )); do
	read -p "Please a number: " y
	((total+=y))
	(( x-- ))
done

if (( div > 0 )); then
	avg=$((total/div))
fi

echo "Average: $avg"

#Check if a file exists, if it doesn't exist, create it.

read -p "Please enter the file name: " file
if [ -f $file ]; then
	echo "The file already exists!"
else
	touch $file
	echo "The file $file has been created!"
fi

#Write a script that outputs the current time and date. For example: "Current time: 08:02, Current date: 2022-08-10"

t=`date +"%T"`
d=`date +"%Y-%m-%d"`
echo "Current time: $t, Current date: $d"

#Write a script that prints how many parameters are passed and which ones? For example, if I run the script like this: ./script1 p1 p2 p3 p4, then it should print: 4 params were passed and they're these ones: p1, p2, p3, p4

echo "$# arguments were passed and they're these ones: $@"

#Write a script that prints information about your OS and version, release number, and kernel version.

uname -sr
lsb_release -d
uname -v

#Write a script that checks if cups service is running. If it running, print "Cups' status is running". Otherwise, prints "Cups's status is stopped".

ps aux | grep -v grep | grep cups 1>/dev/null 2>/dev/null
if [ $? -eq 0 ]; then
	echo "Cups's status is running"
else
	echo "Cups's status is stopped"
fi