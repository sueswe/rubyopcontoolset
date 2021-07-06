#!/usr/bin/env ruby

require 'net/http'
#require 'win32/api'
require 'logger'

log = Logger.new(STDOUT)
log.formatter = proc do |severity, datetime, progname, msg|
  "#{severity} #{datetime}: #{msg}\n"
end

class MAILME
  def recipient
    puts "Empfaenger"
  end
end

def check_elog
    response = Net::HTTP.get_response('lvgom01.sozvers.at', '/', 8080)
    puts response.body
    return response.code.to_i
end

def check_jenkins
    response = Net::HTTP.get_response('lvgom01.sozvers.at', '/', 8180)
    puts response.body
    return response.code.to_i
end



if check_elog == 200
    log.info "ELOG is up an running."
else
    log.error "WARNING: ELOG is not online!"
    notify = %x(notify-send "ELOG is not online!")
end


if check_jenkins == 200
    log.info "Jenkins is up an running."
else
    log.error "WARNING: Jenkins is not online!"
    notify = %x(notify-send "Jenkins is not online!")
end
