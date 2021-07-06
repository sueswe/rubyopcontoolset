#!/usr/bin/env ruby
# Checke auf POP3-Server Emails
require 'net/pop'
pop = Net::POP3.new('mail.sv-services.at', 110)
#pop.set_debug_output $stderr

user = ARGV[0]
pwd = ARGV[1]

if user == nil
  puts "Usage: pop3check username password"
  exit 1
end
if pwd == nil
  puts "Usage: pop3check username password"
  exit 2
end

pop.start("#{user}","#{pwd}")
if pop.mails.empty?
    puts "Keine Emails"
else
    i = 1
    pop.mails.each do |m|
        #puts "Email Nummer #{i}: #{m} \n"
        #File.open("message_#{i}", 'w') do |f|
        #    f.read m.pop
        #end
        i += 1
    end
end
pop.finish
puts "There are #{i} Mails on the Server."
