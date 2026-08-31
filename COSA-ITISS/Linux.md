# COSA —  Linux Notes

**Contents**
1. OS Fundamentals & Linux Kernel
2. Shell — History, GUI/CLI
3. Installation & Partitioning
4. Shell Prompt & Directory Structure
5. Basic Commands (pwd, ls, cd, mkdir, touch, cat, rm, mv, cp...)
6. Text Processing Utilities (sort, uniq, cut, grep...)
7. Search, History & Disk Usage (find, du/df, history, tty)
8. File Permissions (chmod, chown)
9. Practice Exercise — Users, Groups, Permissions & ACLs

---

## 1. Types of OS

```
1) Single User Single Tasking   (DOS)
2) Single User Multi Tasking    (Windows)
3) Multiuser Multitasking       (Linux/Unix)
4) Real Time                    (ATM)
5) Embedded OS                  (Robotics)
```

---

## 2. Linux: Kernel

Linux is a **kernel**, and it is Open Source:

```
- Free to study
- Free to modify
- Free to distribute
```

```bash
which ls              # locate the binary → /usr/bin/ls
cat /usr/bin/ls        # attempt to read its source
```

`cat` on a binary shows garbled machine code, not readable source — commands are compiled, so this doesn't actually reveal the source code.

How instructions travel from user to hardware:

```
USER ----[kernel] i/p----> SHELL -----[kernel] i/p----> H/W
USER <----[kernel] o/p---- SHELL <-----[kernel] o/p---- H/W
```

**SHELL:** the platform used by the user to give instructions to the hardware, via the kernel.

---

## 3. History of SHELL

```
sh      [Shell]           : traditional shell of UNIX
ksh     [Korn Shell]      : UNIX scripting shell
csh     [C Shell]         : syntax modeled on C language
tcsh    [Turbo C Shell]   : enhanced version of csh
bash    [Bourne Again]    : ksh + tcsh combined; default on most Linux distros
```

### GUI / CLI

```
GUI
  - GNOME (Basic)
  - KDE   (Utilities)

CLI
  \_ TUI [ Text Mode User Interface ]
```

---

## 4. Installation

Recommended space: **20G**

### Partitioning

```
/       : [Parent Partition]

/boot   : [Booting configuration files: GRUB]

SWAP    : [ RAM x 2 ]  →  4GB x 2 = 8GB
            Phy Mem.       Virtual Mem.
```

Virtual Mem: a part of the HDD acting as RAM.

```
/dev/sda
/dev/sda1
/dev/sda2

storage device 'a'
```

### File System

```
ext2, ext3, ext4, xfs, vfat
```

---

## 5. Shell Prompt

```
kiosk@kiosk-virtual-machine:~$
```

```
kiosk                   : username
kiosk-virtual-machine   : hostname
~ [tilde]                : home dir of logged in user
```

```
/home/user1
/home/natasha
---
/root
```

```
$   : Normal User
#   : Root user
```

---

## 6. Directory Structure

```
/bin              [binary]
/sbin             [Super Binary]
/usr              [All system commands]  /usr/bin, /usr/sbin/
/boot             [Booting Configuration]  GRUB
/dev              [Devices]
/lib              [Library]
/lib32            [Library]
/lib64            [Library]
/mnt,/misc,/opt,/media : EMPTY
/home             [Home Dir of normal users]  /home/natasha ; /home/harry
/root             [Home Dir of Super User]
/proc             [Process & hardware related information]
/selinux          [RHEL/CentOS: Security Enhanced Linux]  File Based Security
/etc              [Important: system services & system related config]
/srv              [Service: Third party services]
/sys              [System: system driver database]
/tmp              [Temp]
/var              [variable data: spool dir(mail inbox), logs]
files [static/dynamic]
```

### PATH

```
a) Absolute Path  [/home/natasha/Desktop]
b) Relative Path  [cd Desktop]
```

---

## 7. Basic Commands

```bash
clear              # clear the screen [ ctrl+l ]
```

```bash
pwd                # Present/Print Working Dir
whoami             # Print the loggedin username
date               # Show the date & time
ls                 # Show the list of dir contents
ls -a              # Show all/hidden files & dirs
```

```bash
cd DIRPATH         # change Dir
cd ..              # Previous Dir [ cd ../../ ]
cd                 # Always take you to HOME DIR
```

```bash
mkdir dir_name       # Make dir
mkdir dir1 dir2
mkdir -p a/b/c/d      # From Parent to child
mkdir dir{1..10}
mkdir .dirname         # Hidden dir (starts with a dot)
```

```bash
touch filename        # Create a blank file
touch file{1..5}.txt
touch .filename          # Hidden file
```

```bash
cat > filename        # Create a new file with text
text
[ctrl+d]              # exit/save
```

```
>   stdout   [ Standard output to the program ]
<   stdin    [ Standard input to the program ]
```

```bash
cat > secret
redhat
redhat
```

```bash
cat filename           # To show the text of file
passwd username         # To reset the password for user
```

```bash
cat >> filename         # To append the data in existing file
text
[ctrl+d]                # To save
```

### echo — Print a message

```bash
echo "MSG"          # Print the msg on screen
```

### alias — Create a nickname for a command

```bash
alias                        # a) Check existing alias
alias nick='long_command'     # b) Create new alias
alias dheeraj='whoami'
unalias nick                   # c) Remove existing alias
```

### remove / move / copy

```bash
rm filename           # Remove a file
rm -rfv dir_name        # Remove a dir
```

```
-r [ Recursive ]*
-f [ Forcefully ]
-v [ verbose ]  : to view the process in detail
```

```bash
mv sourceFile/Dir DestinationDir     # Move [also used to rename]
```

```bash
cp srcFile dstFile             # File to File
cp -rfv srcFile/Dir dstDir       # File/Dir to Dir
```

```
-R : RECURSIVE
```

---

## 8. Text Processing Utilities

### sort

```bash
sort names.txt                    # alphabetical (ascending)
sort -r names.txt                 # reverse order
sort -n numbers.txt               # numeric sort (not lexicographic)
sort -rn numbers.txt              # numeric descending
sort -u names.txt                 # sort and remove duplicates
sort -f names.txt                 # case-insensitive sort
sort -k2 data.txt                 # sort by 2nd column
sort -k2 -n data.txt              # sort by 2nd column numerically
sort -t: -k3 -n /etc/passwd       # sort by 3rd field, colon-delimited
sort -h sizes.txt                 # human-readable number sort (1K, 2M, etc.)
sort names.txt -o sorted.txt      # write output to file instead of stdout
sort -R names.txt                 # random shuffle
sort -c file.txt                  # check if file is already sorted (no output = sorted)
sort -M months.txt                # sort by month name (Jan, Feb, Mar...)
```
Without `-n`, sort treats numbers as text, so "10" comes before "2".

### uniq — Remove duplicate lines

`uniq` only removes **consecutive** duplicates. Always sort first if you want all duplicates removed.

```bash
uniq names.txt                    # remove consecutive duplicates
sort names.txt | uniq             # sort then deduplicate all
sort names.txt | uniq -c          # prefix each line with occurrence count
sort names.txt | uniq -d          # show only duplicated lines
sort names.txt | uniq -u          # show only unique (non-duplicated) lines
sort names.txt | uniq -i          # case-insensitive deduplication
```

### head / tail / wc / tac / more / less — Reading Files

```bash
head filename         # Read top 10 lines
head -5 filename        # Read top 5 lines
head -c 512 filename      # first 512 bytes

tail filename          # Read last 10 lines
tail -5 filename        # Read last 5 lines
tail -f /var/log/syslog   # follow live updates
tail -F /var/log/app.log   # follow + reopen on rotation

wc filename            # word count (lines, words, bytes)
wc -l filename          # only line count
wc -w filename            # word count only
wc -c filename             # byte count
wc -m filename              # character count
wc -L filename                # length of longest line

tac filename           # Read a file in REVERSE line order ("tac" = "cat" backwards)
more filename            # Display page by page (forward only)
less filename              # Display page by page (forward + backward scroll)

# Combine — lines 20 to 30
head -n 30 file.txt | tail -n 11
```

### cut — Extract columns from text

```bash
cut -d ":" -f1 /etc/passwd        # first field, colon-separated
cut -d "," -f2,4 data.csv         # 2nd and 4th fields, comma-separated
cut -d " " -f1-3 file.txt         # fields 1 through 3
cut -c1-10 file.txt               # first 10 characters of each line
cut -c5- file.txt                 # from character 5 to end of line
cut --complement -d: -f1 file.txt # everything except field 1
```

### paste — Merge lines from files

```bash
paste file1.txt file2.txt         # merge side by side (tab-separated)
paste -d "," file1.txt file2.txt  # use comma as separator
paste -s file.txt                 # merge all lines of one file into one line
```

### tr — Translate or delete characters

```bash
tr 'a-z' 'A-Z' < file.txt        # lowercase to uppercase
tr 'A-Z' 'a-z' < file.txt        # uppercase to lowercase
tr -d '0-9' < file.txt           # delete all digits
tr -d '[:punct:]' < file.txt     # delete all punctuation
tr -d '\r' < file.txt            # remove Windows carriage returns
tr ' ' '\n' < file.txt           # replace spaces with newlines
tr -s ' ' < file.txt             # squeeze multiple spaces into one
tr -cd '[:print:]' < file.txt    # keep only printable characters
echo "hello" | tr 'a-z' 'A-Z'   # works inline
```
`tr` only reads from stdin — it can't take a filename directly, so it always needs `<` or a pipe.

### fold / fmt — Format line length

```bash
fold -w 80 file.txt               # wrap lines at 80 characters
fold -s -w 80 file.txt            # wrap at word boundaries
fmt file.txt                      # reformat paragraphs to ~75 chars
fmt -w 100 file.txt               # set target line width
```

### column — Align output into columns

```bash
column -t file.txt                # auto-align whitespace-separated data
column -t -s "," data.csv         # align CSV data
mount | column -t                 # useful for making tabular output readable
```

### tee — Read from stdin, write to file and stdout

```bash
command | tee output.txt          # show output AND save to file
command | tee -a output.txt       # append instead of overwrite
command | tee file1.txt file2.txt # write to multiple files
```
Useful when you want to both see output and log it.

### xargs — Pass stdin as arguments

```bash
cat files.txt | xargs rm                       # delete files listed in a file
find . -name "*.log" | xargs rm                # delete all found log files
find . -name "*.txt" | xargs grep "error"      # search inside found files
echo "one two three" | xargs -n 1 echo        # one argument per line
find . -name "*.jpg" | xargs -I{} mv {} /backup/  # move with placeholder
cat urls.txt | xargs -P 4 wget                 # parallel downloads (4 at a time)
```

### Path Concepts Quick Reference

| Notation | Meaning | Example |
|----------|---------|---------|
| `/` | Root (start of absolute path) | `/etc/nginx/nginx.conf` |
| `~` | Home directory | `~/projects/app` |
| `.` | Current directory | `./script.sh` |
| `..` | Parent directory | `../config.yaml` |
| `-` | Previous directory (cd only) | `cd -` |

---

## 9. History, tty, find, du/df

### history — Command History

```bash
history              # Show command history
!2000                 # Re-execute the command at history index 2000
history -c            # Clear/clean the history
```

### tty — Console Identity

```bash
tty                          # Print/show the current console/terminal identity
echo "Hello" > /dev/tty1      # Send a message directly to a specific terminal (tty1)
```

### find — Search for Files

```bash
find /root/ -name foo            # Exact filename match
find /root/ -name .foo            # Exact hidden filename match
find /root/ -name cdac             # Exact filename match
find /root/ -name "cdac*"          # Names starting with "cdac"
find /root/ -name "*ac*"            # Names containing "ac" anywhere
find /root/ -name "*.txt"            # All .txt files

mkdir bar Bar
find /root/ -name "bar"              # Case-sensitive — matches "bar" only
find /root/ -iname "bar"              # Case-insensitive — matches "bar" AND "Bar"
```

Extra useful `find` options:
```bash
find / -type f -name "*.log"     # Only regular files (-type f)
find / -type d -name "backup"     # Only directories (-type d)
find / -mtime -7                    # Modified in the last 7 days
find / -size +100M                   # Files larger than 100 MB
find / -empty                         # Empty files/directories
```

### du / df — Disk Usage

```bash
du -sch file/dir      # Disk usage summary
```

```
-s : Size (summary, not per-file breakdown)
-c : Count/total (grand total at the end)
-h : Human Readable Format (K, M, G, T)
```

```bash
df -h                  # Show free/used disk space for all mounted filesystems (complements du)
```

---

## 10. Pipe & grep

### | (Pipe)

```
------o/p-----> i/p
cmd1 | cmd2 | cmd3
------o/p-----> i/p
```

The pipe sends the **output** of one command as the **input** of the next.

```bash
wc -l file.txt              # Count lines directly on a file
cat file.txt | wc -l         # Same result, achieved by piping cat's output into wc
```

### grep — Search Text/Patterns

Used to search a word/string/pattern/regex inside a file or text stream.

**Syntax:**
```bash
grep "string" file.txt
```

**1) Basic string search**
```bash
grep "string" file.txt
```

**2) Multiple strings (OR match)**
```bash
grep "o\|r\|k" data.txt      # Matches lines containing 'o' OR 'r' OR 'k'
```

**3) Ignore case**
```bash
grep -i "s" data.txt
```

**4) Show lines before & after a match**
```bash
grep -A 2 -B 2 "vai" data.txt   # 2 lines After AND 2 lines Before the match
grep -A 2 "vai" data.txt         # 2 lines After only
grep -B 2 "vai" data.txt         # 2 lines Before only
grep -C 2 "vai" data.txt         # 2 lines of Context on both sides (shortcut for -A2 -B2)
```

**5) Meta-characters**
```bash
grep "^a" data.txt      # ^ (caret)  = Start of the line
grep "i$" data.txt       # $ (dollar) = End of the line
```

**6) Only print the matched part**
```bash
grep -o "string" data.txt
```

**More useful grep flags**
```bash
grep -v "string" file.txt      # Invert match — show lines that DON'T contain "string"
grep -c "string" file.txt       # Count how many matching lines (not occurrences)
grep -n "string" file.txt        # Show line numbers alongside matches
grep -r "string" /path/            # Recursively search all files under a directory
grep -w "cat" file.txt              # Match "cat" as a whole word only (not "category")
grep -E "cat|dog" file.txt           # Extended regex (same as egrep) — no need to escape |
```

### egrep — Extended grep

`egrep` is equivalent to `grep -E`. It uses extended regular expressions, so metacharacters like `|`, `+`, `?`, `{}` work without needing a backslash.

```bash
egrep "cat|dog" file.txt        # same as: grep -E "cat|dog" file.txt
egrep -i "error|warning" log.txt  # ignore case
egrep -c "^[0-9]+" data.txt        # count lines starting with one or more digits
egrep -v "cat|dog" file.txt          # invert match — lines with neither
egrep -n "fail|error" /var/log/messages  # show line numbers with matches
```

---

## 11. File Permissions

### Symbolic Method

```
Permission types:
r : read
w : write
x : execute

Ownership classes:
u : user (owner)
g : group
o : others
a : all

Operators:
+ : Assign
- : Remove
= : Overwrite (set exactly)
```

### Reading Permissions (`ls -l`)

```bash
ls -l
```
```
-rw-r--r--. 1 root root      829 Jan 12  2024 threadss.py
drwxr-xr-x. 2 root root     4096 Feb  9  2024 try_again
```

The first 10 characters break down as: `[file type][owner: rwx][group: rwx][others: rwx]`
- `-` = regular file, `d` = directory
- Groups of 3 after that = permissions for **owner**, **group**, **others**

### Default Permissions

```
Default perm for FILE:
  read & write : u
  read          : g
  read          : o

Default perm for DIRECTORY:
  read, write & execute : u
  read & execute          : g
  read & execute          : o
```

These defaults are controlled by the **umask** value (commonly `022`), which subtracts permissions from the maximum (666 for files, 777 for dirs).
```bash
umask           # View current umask value
umask 022       # Set umask (temporary, current session)
```

### Applying Permissions — Symbolic Method

```bash
chmod u+xw file/dir              # Add execute & write to owner
chmod u+r,u-xw file/dir            # Add read, remove execute & write, for owner
chmod u+xw,g-rw,o+rwx file/dir      # Multiple classes in one command
chmod ugo=r file/dir                 # Set read-only for everyone (overwrite)
chmod a=r file/dir                    # Same as above, 'a' = all
chmod +x file/dir                      # Shortcut — adds execute for all classes
```

### Applying Permissions — Numeric (Octal) Method

```
read    : 4
write   : 2
execute : 1
full    : 7  (4+2+1)
none    : 0
```

| Symbolic | Binary | Numeric |
|---|---|---|
| `r--` | 100 | 4 |
| `-w-` | 010 | 2 |
| `--x` | 001 | 1 |
| `rwx` | 111 | 7 |
| `---` | 000 | 0 |

```bash
chmod 710 file/dir     # owner=7(rwx), group=1(x), others=0(none)
                        # order is always: u g o
```

### chown / chgrp — Change Ownership

```bash
chown newuser file             # Change the owner of a file
chown newuser:newgroup file      # Change owner AND group together
chgrp newgroup file               # Change only the group owner
chown -R newuser dir/               # Recursive — apply to a dir and all its contents
```
`chmod` controls **what** permissions exist; `chown`/`chgrp` control **who** they apply to.

---

## 12. Practice Exercise — Users, Groups, Permissions & ACLs

### 1) Create group, users, and passwords

```bash
groupadd admin
useradd -G admin harry
useradd -G admin natasha
useradd -s /sbin/nologin sarah

echo -e "harry:redhat@123?\nnatasha:redhat@123?\nsarah:redhat@123?" | chpasswd
```

### 2) Collaborative directory /common/adm

```bash
mkdir -p /common/adm
chgrp admin /common/adm
chmod 770 /common/adm
```
`770` = owner and group get rwx, others get nothing — only `admin` members (and root) can enter/read/write.

### 3) /var/tmp/fstab with per-user permissions (uses ACLs)

```bash
cp /etc/fstab /var/tmp/fstab
chown root:root /var/tmp/fstab
chmod 644 /var/tmp/fstab

setfacl -m u:harry:rw- /var/tmp/fstab
setfacl -m u:natasha:--- /var/tmp/fstab

getfacl /var/tmp/fstab
```

### 4) Change owner + group of /tmp/exe

```bash
chown natasha:editors /tmp/exe
```

### 5) developers/testers groups + /project/shared (uses setgid + default ACLs)

```bash
groupadd developers
groupadd testers
useradd -G developers Rahul      # or: usermod -aG developers Rahul
useradd -G testers Nisha         # or: usermod -aG testers Nisha

mkdir -p /project/shared
chgrp developers /project/shared
chmod 2770 /project/shared          # setgid bit ensures new files inherit group

setfacl -m g:developers:rwx /project/shared
setfacl -m g:testers:rwx /project/shared
setfacl -d -m g:developers:rwx /project/shared   # default ACL: inherited by new files
setfacl -d -m g:testers:rwx /project/shared

getfacl /project/shared
```

### 6) schedule.txt permissions

```bash
chmod 664 schedule.txt
# owner: rw-, group: rw-, others: r--
```
