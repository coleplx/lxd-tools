# lxd-tools

A small framework for managing common LXD reporting and monitoring tools in one location

To add a tool do the following and refer to existing scripts for the schema:
* Add your script to the 'functions' folder
* Convert your script into a function such as 'function script_name {<your code>}'
* Add the function name in the 'source' header
* Create an entry in the 'mainmenu' function
* Add a command option in the bottom of the file
