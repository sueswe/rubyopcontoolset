#!/usr/bin/ruby

require 'net/ssh'

Net::SSH.start('lvgom02.sozvers.at', 'sueswe') do |ssh|
    out = ssh.exec!("una_me -a")
    puts out
end


Net::SSH.start('lvgom02.sozvers.at', 'sueswe') do |ssh|
    channel = ssh.open_channel do |ch|
        ch.exec "una_me -a; echo \"rtc=$?\"" do |ch, success|
            raise "command not ok" unless success
            # "on_data" is called when the process writes something to stdout
            ch.on_data do |c, data|
                $stdout.print data
            end
            # "on_extended_data" is called when the process writes something to stderr
            ch.on_extended_data do |c, type, data|
                $stderr.print data
            end
            ch.on_close { puts "(remote command done.)" }
        end
    end
    channel.wait
    
end
