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
#
# SQL
#
structuredQueryLanguage = ("
    select DISTINCT SKDNAME,SAVALUE from SNAME
    JOIN SNAME_AUX ON SNAME.skdid = SNAME_AUX.skdid
    --where SAFC = 0
    ORDER BY SKDNAME ASC;
    ")

autobuild = ("
    select distinct SKDNAME from sname_aux
    join sname on sname_aux.skdid = sname.skdid
    and (safc = 105 or safc = 109)
")
#
#
################################################################################

options = {}
optparse = OptionParser.new do |opts|
    opts.banner = "Usage: properties [options]"
    options[:databaseName] = nil
    opts.on('-d', '--databasename DB','mandatory; database name (prefix = \'opconxps_\')') do |dbname|
        options[:databaseName] = dbname
    end
    options[:autobuild] = nil
    opts.on('-a', '--autoBuild','Autobuild Flag') do
        options[:autobuild] = true
    end
    opts.on( '-h', '--help', 'Display this screen' ) do
        puts "Description: selects schedules and autobuild-configuration."
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
    puts "Name of Database: " + DB.red
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

dbh = dbConnect

if options[:autobuild] != nil
    sth = dbh.execute(autobuild)
else
    sth = dbh.execute(structuredQueryLanguage)
end



# colCount wird für die loop benötigt:
colCount = sth.column_names.size
puts "ColCount:         " + colCount.to_s.red

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
        rowValues.concat(val.ljust(50))
    end
    puts rowValues
end
sth.finish

dbh.disconnect if dbh
