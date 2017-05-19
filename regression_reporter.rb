#!/usr/bin/env ruby
=begin
  Date: 2017
  Author: oscarriddle
  Description:
   1) Traverse all the sim.log and summarize error types then generate daily&weekly reports
=end

def fetch_version()
  File.open($PROJ_SRC_ROOT+"/"+$PROJ_NAME+"./git/refs/heads/master") do |version|
  line_ver=version.gets.chomp
end

def print_summary()
  File.open($PROJ_GEN_ROOT+"/"+$PROJ_NAME+"/verif/mem/env/summary.log") do |summary|
  while line=summary.gets
  if(line.include?("rs"))
    $cmd=line
    puts "Command: "
    puts line
  else
    puts line
  end
end

def traverse(path,word)
  if File.directory?(path)
    dir=Dir.open(path)
    while name = dir.read
      next if name == "."
      next if name == ".."
      traverse(path+"/"+name,word)
    end
  else
    if(path.include?("~")||path.include?("#")||path.include?(".nfs")||
      path.include?("log")||path.include?("fsdb")||path.include?($output_file))
    elsif path.include?("sim.log")
      path.scan(/sim\/\/(\S+)\//) do |testname|
        puts testname
        process_file(path,word,testname)
      end
    end
  end
end
