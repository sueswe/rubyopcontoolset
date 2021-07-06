#!/usr/bin/env ruby

# Open Schedules.

require 'dbi'
require 'optionparser'
require 'colorize'
require 'json'
require 'net/http'

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

sql = ('
SELECT top %d convert(datetime,skddate)-2,skdname,count(jobname)
FROM SMASTER
JOIN SNAME ON SMASTER.skdid = SNAME.skdid
WHERE jobstatus = 0
GROUP BY skddate,skdname
ORDER BY skddate
')

myname = File.basename(__FILE__)
options = {}
optparse = OptionParser.new do |opts|
    opts.banner = "Usage: #{myname} [options]"

    options[:databasename] = nil
    opts.on('-d', '--databasename DB','Database-Name') do |dbname|
        options[:databasename] = dbname
    end
    options[:number] = 15
    opts.on('-n', '--number NUM','Output the last NUM lines, instead of the last 15') do |lines|
        options[:number] = lines
    end
    options[:quiet] = false
    opts.on('-q', '--quiet','Don\'t post to Grape Chat') do
        options[:quiet] = true
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

if options[:databasename]

    # Ruby Constants
    # https://www.tutorialspoint.com/ruby/ruby_variables.htm
    # Constants begin with an uppercase letter. Constants defined within a
    # class or module can be accessed from within that class or module,
    # and those defined outside a class or module can be accessed globally.
    # (Für den connect wird eine Methode dbConnect verwendet weiter unten)

    # Es geht aber auch eine globale, beginnend mit $ :
    $dataBaseShortname = "#{options[:databasename]}"
else
    puts "Sorry, missing DATABASE-Name-Option.\nUse '#{myname} -h' for help.".red
    exit 1
end


puts "dataBaseShortname = #{$dataBaseShortname}".green

################################################################################
def dbConnect
  $usr = Read_config.new.get_dbuser
  $pwd = Read_config.new.get_dbpwd
  dbh = DBI.connect("DBI:ODBC:opconxps_#{DB}","#{$usr}","#{$pwd}")
end
################################################################################

dbh = dbConnect

# Ein Parameter lässt sich übergeben, zwei aber nicht mit '(?)':
sth = dbh.execute(sql % options[:number])

# colCount wird für die loop benötigt:
colCount = sth.column_names.size
#puts "ColCount: ".rjust(20) + colCount.to_s.red

# loop über die Spaltenamen:
colNames = ''
#sth.column_names.each do |name|
#    colNames.concat(name + " | ")
#end
#puts colNames.blue

result = ''

while row = sth.fetch do
    rowValues = ''
    # for i in (0 .. 9) do, für jede Spalte also:
    (0 .. colCount - 1).each do |n|
        val = row[n].to_s
        val.sub!('T00:00:00+00:00','')
        rowValues.concat(val + ' ' )
    end
    puts rowValues
    result = result.concat( " ; \n" + rowValues)
end
sth.finish
dbh.disconnect if dbh

url = 'https://chat.sozvers.at/services/hook/custom/1/94fc48c4759a11ebb21d0242ac140a08/'
data = { 'payload' => JSON.dump({ 'username' => 'OM-STP-GrapeBot', 'text' => "Open Schedules @ #{$dataBaseShortname}: #{result}" }) }
puts data

if not options[:quiet]
  Net::HTTP.post_form(URI.parse(url), data)
end
