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

    options[:job] = nil
    opts.on('-j', '--jobname JOB', 'Job-Name') do |jobname|
        options[:job] = jobname
    end

    options[:sname] = nil
    opts.on('-s', '--schedule SCHED', 'Schedule-Name') do |s|
        options[:sname] = s
    end

    opts.on( '-h', '--help', 'Display this screen' ) do
        puts "Description: enables the possibility to search the HISTORY-table."
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
    puts optparse
    exit 2
end
if options[:job] == nil
    puts "Missing jobname. Use -h for help.".cyan
    puts optparse
    exit 2
end
if options[:databaseName]
    # Ruby Constants
    # https://www.tutorialspoint.com/ruby/ruby_variables.htm
    # Constants begin with an uppercase letter. Constants defined within a
    # class or module can be accessed from within that class or module,
    # and those defined outside a class or module can be accessed globally.
    # (Für den connect wird eine Methode dbConnect verwendet weiter unten)
    DB = "#{options[:databaseName]}"
end
if options[:sname]
    schedulename = "#{options[:sname]}"
end
if options[:job]
    jname = "#{options[:job]}"
end

#
# SQL
#
sql = ("
    SELECT skdname, JOBNAME, convert(smalldatetime,JTERM) - 2 as 'END', convert(smalldatetime,JSTART) - 2 as 'START', JRUN as 'Minutes', JSTAT as 'jobstate'
    FROM dbo.HISTORY
    JOIN SNAME ON (HISTORY.SKDID=SNAME.SKDID)
        WHERE SKDDATE > convert(smalldatetime,'2019-01-01') + 2
        AND (SKDNAME LIKE '%#{schedulename}%' )
        --AND JSTAT = '900'
        --AND JRUN > '0'
        AND JOBNAME like '#{jname}'
    --group by SKDNAME,JOBNAME,SKDDATE
    --order by SKDNAME,JOBNAME,SKDDATE
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

colCount = sth.column_names.size

colNames = ''
sth.column_names.each do |name|
    colNames.concat(name.ljust(15))
end
puts colNames

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
