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
    opts.on('-d', '--databasename DB','Database-Name') do |dbname|
        options[:databaseName] = dbname
    end

    options[:landesstelle] = nil
    opts.on('-l', '--landesstelle LS', 'Schedule-Name') do |landstell|
        options[:landesstelle] = landstell
    end

    opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        #puts String.colors
        #puts String.modes
        #puts String.color_samples
        exit
    end
end
optparse.parse!

if options[:databaseName] == nil
    puts "Missing DB name. Use -h for help.".cyan
    exit 2
end
if options[:landesstelle] == nil
    puts "Missing LandesStelle. Use -h for help.".cyan
    exit 2
end

if options[:databaseName]
    DB = "#{options[:databaseName]}"
    puts "Name of Database: ".rjust(20) + DB.red
end
if options[:landesstelle]
    ls = "#{options[:landesstelle]}"
    puts "Schedulename: ".rjust(20) + ls.red
end

################################################################################
#
# SQL
#
sql = ("
select CALNAME, convert(smalldatetime,CALDATE-2) as DATUM from CALDATA
join CALDESC on CALDATA.CALID = CALDESC.CALID
where CALNAME like '#{ls}%'
order by DATUM DESC
")
################################################################################


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

# Ein Parameter lässt sich übergeben, zwei aber nicht mit '(?)':
sth = dbh.execute(sql)

# colCount wird für die loop benötigt:
colCount = sth.column_names.size
puts "ColCount:         " + colCount.to_s.red

# loop über die Spaltenamen:
colNames = ''
sth.column_names.each do |name|
    colNames.concat(name.ljust(10))
end
puts colNames.blue

while row = sth.fetch do
    rowValues = ''

    # for i in (0 .. 9) do, für jede Spalte also:
    (0 .. colCount - 1).each do |n|

        val = row[n].to_s.yellow
        val.sub!('T00:00:00+00:00','')
        rowValues.concat(val + ' | ')
    end
    puts rowValues
end
sth.finish

dbh.disconnect if dbh
