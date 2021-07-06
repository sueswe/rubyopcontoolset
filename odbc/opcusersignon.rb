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

if options[:databaseName]
    DB = "#{options[:databaseName]}"
    puts "Name of Database: " + DB
end

################################################################################
#
# SQL
#
sql = ("
select   USERSIGNON
        ,USERNAME
        ,UAVALUE
    from USERS_AUX
JOIN USERS ON (USERS.USERID = USERS_AUX.USERID)
where UAFC = '131'
ORDER BY USERSIGNON
;
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
#puts "ColCount: ".rjust(20) + colCount.to_s.red

# loop über die Spaltenamen:
colNames = ''
#sth.column_names.each do |name|
#    colNames.concat(name + " | ")
#end
#puts colNames.blue

while row = sth.fetch do
    rowValues = ''
    # for i in (0 .. 9) do, für jede Spalte also:
    (0 .. colCount - 1).each do |n|
        n.to_s.chomp
        val = row[n].rstrip
        rowValues.concat(val + ' | ' )
    end
    puts rowValues
end
sth.finish

dbh.disconnect if dbh
