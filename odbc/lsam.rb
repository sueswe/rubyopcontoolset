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
lsamList = ("
  SELECT machname as Host, ma.mavalue as OS, ma2.MAVALUE as LSAMversion, ma3.MAVALUE as host, ma4.MAVALUE, ma5.MAVALUE, NETSTATUS
      FROM MACHS m
      JOIN MACHS_AUX ma ON m.machid = ma.machid AND ma.mafc = 137
      JOIN MACHS_AUX ma2 ON m.machid = ma2.machid AND ma2.mafc = 135
      JOIN MACHS_AUX ma3 ON m.machid = ma3.machid AND ma3.mafc = 129
      JOIN MACHS_AUX ma4 ON m.machid = ma4.machid AND ma4.mafc = 120
      JOIN MACHS_AUX ma5 ON m.machid = ma5.machid AND ma5.mafc = 143
      --ORDER BY OS
      ORDER BY LSAMversion DESC
    ")
################################################################################

#puts lsamList

options = {}
optparse = OptionParser.new do |opts|
    opts.banner = "Usage: lsam [options]"

    options[:databaseName] = nil
    opts.on('-d', '--databasename DB','mandatory; database name (prefix = \'opconxps_\')') do |dbname|
        options[:databaseName] = dbname
    end
    opts.on( '-h', '--help', 'Display this screen' ) do
        puts "Description: selects agents, OS, ports, and connect-status."
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

puts "NETSTATUS:
    This column contains the current status of the network connections between SMANetCom and the LSAM machines."
#puts "OPERSTATUS:
#    This column contains the current statuses of the LSAMs as set by Events or by the graphical interfaces.
#    These statuses decide whether SMANetCom should communicate with each LSAM.
#"

dbh = dbConnect

sth = dbh.execute(lsamList)

# colCount wird für die loop benötigt:
colCount = sth.column_names.size
#puts "ColCount:         " + colCount.to_s.red

# loop über die Spaltenamen:
colNames = ''
sth.column_names.each do |name|
    colNames.concat(name + " ; ")
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
        #rowValues.concat(val.ljust(30) + " ; ")
        rowValues.concat(val + ' ; ')
    end
    puts rowValues
end
sth.finish

dbh.disconnect if dbh
