#!/usr/bin/env ruby

# apt install ruby-dev, unixodbc, unixodbc-dev
# gem install dbi dbd-odbc ruby-odbc

require 'dbi'
require 'colorize'
require 'optparse'

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

    options[:countdistinct] = nil
    opts.on('-c','--count-distinct','retrieve the count of distinct (different) frequencies') do |x|
      options[:countdistinct] = true
    end

    opts.on( '-h', '--help', 'Display this screen' ) do
        puts "Description: selects all Frequencies, including Frequency-Code and After/On/Before/NotSchedule-configuration."
        puts opts
        #puts String.colors
        #puts String.modes
        #puts String.color_samples
        exit
    end
end
optparse.parse!

if options[:databaseName] == nil
    #puts "Missing DB name. Use -h for help.".cyan
    puts optparse
    exit 2
end


if options[:databaseName]
    DB = "#{options[:databaseName]}"
end

sql_distinct = ("
  select distinct FREQCODE, count(distinct FREQNAME) as ct from JSKD
  group by FREQCODE
  having count(distinct FREQNAME) > 1
  ;
")

sql = ("
SELECT DISTINCT FREQNAME, FREQCODE, AOBN, CALID
--SELECT DISTINCT FREQNAME, FREQCODE, AOBN, SKDNAME, JOBNAME
FROM jskd
JOIN sname ON jskd.SKDID = sname.skdid
order by FREQNAME
;
")


def dbConnect
  $usr = Read_config.new.get_dbuser
  $pwd = Read_config.new.get_dbpwd
  dbh = DBI.connect("DBI:ODBC:opconxps_#{DB}","#{$usr}","#{$pwd}")
end

dbh = dbConnect

if options[:countdistinct] == true
  sth = dbh.execute(sql_distinct)
else
  sth = dbh.execute(sql)
end

colCount = sth.column_names.size
colNames = ''
sth.column_names.each do |name|
  colNames.concat(name + " | ")
end
while row = sth.fetch do
  rowValues = ''
  (0 .. colCount - 1).each do |n|
    val = row[n].to_s
    if val == '0'
      val = '(no cal)'
    end
    rowValues.concat(val + ' | ')
  end
  puts rowValues
end

sth.finish

dbh.disconnect if dbh
