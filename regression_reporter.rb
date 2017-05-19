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


def process_file(path,word,testname)
  line_name=1
  File.open(path) do |file|
    File.open($root+$output_file, "a") do |data|
      while line = file.gets
        line = line.chomp
        if line.include?(word)
          data.puts path+"::"+line_num.to_s+"::"+line+"\n"
          $KEYWORD_DICT[word]=$KEYWORD_DICT[word].to_i+1
          line.scan(/\*\w,([A-Za-z0-9_-]+)\:*\s/) do |type|
            if (word=="*E")
              if ($ERROR_DICT.has_key?(type))
                $ERROR_DICT[type]=$ERROR_DICT[type].to_i+1
                if (!$ERROR_DICT[type].include?(testname))
                  $ERROR_TESTS[type].push(testname)
                end 
              else
                $ERROR_DICT.store(type,1)
                $ERROR_TESTS[type].push(testname)
              end
            elsif(word=="W")
              if ($WARNING_DICT.has_key?(type))
                $WARNING_DICT[type]=$WARNING_DICT[type].to_i+1
                if (!$WARNING_DICT[type].include?(testname))
                  $WARNING_TESTS[type].push(testname)
                end 
              else
                $WARNING_DICT.store(type,1)
                $WARNING_TESTS[type].push(testname)
              end
            end
          end
        line_num=line_num+1
        else
          line_num=line_num+1
          next
        end
      end
    end
  end
end  
    
# Initialization Section
$root = "./"
$output_file="result.dat"
$date="0"
$PROJ_SRC_ROOT=ENV["PROJ_SRC_ROOT"]
$PROJ_GEN_ROOT=ENV["PROJ_GEN_ROOT"]
$PROJ_NAME=ENV["PROJ_NAME"]
File.open($PROJ_SRC_ROOT+"/"+$PROJ_NAME+"/.git/refs/heads/master") do |version|
  $current_version=version.gets.chomp
end 
date=Time.new

  
  
  
