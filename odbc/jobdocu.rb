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


################################################################################

options = {}
optparse = OptionParser.new do |opts|
    opts.banner = "Usage: properties [options]"
    options[:databaseName] = nil
    opts.on('-d', '--databasename DB','DB Name') do |x|
        options[:databaseName] = x
    end
    options[:schedulename] = nil
    opts.on('-s', '--schedule-name SN', 'Schedule-Name') do |x|
        options[:schedulename] = x
    end
    opts.on( '-h', '--help', 'Display this screen' ) do
        puts "Kurzbeschreibung: Ausgeben von Job-Documentation-Feldern."
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

if options[:databaseName]
    DB = "#{options[:databaseName]}"
    puts "Name of Database: " + DB.cyan
end

if options[:schedulename]
  sname = "#{options[:schedulename]}"
  puts "Name of Schedule: " + sname.cyan
end

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

################################################################################
#
# SQL
#
structuredQueryLanguage = ("
SELECT jobname,doctext,docline
FROM JDOCS
JOIN sname on jdocs.skdid = sname.skdid
AND skdname like '#{sname}'
")

dbh = dbConnect

sth = dbh.execute(structuredQueryLanguage)




# colCount wird für die loop benötigt:
colCount = sth.column_names.size
#puts "ColCount:         " + colCount.to_s.red

# loop über die Spaltenamen:
colNames = ''
sth.column_names.each do |name|
    colNames.concat(name.ljust(50))
end
puts colNames.blue

while row = sth.fetch do
    rowValues = ''
    # for i in (0 .. 9) do
    (0 .. colCount - 1).each do |n|
        val = row[n]
        if val.nil?
            val = '<<NULL>>'
        end
        rowValues.concat(val + ' ; ')
    end
    puts rowValues
end
sth.finish

dbh.disconnect if dbh
