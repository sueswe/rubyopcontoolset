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
    opts.banner = "Usage: lsam [options]"

    options[:databaseName] = nil
    opts.on('-d', '--databasename DB','DB-Name (prod, test, entw)') do |dbname|
        options[:databaseName] = dbname
    end

    options[:schedulename] = nil
    opts.on('-s', '--schedulename STR','Schedule Name (e.g.: 1-%MVB )') do |sname|
        options[:schedulename] = sname
    end

    options[:jobname] = nil
    opts.on('-j','--jobname STR','Job Name (e.g.: bciabr )') do |jn|
        options[:jobname] = jn
    end

    opts.on( '-h', '--help', 'Display this screen' ) do
        puts "Description: lookup jobs with a frequency set to \"Do Not Schedule\"."
        puts opts
        exit
    end
end
optparse.parse!

if options[:databaseName] == nil
    puts optparse
    #text = "use -h for Help."
    #puts text.cyan
    exit 2
end

if options[:databaseName]
    DB = "#{options[:databaseName]}"
    puts "Name of Database: " + DB.red
end

def dbConnect
  $usr = Read_config.new.get_dbuser
  $pwd = Read_config.new.get_dbpwd
  dbh = DBI.connect("DBI:ODBC:opconxps_#{DB}","#{$usr}","#{$pwd}")
end

if options[:schedulename]
  sname = options[:schedulename]
else
  puts "Need a ScheduleName."
  exit 1
end

if options[:jobname]
  jn = options[:jobname]
end

################################################################################
#
# SQL
#
sql_old = ("
SELECT
   SKDNAME,JOBNAME,FREQNAME
 FROM [dbo].[JSKD]
 JOIN SNAME ON (jskd.SKDID = SNAME.SKDID)
 WHERE STSTATUS = '-1'
 ORDER BY SKDNAME
 ;
")

sql = ("
  select skdname,jobname,freqname,isnull(jobstate,'Do Not Schedule') AS 'STATE',jskd.STSTATUS
  from jskd
  join sname on jskd.skdid = sname.skdid
  left JOIN JSTATMAP ON jskd.ststatus = JSTATMAP.STSTATUS
  where skdname LIKE '%#{sname}%'
  and jobname LIKE '%#{jn}%'
  and freqname LIKE '%'
  and jskd.ststatus LIKE '-1'
")
################################################################################

dbh = dbConnect

sth = dbh.execute(sql)

colCount = sth.column_names.size

colNames = ''
sth.column_names.each do |name|
    colNames.concat(name + ' | ')
end

while row = sth.fetch do
    rowValues = ''
    # for i in (0 .. 9) do
    (0 .. colCount - 1).each do |n|
        val = row[n]
        if val.nil?
            val = '<<NULL>>'
        end
        # rowValues.concat(val.ljust(30) + " ; ")
        rowValues.concat(val + ' | ')
        #rowValues.concat(val)
    end
    puts rowValues
end
sth.finish

dbh.disconnect if dbh
