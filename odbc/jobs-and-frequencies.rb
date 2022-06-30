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

options = {}
optparse = OptionParser.new do |opts|
    opts.banner = "Usage: properties [options]"
    options[:databaseName] = nil
    opts.on('-d', '--databasename DB','mandatory; database name (prefix = \'opconxps_\')') do |dbname|
        options[:databaseName] = dbname
    end
    options[:schedule] = nil
    opts.on('-s', '--schedule SCHEDULENAME','Schedule Name') do |sn|
        options[:schedule] = sn
    end
    opts.on( '-h', '--help', 'Display this screen' ) do
        puts "Description: selects MASTER-Job - configurations and frequencies."
        puts opts
        exit
    end
end
optparse.parse!

if options[:databaseName] == nil
    #text = "use -h for Help."
    #puts text.cyan
    puts optparse
    exit 2
end

if options[:databaseName]
    DB = "#{options[:databaseName]}"
    puts "Name of Database: " + DB.red
end

if options[:schedule]
    schedulename = "#{options[:schedule]}"
    puts "Name of schedule: " + schedulename.red
end

puts "Note: selects no OR frequencies.".cyan

#
# Methods
#

def dbConnect
  $usr = Read_config.new.get_dbuser
  $pwd = Read_config.new.get_dbpwd
  dbh = DBI.connect("DBI:ODBC:opconxps_#{DB}","#{$usr}","#{$pwd}")
end
################################################################################
#
# SQL
#
structuredQueryLanguage = ("
SELECT distinct skdname,jobname,freqname,
(
SELECT javalue
from jmaster_aux ja
JOIN sname sa ON ja.skdid = sa.skdid
where ja.jafc = 6001
and sa.skdname = s.skdname
and ja.jobname = j.jobname
),
(
SELECT javalue
from jmaster_aux ja2
JOIN sname sa2 ON ja2.skdid = sa2.skdid
where ja2.jafc = 6002
and sa2.skdname = s.skdname
and ja2.jobname = j.jobname
)
FROM jskd j
JOIN sname s ON j.skdid = s.skdid
WHERE s.skdname like '#{schedulename}'
--and j.freqname not like 'OR%'
")
#
#
################################################################################

################################################################################

dbh = dbConnect

sth = dbh.execute(structuredQueryLanguage)

colCount = sth.column_names.size
puts "ColCount:         " + colCount.to_s.red

colNames = ''
sth.column_names.each do |name|
    colNames.concat(name + ' | ')
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
        rowValues.concat(val + ' | ')
    end
    puts rowValues
end
sth.finish

dbh.disconnect if dbh
