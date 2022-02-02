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

    options[:schedulename] = nil
    opts.on('-s', '--schedule-name SN', 'Schedule-Name') do |schname|
        options[:schedulename] = schname
    end

    options[:jobname] = nil
    opts.on('-j', '--jobname JN', 'Job-Name') do |jbn|
        options[:jobname] = jbn
    end

    options[:value] = nil
    opts.on('-v', '--value V', 'JA-Value') do |val|
        options[:value] = val
    end

    opts.on( '-h', '--help', 'Display this screen' ) do
        puts "Description: selects MASTER-Jobs - configurations."
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
else
    DB = "#{options[:databaseName]}"
    puts "Name of Database: ".rjust(20) + DB.red
end

if options[:schedulename] == nil
    SCHEDULENAME = "%"
else
    SCHEDULENAME = options[:schedulename]
end
puts "Schedulename: ".rjust(20) + SCHEDULENAME.red

if options[:jobname] == nil
    JOBNAME = "%"
else
    JOBNAME = options[:jobname]
end
puts "Job: ".rjust(20) + JOBNAME.red

if options[:value] == nil
    JAVALUE = "%"
else
    JAVALUE = options[:value]
end
puts "ja-value: ".rjust(20) + JAVALUE.red


################################################################################
#
# SQL
#
sql = ("
    select skdname,jmaster.jobname,javalue
    from jmaster
    join sname on jmaster.skdid = sname.skdid
    join jmaster_aux on jmaster.skdid = jmaster_aux.skdid and jmaster.jobname = jmaster_aux.jobname
    where skdname like '#{SCHEDULENAME}'
    and jmaster.jobname like '#{JOBNAME}'
    and javalue like '#{JAVALUE}'
    ")
#
#--and jafc like (?)


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
puts "(ColCount: " + colCount.to_s.cyan + ")"

colNames = ''
sth.column_names.each do |name|
    colNames.concat(name.ljust(10))
end
puts colNames.blue

while row = sth.fetch do
    rowValues = ''
    (0 .. colCount - 1).each do |n|
        #val = row[n].to_s.yellow
        val = row[n]
        rowValues.concat(val + ' | ')
    end
    puts rowValues
end
sth.finish

dbh.disconnect if dbh
