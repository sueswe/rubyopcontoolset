## Opcon Ruby Tools for the CLI


### Description

This set of scripts tries to select usefull informations from an OPCON-database,
for example frequencies and which jobs they using it.

There are following tools currently available:

| Name | description |
| :--- | :--- |
                 audit.rb | "Kurzbeschreibung: Ermöglicht ein Durchsuchen der AUDIT-Tabelle."
             batchuser.rb | "Kurzbeschreibung: Ermöglicht ein Durchsuchen der UNIX-Batch-User."
              calendar.rb | "Kurzbeschreibung: Gibt die Kalender inklusive eingetragenen Daten aus."
                events.rb | "Kurzbeschreibung: Ermöglicht ein Durchsuchen der EVENTS nach Jobname, Eventstring, Schedule."
           frequencies.rb | "Kurzbeschreibung: Ermöglicht ein Durchsuchen der Frequencies, inklusive Frequency-Code und After/On/Before/NotSchedule-Einstellung."
               history.rb | "Kurzbeschreibung: Ermöglicht ein Durchsuchen der HISTORY-Einträge."
       jobdetailmaster.rb | "Kurzbeschreibung: Ausgeben von MASTER-Jobs - Konfigurationen."
               jobdocu.rb | "Kurzbeschreibung: Ausgeben von Job-Documentation-Feldern."
     jobonwhichmachine.rb | "Kurzbeschreibung: Ausgeben von Jobname und zugeordneter Maschinengruppe bzw Maschine."
  jobs-and-frequencies.rb | "Kurzbeschreibung: Ausgeben von MASTER-Jobs - Konfigurationen in Bezug auf die Frequenz."
             jobstates.rb | "Kurzbeschreibung: Ausgeben von aktuellen Job-Status in Bezug auf ein TEV-Datum und Schedule."
                  lsam.rb | "Kurzbeschreibung: Ausgeben der Agents, OS, Ports, sowie des Connect-Status."
               machgrp.rb | "Kurzbeschreibung: Ausgeben von Maschinengruppen und zugeordneter Maschinen."
         opcusersignon.rb | "Kurzbeschreibung: Ausgeben von Benutzer , Anmeldezeitraum sowie Client-Version."
         openschedules.rb | "Kurzbeschreibung: anzeigen von noch nicht abgeschlossenen Schedules."
            properties.rb | "Kurzbeschreibung: Ausgeben von Properties und Values."
            ressources.rb | "Kurzbeschreibung: Ausgeben von Ressourcen, zugeordneten Jobs und Werten."
             schedules.rb | "Kurzbeschreibung: Ausgeben von vorhandenen Schedules und Autobuild-Konfiguration."
            starttimes.rb | "Kurzbeschreibung: Ausgeben von Jobs und Startzeiten."
               zpvjobs.rb | "Kurzbeschreibung: Ausgabe von History-Werten für ZPV-Jobs."

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

