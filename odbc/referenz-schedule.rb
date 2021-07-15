#!/usr/bin/env ruby

# apt install ruby-dev, unixodbc, unixodbc-dev
# gem install dbi dbd-odbc ruby-odbc

# Author: Werner Süß <werner.suess@itsv.at>

require 'dbi'
require 'colorize'
require 'optionparser'



options = {}
optparse = OptionParser.new do |opts|
    opts.banner = "Usage: programname [options]"

    options[:databaseName] = nil
    options[:RefVersion] = nil
    opts.on('-d', '--databasename DB','DB-Name') do |dbname|
        options[:databaseName] = dbname
    end
    opts.on('-v', '--version VER', 'Version') do |version|
        options[:RefVersion] = version
    end
    opts.on( '-h', '--help', 'Display this screen' ) do
        puts "Kurzbeschreibung: Obsolet."
        puts opts
        exit
    end
end
optparse.parse!

if options[:databaseName] == nil
    text = "use -h for Help."
    puts text.cyan
    exit 2
end
if options[:RefVersion] == nil
    text = "use -h for Help."
    puts text.cyan
    exit 2
end

if options[:databaseName]
    DB = "#{options[:databaseName]}"
    #puts "Name of Database: " + DB.red
end

if options[:RefVersion]
    ver = "#{options[:RefVersion]}"
    #puts "ReferenzVersion: " + ver.red
end

################################################################################
#
# Methoden
#
################################################################################
def dbConnect
    dbh = DBI.connect("DBI:ODBC:opconxps_#{DB}",'opcon_ro','0nly4u!')
end

################################################################################
#
# SQL
#
query = ("
    select
    jmaster.jobname as Jobname ,
    depjobname as Abhaengigkeit,
    replace(replace(replace(deptype,'131','Weiter'),'3','Stop'),'1','Benoetigt') as 'DepType',
    JAVALUE as 'Script und Parameter',
    (
        SELECT JAVALUE
        FROM jmaster_aux
        JOIN sname ON jmaster_aux.skdid = sname.skdid
        WHERE jmaster_aux.skdid = jmaster.skdid
        AND JAFC = '6002'
        AND Jobname = jmaster.jobname
    ) AS Parameter,
    jskd.Freqname
    --jdocs.doctext
    from jmaster
    left join sname on jmaster.skdid = sname.skdid
    left join jdepjob on jmaster.jobname = jdepjob.jobname
    left join jmaster_aux on jmaster.jobname = jmaster_aux.jobname
    left join jskd on jmaster.jobname = jskd.jobname
    -- left join jdocs on jmaster.jobname = jdocs.jobname
    where skdname like '11-%-RefV#{ver}_T6'
    and jdepjob.SKDID = jmaster.skdid
    and jmaster.jobname not like 'B%N%START%'
    and jmaster.jobname not like 'B%N%END%'
    and jmaster_aux.skdid = jmaster.skdid
    and jskd.skdid = jmaster.skdid
    --and (jmaster.skdid = jdocs.skdid or jdocs.doctext is null)
    and jskd.freqname != 'OR'
    and jmaster_aux.jafc = '6001'
    order by jmaster.jobname
    ;

    ")
#
################################################################################

################################################################################

dbh = dbConnect

sth = dbh.execute(query)

# colCount wird für die loop benötigt:
colCount = sth.column_names.size
#puts "ColCount:         " + colCount.to_s.red

# loop über die Spaltenamen:
colNames = ''
sth.column_names.each do |name|
    #colNames.concat(name.ljust(50))
    colNames.concat(name + ";")
end
puts colNames

while row = sth.fetch do
    rowValues = ''
    # for i in (0 .. 9) do
    (0 .. colCount - 1).each do |n|
        val = row[n]
        if val.nil?
            val = '<<NULL>>'
        end
        #rowValues.concat(val.ljust(50))
        rowValues.concat(val + ";")
    end
    puts rowValues
end
sth.finish

dbh.disconnect if dbh
