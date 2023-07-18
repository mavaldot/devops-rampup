#Display only the even numbers from 1 to 100.

for i in {1..100}; do
    if [[ $(( $i % 2 )) -eq 0 ]]; then
        echo $i
    fi
done

#Compare natural numbers and display "X is greater than Y", "X is equal to Y" or "X is less than Y".


#Read N numbers from the stdio and compute their average.


#Check if a file exists, if it doesn't exist, create it.


#Write a script that outputs the current time and date. For example: "Current time: 08:02, Current date: 2022-08-10"


#Write a script that prints how many parameters are passed and which ones? For example, if I run the script like this: ./script1 p1 p2 p3 p4, then it should print: 4 params were passed and they're these ones: p1, p2, p3, p4


#Write a script that prints information about your OS and version, release number, and kernel version.


#Write a script that checks if cups service is running. If it running, print "Cups' status is running". Otherwise, prints "Cups's status is stopped".
