#!/usr/bin/env ruby

require 'net/http'
require 'win32/api'
require 'logger'

$stdout.sync = true

log = Logger.new(STDOUT)
log.formatter = proc do |severity, datetime, progname, msg|
  "#{severity} #{datetime}: #{msg}\n"
end

SERVICES = {
  "homepage" => "scheduling.sozvers.at:80" ,
  "jenkins" => "lvgom01.sozvers.at:8180" ,
  "elog" => "lvgom01.sozvers.at:8080"
}


def error_popup(s,p)
  messageBox = Win32::API.new("MessageBox", 'LPPI', 'I', "user32")
  mb_OK = 0x00000000
  mb_OKCANCEL = 0x00000001
  mb_ABORTRETRYIGNORE = 0x00000002
  mb_YESNOCANCEL = 0x00000003
  mb_YESNO = 0x00000004
  mb_RETRYCANCEL = 0x00000005
  mb_ICONHAND = 0x00000010
  mb_ICONQUESTION = 0x00000020
  mb_ICONEXCLAMATION = 0x00000030
  mb_ICONASTERISK = 0x00000040
  mb_ICONINFORMATION = mb_ICONASTERISK
  mb_ICONSTOP = mb_ICONHAND
  messageBox.call(0, "Verbindungsproblem mit #{s} , Port #{p}", "Server-Verbindungs-Fehler", mb_OK | mb_ICONINFORMATION)
end


def check_service(u,p)
  x = Net::HTTP.new(u, p)
  x.read_timeout = 5

  begin
    response = x.request_get("index.html")
    return "OK #{u}:#{p}"
  rescue
    error_popup("#{u}",p)
    return "ERROR bei #{u}:#{p}"
  end
end


SERVICES.each do |v|
  #puts v[0] +  " : " + v[1]
  r = v[1].split(':')
  server = r[0]
  port = r[1]
  puts check_service(server,port)
end
