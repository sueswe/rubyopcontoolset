## Opcon SQL Tools for the CLI

### Prerequisites

For example, on apt-based systems:

~~~
sudo apt install ruby-dev unixodbc unixodbc-dev ruby-bundler
~~~

Then you may configure your user-account , e.g. your .bashrc , with:

~~~
export GEM_HOME="${HOME}/.gem"
export GEM_PATH="${HOME}/.gem"
export PATH="${PATH}:${HOME}/bin:${GEM_PATH}/bin"
~~~

Don't forget to resource your bashrc.

Now you have to install some gems:

~~~
gem install dbi dbd-odbc ruby-odbc
gem install colorize OptionParser logger
~~~

Now, run bundle:

~~~
bundle
~~~


### Configure the ODBC-Connections

Please refer to:

https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15


### Installing the tools to ${HOME}/bin

You may or may not now copy the scripts to your HOME/bin - directory with:

~~~
rake
~~~


