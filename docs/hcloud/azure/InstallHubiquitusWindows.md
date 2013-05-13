# Installing Hubiquitus on Windows
An already compiled, fully working version is available [Hubiquitus for Windows.zip (10.5 Mo)](https://mega.co.nz/#!XQRGUKgB!ZP6v7gExM-mMuAaX7LGNx0vSXOQV6XIKrJtqSJUkyKY). Use it if you have any trouble compiling hubiquitus on Windows.

Hubiquitus is originally made to work on Unix systems. To make it work on Windows, a few adjustments are needed.

1. Download Node.js [v0.8.22-x64](http://nodejs.org/dist/v0.8.22/x64/node-v0.8.22-x64.msi) (if you are in Windows 64-bits). This version is the best that suits with all our future actions.

2. Download Hubiquitus project as a Zip from GitHub

3. Edit package.json file as follows :

 a. Replace "zmq" dependency by "git://github.com/mscdex/zeromq.node.git".
For Windows 32-bits, try "git://github.com/matthiasg/zeromq-node-windows.git" **(untested)**

 b. Change socket.io module version to ">= 0.9.10" (not to be mistaken with **socket.io-client**)

4. Some dependencies use Git : On Windows a git client is needed, such as [MySysGit](https://code.google.com/p/msysgit/). During the installation choose option "Run Git from the Windows Command Prompt"

5. Node-gyp is a build tool for Node.js native addons. Its installation is needed for Hubiquitus but complex on Windows... Install in this order :
 - [Microsoft Visual Studio C++ 2010 Express](http://go.microsoft.com/?linkid=9709949)
 - [Windows 7 64-bit SDK](http://www.microsoft.com/en-us/download/details.aspx?id=8279). If installation fails, try to uninstall Visual C++ librairies 2010 x64 & x86 Redistributable versions 10.4.xxx.
 - For Windows 64-bits install [Compiler Update for the Windows SDK 7.1](http://www.microsoft.com/en-us/download/details.aspx?id=4422)

 Many issues have been encountered on the way to make "node-gyp" work properly. If it is impossible to re-compile, use the already compiled versions of *time* and *zmq* from the already compiled Hubiquitus for Windows here : [Hubiquitus for Windows.zip (10.5 Mo)](https://mega.co.nz/#!XQRGUKgB!ZP6v7gExM-mMuAaX7LGNx0vSXOQV6XIKrJtqSJUkyKY).


6. Start a command-line shell in Admin mode (use Powershell rather than Windows default command-line shell !) and go in your hubiquitus folder where package.json appears (use **dir** or **ls** to list files).

7. Run **npm install**. If no errors appear, you have just compiled Hubiquitus on Windows successfully !

8. Installing MongoDB has **NOT** been tested. If you don't need it, you have to modify *hubiquitus\lib\actor\hchannel.coffee* in order to remove all references to databases, so that Hubiquitus doesn't use MongoDB. Find an example  [here](https://mega.co.nz/#!7YoXSZ5A!SzYtMxStVxq9weEfPmt1IjCSCwtGYNVL2mnBw0Yy7JE
https://mega.co.nz/#!7YoXSZ5A!SzYtMxStVxq9weEfPmt1IjCSCwtGYNVL2mnBw0Yy7JE) (This might not be the up-to-date version of the file)
