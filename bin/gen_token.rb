#!/usr/bin/env ruby

require 'gdata'
require 'yaml'

token_file = "token.yaml"

print "Username: "
user = $stdin.gets.chomp

print "Password: "
%x{stty -echo}
pass = $stdin.gets.chomp
%x{stty echo}
puts
print "Service: "
service = $stdin.gets.chomp

auth = GData::Auth::ClientLogin.new(user, pass, service)
token = auth.token

if token.nil?
  $stderr.puts "Authentication failed"
  exit
end

token_hash = { :token => token, :created => Time.now }

File.open(token_file, "w") do |f|
  f.write(YAML.dump(token_hash))
  f.chmod(0600)
end

puts "Token information written to #{token_file}"
