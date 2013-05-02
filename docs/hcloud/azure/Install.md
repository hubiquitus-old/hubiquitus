# Installing Hubiquitus on Windows
An already compiled, fully working version is available [here](). Use it if you have any trouble compiling hubiquitus on Windows.

Hubiquitus is originally made to work on Unix systems. To make it work on Windows, a few adjustments are needed.

1. Download Hubiquitus project as a Zip from GitHub

2. Edit package.json file as follows :

 a. Replace "zmq" dependency by "git://github.com/mscdex/zeromq.node.git".
For Windows 32-bits, try "git://github.com/matthiasg/zeromq-node-windows.git" **(untested)**

 b. Change socket.io module version to ">= 0.9.10" (not to be mistaken with **socket.io-client**)

3. Some dependencies use Git : On Windows a git client is needed, such as [MySysGit](https://code.google.com/p/msysgit/). During the installation choose option "Run Git from the Windows Command Prompt"

4. Node-gyp is a build tool for Node.js native addons. Its installation is needed for Hubiquitus but complex on Windows... Install in this order :
 - [Microsoft Visual Studio C++ 2010 Express](http://go.microsoft.com/?linkid=9709949)
 - [Windows 7 64-bit SDK](http://www.microsoft.com/en-us/download/details.aspx?id=8279).
If installation fails, try to uninstall Visual C++ librairies 2010 x64 & x86 Redistributable versions 10.4.xxx).

 - For Windows 64-bits install [Compiler Update for the Windows SDK 7.1](http://www.microsoft.com/en-us/download/details.aspx?id=4422)

 Many issues have been encountered on the way to make "node-gyp" work properly. If it is impossible to re-compile, use the already compiled versions of *time* and *zmq* from the already compiled Hubiquitus for Windows [here]()

5. Start a command-line shell in Admin mode (use Powershell rather than Windows default command-line shell !) and go in your hubiquitus folder where package.json appears (use **dir** or **ls** to list files).

6. Run **npm install**. If no errors appear, you have just compiled Hubiquitus on Windows successfully !

# Use Hubiquitus in a Windows Azure Project

## Install Windows Azure SDK Development Kit for Node.js
Download Microsoft **Web Platform Installer**. This tool will be used to download installation packages.

Open Web Platform Installer (WPI) and find **"Windows Azure SDK for Node.js Software Development Kit"** (in French "Kit de développement logiciel Windows Azure SDK pour Node.js")
Currently this package is released on 24/04/2013 and contains in particular Windows Azure Powershell, Windows Azure Emulator and Windows Azure SDK for Node.js.

Installing the package will only install the dependencies you don't already have. If you ever happen to uninstall some dependencies manually, you won't be able to re-install them with WPI : "Windows SDK for Node.js" product will appear as "Installed" as long as Windows azure Powershell is installed. Uninstall it (can't be done with WPI) if you want to install it again with all its dependencies.

## Create a new Node.js project with Powershell

Windows Azure allows to deploy Node.js project, but these can't be managed with Visual Studio. No problem, as command-line tools are enough to de everything you want.

- Open Windows Azure Powershell as Administrator

- Create anywhere a *Projects* folder, and go inside : 
```
md Projects
cd Projects
```

- Create a new project 
```
New-AzureServiceProject testProj
```

- Add a Node.js Web Role to the project
```
Add-AzureNodeWebRole
```
If not specified, the default name for the Web Role is *WebRole1*

- The *server.js* file is the one launched at starting.You can replace the following line :
```
res.end(“Hello World”); 
```
by
```
res.end('</br>Hello from Windows 
Azure running node version: ' + process.version + '</br>');
```
This will print the Node.js version used on the system.

