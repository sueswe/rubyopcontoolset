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

myname = File.basename(__FILE__)

options = {}
optparse = OptionParser.new do |opts|
    opts.banner = "Usage: #{myname} [options]"

    options[:databaseName] = nil
    opts.on('-d', '--databasename DB','mandatory; database name (prefix = \'opconxps_\')') do |dbname|
        options[:databaseName] = dbname
    end

    options[:jobname] = nil
    opts.on('-j','--jobname JOB','') do |j|
      options[:jobname] = j
    end

    opts.on( '-h', '--help', '(Display this screen)' ) do
        puts "Description: selects jobnames and machine-groups or machines."
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
    puts optparse
    exit 2
end

if options[:databaseName]
  DB = "#{options[:databaseName]}"
  puts "Name of database: " + DB
end

if options[:jobname]
  job = "#{options[:jobname]}"
else
  puts "Missing a jobname or something ".red
  puts optparse
  exit 3
end



################################################################################
#
# SQL
#
sql = ("SELECT
jmaster_aux.jobname, jmaster_aux.javalue, machs.machname, machgrps.machgrp
FROM jmaster_aux
JOIN sname    ON jmaster_aux.skdid = sname.skdid
JOIN jmaster  ON jmaster_aux.skdid = jmaster.skdid AND jmaster_aux.jobname = jmaster.jobname
JOIN machs    on jmaster.primmachid = machs.machid
JOIN machgrps on jmaster.machgrpid = machgrps.MACHGRPID
where jmaster_AUX.JOBNAME like '%#{job}%'
--AND (jafc = 6001 OR jafc = 6004 OR jafc = 6005 OR jafc = 3003 OR jafc = 3001 or jafc = 1004 or jafc = 1006 or jafc = 1003 or jafc = 1005)
order by machgrp
;
")
################################################################################
puts "-" * 40
puts "Going to run:".yellow
puts "-" * 40
puts sql.green
puts "-" * 40
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

dbh = dbConnect

sth = dbh.execute(sql)

colCount = sth.column_names.size
puts "ColCount: " + colCount.to_s.cyan

colNames = ''
sth.column_names.each do |name|
    colNames.concat(name + " | ")
end
puts colNames.blue

while row = sth.fetch do
    rowValues = ''
    # for i in (0 .. 9) do, für jede Spalte also:
    (0 .. colCount - 1).each do |n|
        val = row[n].to_s
        rowValues.concat(val + ' | ' )
    end
    puts rowValues
end
sth.finish

dbh.disconnect if dbh
