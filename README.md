## Opcon SQL Tools for the CLI

### Prerequisites

For example, on apt-based systems:

~~~
sudo apt install ruby-dev unixodbc unixodbc-dev
~~~

Then you may configure your user-account , e.g. your .bashrc , with:

~~~
export GEM_HOME=${HOME}/.gem
export GEM_PATH=${HOME}/.gem
~~~

Don't forget to resource your bashrc.

Now you have to install some gems:

~~~
gem install dbi dbd-odbc ruby-odbc
gem install colorize OptionParser logger
~~~

### Configure the ODBC-Connections

(to be continued)
