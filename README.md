## Opcon Ruby Tools for the CLI


### Description

This set of scripts tries to select usefull informations from an OPCON-database,
for example frequencies and which jobs they using it.

There are following tools currently available:

| Name | description |
| :--- | :--- |
| audit.rb | "Description: Enables the possibility to search the AUDIT-table." |
| batchuser.rb | "Description: selects the batch-user." |
| calendar.rb | "Description: selects all data from all calenders." |
| events.rb | "Description: selects EVENTS with Jobname, Eventstring and Schedulename." |
| frequencies.rb | "Description: selects all Frequencies, including Frequency-Code and After/On/Before/NotSchedule-configuration." |
| history.rb | "Description: enables the possibility to search the HISTORY-table." |
| jobdetailmaster.rb | "Description: selects MASTER-Jobs - configurations." |
| jobdocu.rb | "Description: selects Job-documentation from the MASTER-Jobs." |
| jobonwhichmachine.rb | "Description: selects jobnames and machine-groups or machines." |
| jobs-and-frequencies.rb | "Description: selects MASTER-Job - configurations and frequencies." |
| jobstates.rb | "Description: selects current job-state (dependend on schedule-date and schedule)." |
| lsam.rb | "Description: selects agents, OS, ports, and connect-status." |
| machgrp.rb | "Description: selects machinegroups and machines." |
| opcusersignon.rb | "Description: selects user, login-time and client-version." |
| openschedules.rb | "Description: selects open schedules." |
| properties.rb | "Description: selects properties and values." |
| ressources.rb | "Description: selects resources, jobs and values." |
| schedules.rb | "Description: selects schedules and autobuild-configuration." |
| starttimes.rb | "Description: selects Jobs with starttimes (start-offset not 0)." |

The great advantage of the CLI is, you could use grep and other tools to parse the results
for your needs.

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

### Usage

Every script contains a short help by calling it with option '-h' .

