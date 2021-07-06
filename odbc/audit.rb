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
    puts "Name of Database: " + DB
end

if options[:fromdate] == nil
    puts "Missing FROM_DATE (yyyy-mm-dd). Use -h for help.".cyan
    exit 2
else
    from_date = "#{options[:fromdate]}"
    puts "fromdate: #{from_date}"
end

if options[:todate] == nil
    to_date = from_date
    #puts "Missing TO_DATE (yyyy-mm-dd). Use -h for help.".cyan
    #exit 2
else
    to_date = "#{options[:todate]}"
    puts "todate: #{to_date}"
end



################################################################################
#
# SQL
#
sql = ("
SELECT convert(smalldatetime,UPDTIMESTAMP)
    ,LTRIM(RTRIM(OPCONUSERNAME))
    ,HOSTNAME
    ,TBLNAME
    ,BEFOREVALUE
    ,AFTERVALUE
    ,KEY1,key2,key3,key4,key5,key6
FROM AUDITRECSVIEW
WHERE UPDTIMESTAMP >= '#{from_date} 00:00:00.000'
AND UPDTIMESTAMP <= '#{to_date} 23:59:59.999'
ORDER BY UPDTIMESTAMP asc
;
")
################################################################################

def dbConnect
  $usr = Read_config.new.get_dbuser
  $pwd = Read_config.new.get_dbpwd
  dbh = DBI.connect("DBI:ODBC:opconxps_#{DB}","#{$usr}","#{$pwd}")
end

################################################################################

dbh = dbConnect

sth = dbh.execute(sql)

# colCount wird für die loop benötigt:
colCount = sth.column_names.size
puts "ColCount: " + colCount.to_s.cyan

# loop über die Spaltenamen:
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
