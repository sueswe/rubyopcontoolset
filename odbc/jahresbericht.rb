#!/usr/bin/env ruby

# apt install ruby-dev, unixodbc, unixodbc-dev
# gem install dbi dbd-odbc ruby-odbc

require 'dbi'
require 'colorize'
require 'optionparser'

class Read_config
  require 'yaml'
  targetDir = ENV["HOME"] + "/bin/"
  $config = targetDir  +  "opcon.yaml"

  def get_dbuser
    config = YAML.load_file($config)
    opcon_db_username = config['opconuser']
    return opcon_db_username
  end
  def get_dbpwd
    config = YAML.load_file($config)
    opcon_db_pwd = config['opconpassword']
    return opcon_db_pwd
  end
end

puts "## Jahresbericht/Zwischenbericht\n"
# puts "---\n"

myname = File.basename(__FILE__)

options = {}
optparse = OptionParser.new do |opts|
    opts.banner = "Usage: #{myname} [options]"

    options[:databaseName] = nil
    opts.on('-d', '--databasename DB','Zwingend; Datenbank-Name (Anteil nach opconxps_)') do |dbname|
        options[:databaseName] = dbname
    end

    options[:fromdate] = nil
    opts.on('-v', '--von Datum','Zwingend; Datum (YYYY-MM-DD) des Timestamps (>=)') do |date|
        options[:fromdate] = date
    end

    options[:todate] = nil
    opts.on('-b', '--bis Datum','Optional; Datum (YYYY-MM-DD) des Timestamps (<=)') do |date|
        options[:todate] = date
    end

    opts.on( '-h', '--help', '(Display this screen)' ) do
        puts "Kurzbeschreibung: Datenbank-Abfragen für ITSV-Opcon-Jahresbericht."
        puts opts
        #puts String.colors
        #puts "Sonstiges: ".yellow
        #puts " - Wildcard fuer das Datum ist '%' , bspw. 2021-03-%"
        #puts String.modes
        #puts String.color_samples
        exit
    end
end
optparse.parse!

if options[:databaseName] == nil
    puts "Missing DB name (prod|test|entw). Use -h for help.".cyan
    exit 2
end
if options[:databaseName]
    DB = "#{options[:databaseName]}"
    puts "\n### System: " + DB.upcase
end

if options[:fromdate] == nil
    puts "Missing FROM_DATE (yyyy-mm-dd). Use -h for help.".cyan
    exit 2
else
    from_date = "#{options[:fromdate]}"
    #puts "fromdate: #{from_date}"
end

if options[:todate] == nil
    to_date = from_date
    #puts "Missing TO_DATE (yyyy-mm-dd). Use -h for help.".cyan
    #exit 2
else
    to_date = "#{options[:todate]}"
    #puts "todate: #{to_date}"
end

puts "\n### Berichtsdatum: #{from_date} bis einschließlich #{to_date} \n"


################################################################################
#
# SQL
#
sql_zpvmaschinen = ("
SELECT
--CONVERT(smalldatetime,JSTART-2),SKDNAME,JOBNAME,JMACH
count(*)
FROM HISTORY
JOIN SNAME ON (HISTORY.SKDID = sname.skdid)
WHERE convert(smalldatetime,JSTART-2) >= '#{from_date} 00:00:00.000'
AND convert(smalldatetime,JSTART-2) <= '#{to_date} 23:59:59.999'
and JMACH like '%zpv%'
--ORDER BY JSTART DESC
;
")

sql_zpvbatch = ("
select count(jobname)
from history
join sname on history.skdid = sname.skdid
where skdname like '%-ZPVBATCH'
and SKDDATE >= convert(smalldatetime,'#{from_date}') + 2
and SKDDATE <= convert(smalldatetime,'#{to_date}') + 2
and jmach not like '%Info%'
--WHERE convert(smalldatetime,JSTART-2) >= '#{from_date} 00:00:00.000'
--AND convert(smalldatetime,JSTART-2) <= '#{to_date} 23:59:59.999'
;
")

planbare_schedules = ("
--select distinct SKDNAME
select count(*)
--(
--select SAVALUE
--from SNAME_AUX au
--join sname sn on sn.skdid = au.skdid
--where au.SAFC = 0
--AND s.skdid = au.skdid
--)
from sname s
join sname_aux a on s.skdid = a.skdid
where s.SKDNAME not like '%AMC'
and s.SKDNAME not like '%CYCLO%'
and s.SKDNAME not like '%SCHEDU%'
and s.SKDNAME not like '%SMS'
and s.SKDNAME not like '%Util%'
AND a.SAFC = 105
;
")

verfuegbare_schedules = ("
select count(*)
from sname
where SKDNAME not like '%AMC'
and SKDNAME not like '%CYCLO%'
and SKDNAME not like '%SCHEDU%'
and SKDNAME not like '%SMS'
and SKDNAME not like '%Util%'
;")

summe_gelaufene_jobs = ("
select count(history.jobname)
from history
where jstart >= convert(smalldatetime,'#{from_date}') + 2
and jstart <= convert(smalldatetime,'#{to_date}') + 2
and history.jobname != ''
;
")

aktive_jobs = ("
select count(*) from jmaster
where skdid in (select sname.skdid
from sname
join sname_aux on sname.skdid = sname_aux.skdid
and safc = 105)
;")

master_jobs = ("
select count(*) from jmaster
join sname on sname.skdid = jmaster.skdid
where SKDNAME not like '%vor%'
;")

durschnittlich_gelaufene_jobs_pro_tag = ("
select
(
select count(history.jobname)
from history
where jstart > convert(smalldatetime,'#{from_date}') + 2
and jstart <= convert(smalldatetime,'#{to_date}') + 2
and datepart(dw,convert(smalldatetime,skddate)-2) != 7 -- kein WE
and datepart(dw,convert(smalldatetime,skddate)-2) != 1 -- kein WE
and history.jobname != ''
)
/ -- divide
(
select count(distinct skddate)
from history
where jstart > convert(smalldatetime,'#{from_date}') + 2
and jstart <= convert(smalldatetime,'#{to_date}') + 2
and datepart(dw,convert(smalldatetime,skddate)-2) != 7 -- kein WE
and datepart(dw,convert(smalldatetime,skddate)-2) != 1 -- kein WE
and history.jobname != ''
)
;")
################################################################################

#puts "\nGoing to run:"
#puts sql.red
#puts "-" * 40

################################################################################
#
# Methoden
#
################################################################################
def dbConnect
  $usr = Read_config.new.get_dbuser
  $pwd = Read_config.new.get_dbpwd
  dbh = DBI.connect("DBI:ODBC:opconxps_#{DB}","#{$usr}","#{$pwd}")
end
################################################################################
puts "\n"
puts "|---"
puts "| Position | Anzahl |"
puts "| :--- | ---: |"

dbh = dbConnect


sth = dbh.execute(verfuegbare_schedules)
colCount = sth.column_names.size
colNames = ''
sth.column_names.each do |name|
    colNames.concat(name + " | ")
end
while row = sth.fetch do
    rowValues = ''
    (0 .. colCount - 1).each do |n|
        val = row[n].to_s
        rowValues.concat(val + ' ' )
    end
    puts "|Verfügbare Schedules|" + rowValues + " | "
end
sth.finish


sth = dbh.execute(planbare_schedules)
colCount = sth.column_names.size
colNames = ''
sth.column_names.each do |name|
    colNames.concat(name + " | ")
end
while row = sth.fetch do
    rowValues = ''
    (0 .. colCount - 1).each do |n|
        val = row[n].to_s
        rowValues.concat(val + ' ' )
    end
    puts "|Geplante Schedules (AUTOBUILD=YES)|" + rowValues + " | "
end
sth.finish




sth = dbh.execute(summe_gelaufene_jobs)
colCount = sth.column_names.size
colNames = ''
sth.column_names.each do |name|
    colNames.concat(name + " | ")
end
while row = sth.fetch do
    rowValues = ''
    (0 .. colCount - 1).each do |n|
        val = row[n].to_s
        rowValues.concat(val + ' ' )
    end
    puts "|Summe gelaufener Jobs |" + rowValues + " | "
end
sth.finish




sth = dbh.execute(aktive_jobs)
colCount = sth.column_names.size
colNames = ''
sth.column_names.each do |name|
    colNames.concat(name + " | ")
end
while row = sth.fetch do
    rowValues = ''
    (0 .. colCount - 1).each do |n|
        val = row[n].to_s
        rowValues.concat(val + ' ' )
    end
    puts "|Aktive Jobs in Schedules (AUTOBUILD=YES)|" + rowValues + " | "
end
sth.finish



sth = dbh.execute(master_jobs)
colCount = sth.column_names.size
colNames = ''
sth.column_names.each do |name|
    colNames.concat(name + " | ")
end
while row = sth.fetch do
    rowValues = ''
    (0 .. colCount - 1).each do |n|
        val = row[n].to_s
        rowValues.concat(val + ' ' )
    end
    puts "|Jobanzahl insgesamt im MASTER|" + rowValues + " | "
end
sth.finish




sth = dbh.execute(durschnittlich_gelaufene_jobs_pro_tag)
colCount = sth.column_names.size
colNames = ''
sth.column_names.each do |name|
    colNames.concat(name + " | ")
end
while row = sth.fetch do
    rowValues = ''
    (0 .. colCount - 1).each do |n|
        val = row[n].to_s
        rowValues.concat(val + ' ' )
    end
    puts "|Durchschnittlich gelaufene Jobs pro Tag|" + rowValues + " | "
end
sth.finish


sth = dbh.execute(sql_zpvmaschinen)
colCount = sth.column_names.size
colNames = ''
sth.column_names.each do |name|
    colNames.concat(name + " | ")
end
while row = sth.fetch do
    rowValues = ''
    (0 .. colCount - 1).each do |n|
        val = row[n].to_s
        rowValues.concat(val + ' ' )
    end
    puts "|Gelaufene Jobs auf zpv-Maschine(n)|" + rowValues
end
sth.finish


sth = dbh.execute(sql_zpvbatch)
colCount = sth.column_names.size
colNames = ''
sth.column_names.each do |name|
    colNames.concat(name + " | ")
end
while row = sth.fetch do
    rowValues = ''
    (0 .. colCount - 1).each do |n|
        val = row[n].to_s
        rowValues.concat(val + ' ' )
    end
    puts "|Durchgeführte ZPVBATCH-Jobs|" + rowValues + " | "
end
sth.finish

dbh.disconnect if dbh
