------------------------------------------------------------------------------
ATTENTION: This project has not been updated since 2004, and I don't even know
if this code still works with the latest versions of Big Brother (www.bb4.com)

To build it you will need Borland Delphi 7 (don't know if newer versions will
compile it)

The last binary available can be downloaded from Dell: http://goo.gl/FGFMX7
And the package with the SSL library included is here: http://goo.gl/7fopR5

It should work also with Xymon/Hobbit: http://xymon.sourceforge.net
------------------------------------------------------------------------------



ORIGINAL README.TXT:


     BBtray 0.9.2

     (c)1999,2004 by Deluan Cotts



WHAT IS IT?
----------
This is a little Win32 tray-icon program that monitors a predefined BBDISPLAY
page (normaly the "Condensed View" page) and alerts when the status of that page
changes, using a popup window and sound alarms.

If you don't know what the hack is a "BBDISPLAY page", please visit the
"Big Brother System and Network Monitor" homepage at http://www.bb4.com

I've made this program to avoid keeping a Browser opened on my desktop. The
main advantages should be obvious: more free memory available, no browser
windows in your way and your attention grabbed anywhere in the room
(thanks to the sound alarms).



HOW TO INSTALL?
---------------
1) Uncompress BBtray.zip to a new directory (ex: "C:\BBTRAY"). Remember to
   mantain the directory structure ("Use folder names" option in WinZip)
2) Rename "BBTRAY.INI.DIST" to "BBTRAY.INI" and customize it
   (see the details inside it)
3) Start "BBTRAY.EXE"
4) That's it! Now you should see a colored icon on the Windows' tray.

If you want your sound files to reside on the BBDISPLAY server, follow these
steps:
1) Create a directory in bb/www for the WAV files (ex: bb/www/sounds)
2) Copy "*.wav" to that directory. Note that the WAV filenames must
   be all lower case.
3) Check if you can view this sound directory list on your browser
4) See the comments on the 'SoundsPath' option, inside "BBTRAY.INI"



SSL SUPPORT
-----------
You can use SSL URL's (https) with BBtray, as long as you install OpenSSL for
Indy in the system it will run. You can download OpenSSL DLL's for free from:

http://www.intelicom.si/modules.php?op=modload&name=Downloads&file=index&req=getit&lid=4

or download BBtray-SSL.zip from the same place you've download this package.
That one includes the file indy_openssl096.zip, with the necessary DLL's.

Uncompress the DLL's in the Windows directory (normally C:\WINDOWS or C:\WINNT).

Be aware that BBtray has only been tested with OpenSSL 0.9.6 DLL's.

See also COPYRIGHT bellow.



MCAFEE VIRUSSCAN USERS
----------------------
Please read the "McAffe\McAfee.txt" for important notes.



HISTORY
-------
See "HISTORY.TXT"



TODO/WISH LIST
--------------
- Make the code multithreaded, enabling one instance of BBtray to monitor as
  many BBDISPLAY as needed
- Also act as screensaver
- Port to Linux
- You say...



COPYRIGHT
---------
This is free software. You can not sell this software. If you want to do so,
please contact me.

Use it at your own risk. Again: USE IT AT YOUR OWN RISK.

*IMPORTANT*: BBtray does not give you any legal rights to use SSL. Using SSL
in some nations may be illegal. It is up to you to determine the legal
situation in your nation.

And just to be sure: USE BBTRAY AT YOUR OWN RISK.

Also I'd like to give my thanks to Martin Parrot, for BBtray.exe's icon.



COMMENTS? QUESTIONS?
--------------------

I would really be pleased to hear what you think about BBtray. You are welcome
to send any sugestions or comments to:

bbtray@deluan.com.br
