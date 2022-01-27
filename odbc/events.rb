#!/usr/bin/env ruby

require 'dbi'
require 'optionparser'
require 'colorize'

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

    options[:databasename] = nil
    opts.on('-d', '--databasename STR','mandatory; database name (prefix = \'opconxps_\')') do |dbname|
        options[:databasename] = dbname
    end
    options[:schedulename] = nil
    opts.on('-s', '--schedulename STR','Schedule Name') do |sname|
        options[:schedulename] = sname
    end
    options[:jobname] = nil
    opts.on('-j','--jobname STR','Job Name') do |jn|
        options[:jobname] = jn
    end
    options[:eventname] = nil
    opts.on('-e','--event STR', 'Event String') do |es|
        options[:eventname] = es
    end
    opts.on( '-h', '--help', 'Display this screen' ) do
        puts "Description: selects EVENTS with Jobname, Eventstring and Schedulename."
        puts opts
        #puts String.colors
        #puts String.modes
        #puts String.color_samples
        exit
    end
end
optparse.parse!


if options[:databasename]

    $dataBaseShortname = "#{options[:databasename]}"

    if options[:schedulename]
        schedulename = "#{options[:schedulename]}"
    else
        puts "Sorry, i need a Schedulename. "
        puts "Use '#{myname} -h' for help.".cyan
        exit 2
    end
    if options[:jobname]
        jobname = "#{options[:jobname]}"
    else
        puts "(no jobname given. It's okay.)".rjust(60)
    end
    if options[:eventname]
        event = "#{options[:eventname]}"
    else
        puts "(no eventname given. It's okay.)".rjust(60)
    end
else
    puts "Sorry, missing DATABASE-Name-Option.\nUse '#{myname} -h' for help.".red
    exit 1
end


puts "dataBaseShortname = #{$dataBaseShortname}".green
puts "ScheduleName = #{schedulename}".green
puts "Jobname = #{jobname}".green
puts "Eventstring = #{event}".green
#exit

###############################################################################
sql = ("
SELECT
    SKDNAME,JOBNAME,EVDETS,JOBSTATUS
FROM JEVENTS
    JOIN SNAME ON (jevents.SKDID=SNAME.SKDID)
WHERE SKDNAME LIKE '%#{schedulename}%'
AND jobname LIKE '%#{jobname}%'
AND EVDETS LIKE '%#{event}%'
ORDER BY SKDNAME;
")
###############################################################################

def dbConnect
  $usr = Read_config.new.get_dbuser
  $pwd = Read_config.new.get_dbpwd
  dbh = DBI.connect("DBI:ODBC:opconxps_#{$dataBaseShortname}","#{$usr}","#{$pwd}")
end

################################################################################

puts "#{sql}".blue

dbh = dbConnect

sth = dbh.execute(sql)

colCount = sth.column_names.size

colNames = ''
sth.column_names.each do |name|
    colNames.concat(name.ljust(10))
end

while row = sth.fetch do
    rowValues = ''

    (0 .. colCount - 1).each do |n|
        val = row[n].to_s

        rowValues.concat(val + ' | ')
    end
    puts rowValues
end
sth.finish

dbh.disconnect if dbh
