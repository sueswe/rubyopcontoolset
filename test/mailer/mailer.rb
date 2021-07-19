#!/usr/bin/env ruby

require 'net/smtp'
require 'optionparser'

ME = File.basename(__FILE__)

def help
    puts "Usage:"
    puts "#{ME} --from a --to b --cc CC --subject text --message text --attach filename*"
end

#help

options = {}
optparse = OptionParser.new do |opts|
    opts.banner = "Usage: #{ME} [options]"

    # Structs anlegen:
    options[:from] = nil
    options[:to] = nil
    options[:subject] = nil
    options[:message] = nil

    opts.on('-f','--from FROM', 'Absender') do |from|
        options[:from] = from
    end

    opts.on('-t','--to TO', 'Empfänger') do |to|
        options[:to] = to
    end

    opts.on('-s','--subject SUBJECT', 'Betreff') do |subj|
        options[:subject] = subj
    end

    opts.on('-m','--message MSG', 'Nachricht') do |msg|
        options[:message] = msg
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

von = options[:from]
an = options[:to]
betreff = options[:subject]
body = options[:message]

marker = "AUNIQUEMARKER"

message = <<END_OF_MESSAGE
From: #{von}
To: #{an}
MIME-Version: 1.0
Content-type: text/html
Subject: #{betreff}

A bit of plain text.

<strong>The beginning of your HTML content.</strong>
<h1>And some headline, as well.</h1>
END_OF_MESSAGE

puts message
