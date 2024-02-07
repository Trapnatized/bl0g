---
layout: post
title: HTB Inject
categories: [writeups, htb]
tags: [lfi, exploit, privesc]
date: 2023-06-05
img_path: '/assets/img/writeups/htb/inject.md/'
image:
  path: logo.png
---


...


<br/>
Lets start off with a nmap scan..<br/>
<br/>
![](image 2.png)
<br/>
We will come back to look for exploits on Nagios. Let's check out whats on port 8080<br/>
<br/>
![](image 3.png)
<br/>
We have an /upload page and a /register page. Let's check out the upload page and see if we can upload something without signing up.<br/>
And it looks like we can upload an /assets/images/htb/inject.md/image file, time to view our newly uploaded file.. (maybe we can **inject** a php reverse shell using burp..)<br/>
<br/>
<br/>
![](image 4.png)
<br/>
<br/>
<br/>
![](image 5.png)
<br/>
Hmmm... lets try **LFI** <br/>
<br/>
![](image 6.png)
<br/>
We get a 500 error code.. Maybe we didnt go far enough back to make it to the root directory.. <br/>
Using curl we are able to see that is indeed the problem.<br/>
<br/>
![](image 7.png)
<br/>
Looks like we need to go back 2 more directories.<br/>
<br/>
![](image 8.png)
<br/>
????... Let's check the output using curl...<br/>
<br/>
![](image 9.png)
<br/>
We have **LFI** and also 2 users on this machine, Frank and Phil. Lets check for any id_rsa keys for these users.<br/>
<br/>
![](image 10.png)
<br/>
Looks like no id_rsa key for Frank or Phil but we can further enumerate the machine to look for other interesting files by &nbsp;just searching directories.<br/>
<br/>
![](image 11.png)
<br/>
ahhh a flag.. &nbsp;Tried to curl the user.txt but i dont have the right permissions.. Let's get a shell<br/>
Further enumerating the system using curl we come across<br/>
<br/>
![](image 12.png)
<br/>
![](image 13.png)
<br/>
Let's check searchsploit.. This exploit might work. We can download this python script to our machine and test it out.<br/>
<br/>
![](image 14.png)
<br/>
...<br/>
<br/>
Let's see if we can get a meterpreter shell.<br/>
First we'll start metasploit and search Spring Cloud. There are a few modules we could try but let's go with the exploit.<br/>
<br/>
![](image 15.png)
<br/>
Next we will set the options to be able to run the exploit.<br/>
<br/>
![](image 16.png)
<br/>
So we will need to set RHOSTS &amp; LHOST then we can run exploit.<br/>
<br/>
![](image 17.png)
<br/>
And we get a shell. Type help to get a list of commands we can use while in our meterpreter shell. Lets drop into a system command shell and check our id.<br/>
<br/>
![](image 18.png)
<br/>
We are Frank. Lets look for ways to escalate to root or pivot to phil.<br/>
<br/>
<br/>
![](image 19.png)
<br/>
Well that was too easy.... I dont think that was the intended way but ill take the easy win....<br/>
<br/>
<br/>
<br/>



