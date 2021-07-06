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
    opts.on('-d', '--databasename STR','Database-Name') do |dbname|
        options[:databasename] = dbname
    end
    options[:sname] = nil
    opts.on('-s', '--schedulename STR', 'Schedulename (Optional)') do |sn|
      options[:sname] = sn
    end
    options[:jobname] = nil
    opts.on('-j','--jobname STR','Job Name (Optional)') do |jn|
        options[:jobname] = jn
    end
    options[:resname] = nil
    opts.on('-r','--ressource STR', 'Ressource Name (Optional)') do |es|
        options[:resname] = es
    end
    opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        #puts String.colors
        #puts String.modes
        #puts String.color_samples
        puts "\nAusgabebeschreibung:".yellow
        puts "Schedulename | Jobname | Anzahl genutzte Ressourcen | Ressource-Name |".yellow
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

    if options[:sname]
        schedule= options[:sname].to_s
    else
      puts "(no Schedulename given. It's okay.)".rjust(60)
  end
    if options[:jobname]
        jobname = "#{options[:jobname]}"
    else
        puts "(no jobname given. It's okay.)".rjust(60)
    end
    if options[:resname]
        ressource = "#{options[:resname]}"
    else
        puts "(no ressource name given. It's okay.)".rjust(60)
    end
else
    puts "Sorry, missing DATABASE-Name-Option.\nUse '#{myname} -h' for help.".red
    exit 1
end


puts "dataBaseShortname = #{$dataBaseShortname}".green
puts "Jobname = #{jobname}".green
puts "Schedule = #{schedule}".green
puts "Ressourcestring = #{ressource}".green
#exit

###############################################################################
sql = ("
SELECT SKDNAME,JOBNAME,THRESHUSED,THRESH.THRESHDESC
FROM JDEPTHR
JOIN THRESH ON (JDEPTHR.DEPTHRID = THRESH.THRESHID)
JOIN SNAME ON (JDEPTHR.SKDID=SNAME.SKDID)
WHERE jobname LIKE '%#{jobname}%'
AND THRESHDESC LIKE '%#{ressource}%'
and SKDNAME LIKE '%#{schedule}%'
ORDER BY THRESHDESC
")
###############################################################################

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

#puts "#{sql}".blue

dbh = dbConnect

# Ein Parameter lässt sich übergeben, zwei aber nicht mit '(?)':
sth = dbh.execute(sql)

# colCount wird für die loop benötigt:
colCount = sth.column_names.size
#puts "ColCount:         " + colCount.to_s.red

# loop über die Spaltenamen:
colNames = ''
sth.column_names.each do |name|
    colNames.concat(name.ljust(10))
end
#puts colNames

while row = sth.fetch do
    rowValues = ''

    # for i in (0 .. 9) do, für jede Spalte also:
    (0 .. colCount - 1).each do |n|
        val = row[n].to_s

        rowValues.concat(val + ' | ')
    end
    puts rowValues
end
sth.finish

dbh.disconnect if dbh
