---
layout: post
title: HTB MonitorsTwo
categories: [writeups, htb]
tags: [rce, docker escape, exploit]
date: 2023-06-08
img_path: '/assets/img/writeups/htb/monitorstwo.md/'
image:
  path: logo.png
---
...

First let's start off by scanning for open ports.<br/>

## Threader3000 / Nmap

<br/>
![](image.png)
<br/>
Heading over to port 80 we find a login page that also tells us which version # is running.<br/>
<br/>
![](image 2.png)
<br/>
Let's look for an exploit...<br/>

## Foothold

<br/>
![](image 3.png)
<br/>
Let's use this exploit since it works right out of the box...<br/>

we can either `git clone https://github.com/FredBrave/CVE-2022-46169-CACTI-1.2.22.git` or 

<br/>
![](image 4.png)
<br/>
copy &nbsp;the code and save it to a new file `exploit.py` <br/>
<br/>
![](image 5.png)
<br/>
Start a netcat listener <br/>
<br/>
![](image 6.png)
<br/>
<br/>
Now lets trigger the exploit<br/>
<br/>
![](image 7.png)
<br/>
and if we check our netcat listener we see we have a shell.<br/>
<br/>
![](image 8.png)

## Priv-esc

<br/>
Let's run linPEAS and see if we can find anything interesting<br/>
<br/>
![](image 9.png)
<br/>
![](image 10.png)
<br/>
`/sbin/capsh` has the SUID bit set.. Let's go check out [gtfobins.github.io] <br/>
<br/>
![](image 11.png)
<br/>
`/sbin/capsh --gid=0 --uid=0 --`<br/>
<br/>
![](image 12.png)
<br/>
we are root.... But i believe we are stuck inside of a docker container<br/>
<br/>
![](image 13.png)
<br/>

## Lateral Pivot / www -> marcus

<br/>
some other info from linpeas<br/>
![](image 21.png)
<br/>
<br/>
![](image 20.png)
<br/>
`mysql --host=db --user=root --password=root cacti -e 'show tables'`<br/>
![](image 14.png)
<br/>
Ok let's look inside user_auth.<br/>
`mysql --host=db --user=root --password=root cacti -e 'select * from user_auth'`<br/>
<br/>
![](image 15.png)
<br/>
And we find a couple hashes along with names and emails.. Maybe we can crack the hashes and get the passwords...<br/>
<br/>
![](image 22.png)
<br/>
well that was easy... Now we have Marcus's password wonder if we can log in.<br/>
<br/>
![](image 17.png)
&nbsp;<br/>
Looks like we are inside docker containers....<br/>
Lets grab the user.txt flag, then breakout.<br/>
<br/>
![](image 18.png)
<br/>

## Docker Escape

<br/>
Ok let's check what version of docker is running<br/>
<br/>
![](image 19.png)
<br/>
Any exploits?? Let's check it out..<br/>
<br/>
![](image 23.png)
<br/>
Here is the readme.md for this exploit...<br/>
<br/>
![](image 26.png)
<br/>
Again we will just copy the raw file and paste into a new file called `test.sh` to test this out.<br/>
<br/>
![](image 25.png)
<br/>
First let's change directory to /tmp and then create our `test.sh` file.. Once complete we will need to make this file executable. <br/>
<br/>
![](image 24.png)
<br/>
So according to the README, the only step i'm missing is to set the SUID bit on /bin/bash inside the container..<br/>
Looks like the /bin/bash binary already has the SUID bit set.... But here's the command to set it anyways...<br/>
It's always a good idea to make a backup of any binary before modifying it just incase something happens you'll have a way to revert back to original..<br/>
<br/>
![](image 27.png)
<br/>
Ok time to run the exploit and see if it works..<br/>
<br/>
![](image 16.png)
<br/>

## Root

Looks like we got a shell but it closed itself.... Lets follow this new path and manually execute ./bin/bash -p<br/>
<br/>
![](image 28.png)
<br/>
Looks like our euid is root and that is enough to read &nbsp;/root/root.txt..<br/>
But if we want full root privileges let's take it one step further...<br/>

`python3 -c 'import os;os.setuid(0);os.setgid(0);os.system("/bin/sh")'`

<br/>
![](image 29.png)
<br/>
And we now have full root access to this machine...<br/>
<br/>
![](image 30.png)
<br/>
<br/>
