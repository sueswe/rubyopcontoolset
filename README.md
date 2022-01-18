# Opcon Ruby Tools for the CLI


> get informations from your SMA OPCON job-control-database.


## Description

This set of ruby-scripts tries to select usefull informations from an OPCON-database.
The idea: the great advantage of the CLI is, you could use grep and other tools to parse the results
for your needs.

* There are following tools currently available:

| Name | a very short ... |
| :--- | :--- |
| audit.rb | "Description: Enables the possibility to search the AUDIT-table." |
| batchuser.rb | "Description: selects the configured batch-users." |
| calendar.rb | "Description: selects all data from/with all calenders." |
| disabled-frequencies | "Description: lookup jobs with a disabled frequency." |
| events.rb | "Description: selects EVENTS with jobname, eventstring and schedulename." |
| frequencies.rb | "Description: selects all frequencies, including frequency-code and After/On/Before/NotSchedule-configuration." |
| history.rb | "Description: enables the possibility to search the HISTORY-table." |
| jobdetailmaster.rb | "Description: selects MASTER-Job - configurations." |
| jobdocu.rb | "Description: selects job-documentation from the MASTER-jobs." |
| jobonwhichmachine.rb | "Description: selects jobnames and machine-groups / machines." |
| jobs-and-frequencies.rb | "Description: selects MASTER-jobs and used frequencies." |
| jobstates.rb | "Description: selects current job-state (dependend on schedule-date and schedule)." |
| lsam.rb | "Description: selects agents, OS, ports, and connect-status." |
| machgrp.rb | "Description: selects machinegroups and machines." |
| opcusersignon.rb | "Description: selects user, login-time and client-version." |
| openschedules.rb | "Description: selects open schedules." |
| properties.rb | "Description: selects properties and values." |
| ressources.rb | "Description: selects resources, jobs and values." |
| schedules.rb | "Description: selects schedules and autobuild-configuration." |
| starttimes.rb | "Description: selects Jobs with starttimes (start-offset not 0)." |



## Prerequisites

* First, you need a read-only-database-user for accessing the opcon-database. The rake-installer will ask you later for username and password.

Now you can prepare your local installation:

For example, on apt-based Linux systems (but it also works with Windows 10, see note below):

```sh
$ sudo apt install ruby-dev unixodbc unixodbc-dev ruby-bundler
```

Then you may configure your user-account , e.g. your .bashrc , with:

```sh
export GEM_HOME="${HOME}/.gem"
export GEM_PATH="${HOME}/.gem"
export PATH="${PATH}:${HOME}/bin:${GEM_PATH}/bin"
```

Don't forget to source your .bashrc again.

Now you have to install some gems:

```sh
$ gem install dbi dbd-odbc ruby-odbc
$ gem install colorize OptionParser logger
```

Now, run bundle, to select the right versions of the gems:

~~~
$ bundle
~~~



> **NOTE:** If you like to use the toolset under Windows 10, you have to choose an installer with DEV-Kit from https://rubyinstaller.org/downloads/



## Linux: install the ODBC-connections

Please refer to:

https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15


## Installing the tools to ${HOME}/bin

To install the toolset, run

~~~
$ rake
~~~

You will now be asked for the database-user and password.


### How do I have to name my ODBC-connections?

In the code, I currently use a prefix for the database-name:

```ruby
def dbConnect
  $usr = Read_config.new.get_dbuser
  $pwd = Read_config.new.get_dbpwd
  dbh = DBI.connect("DBI:ODBC:opconxps_#{DB}","#{$usr}","#{$pwd}")
end

```

So the prefix is: *opconxps_*

We use three database-stages (production, testing and developement), so we called
our databases opconxps_prod, opconxps_test and opconxps_dev.
If we want to make a select to the production-database, we only need
the shortname for the parameter like:

```sh
$ jobonwhichmachine.rb -d prod -j %somejobname%

```

(the % is the wildcard for the select-statement in the code.)


## Usage

Every script contains a short help by calling it with option '-h' .

For example:

~~~
$ jobstates.rb -h

Description: selects current job-state (dependend on schedule-date and schedule).
Usage: jobstates.rb [options]
        --databasename DB            Database-Name
    -d, --date SD                    Schedule-Date
    -s, --schedule SN                Schedule-Name
    -h, --help                       Display this screen
~~~


## Support

If you need help, feel free to write an issue.
