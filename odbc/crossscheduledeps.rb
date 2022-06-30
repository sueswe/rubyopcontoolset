#!/usr/bin/env ruby

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
    opts.banner = "Usage: crossscheduledeps.rb [options]"
    options[:databaseName] = nil
    opts.on('-d', '--databasename DB','mandatory; database name (prefix = \'opconxps_\')') do |dbname|
        options[:databaseName] = dbname
    end
    options[:schedulename] = nil
    opts.on('-s', '--schedule-name SN', 'Schedule-Name') do |schname|
        options[:schedulename] = schname
    end
    opts.on( '-h', '--help', 'Display this screen' ) do
        puts "Description: selects jobs with cross-schedule-dependencies"
        puts opts
        exit
    end
end
optparse.parse!


if options[:databaseName] == nil
    puts optparse
    exit 1
else
    DB = "#{options[:databaseName]}"
end

if options[:schedulename] == nil
    puts optparse
    exit 1
else
    schedulename = options[:schedulename]
end


################################################################################
#
# Methods
#
################################################################################
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
    select a.skdname,jobname,depjobname,b.skdname from jdepjob
    join sname a on jdepjob.skdid = a.skdid join sname b on jdepjob.depskdid = b.skdid
    where a.skdname like '#{schedulename}'
    and jdepjob.skdid != jdepjob.depskdid
")
################################################################################

dbh = dbConnect
sth = dbh.execute(structuredQueryLanguage)

colCount = sth.column_names.size

colNames = ''
sth.column_names.each do |name|
    colNames.concat(name + ' | ')
end
puts colNames

while row = sth.fetch do
    rowValues = ''
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
