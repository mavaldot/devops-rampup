# Display the content of the /etc/passwd, count how many lines it has and sort in a decreasing order (z-a).

cat /etc/passwd
cat /etc/passwd | wc - l
sort -r /etc/passwd

#Find what is your User ID and Group ID. This information is stored in the /etc/passwd file. Also, find what's the line they are. Of course, you should do this without displaying the file's content.

user="myuser"; cat /etc/passwd | grep -n "$user"

#List files and directories that are hidden on your $pwd. Also, list them by time (use the man page to see what flag you need).

ls -lat

#Create a file called myfile. Update its permissions so only your user can read, write, and execute it.

touch myfile
chmod 700 myfile

#Create 5 files (f1,f2,...,f5) without having to type 5 times the touch command.

touch f1 f2 f3 f4 f5

#Move to another location where those 5 files are not. Then do a search to find them, and execute the ls -l command to each of those. This should be done with just one command.

find . -regextype sed -regex '.*[f][0-9]' -exec ls -l {} \;

#Create the directory d1/d2/d3/foo/d4. If the previous directories don't exist, then they should also be created automatically.

mkdir -p d1/d2/d3/foo/d4

#Given the following text "We have 5 days to finish 5 lines of code of the Hi5b project" Replace all "5" by "five", the number must be alone, cannot be in a word.

echo "We have 5 days to finish 5 lines of code of the Hi5b project" | sed "s/ 5 / five /g"

#List all processes running on your system and sort them by the username that's running each process.

ps aux --sort=user

#Run the gedit program, search for it's PID and send it a signal to stop it. After this, send another one resume its execution.

TODO

#Install SSH server. Start the service, and check its status. If it is not enabled, do it.



#Display the network interfaces on your system. Do you see one that isn't physical? What's that interface?

ip a
# The one that isn't physical is the loopback interface (localhost)

#What's your IP and MAC address?

ip a
# IP Address = 10.0.2.15
# MAC Address = 08:00:27:a5:83:c7

#Can you communicate outside your private network? Test this with a command.

ping -c 3 google.com

#What happens to a packet going to a host outside of the network?



#What is the IP of your gateway(s)? Can you check this with two commands?



#Trace the route being taken to connect to cloudflare.com.

traceroute -I cloudflare.com

#What's the IP address of perficient.com? What's their mail server?



#List all TCP and UDP connections on the system.



#What ports do you have open on the system?



#List only the listening connections on the system.



