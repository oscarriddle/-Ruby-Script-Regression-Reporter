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
year_format=format('%2d',date.year)
month_format=format('%2d',date.month)
day_format=format('%2d',date.day)
hour_format=format('%2d',date.hour)
min_format=format('%2d',date.min)
sec_format=format('%2d',date.sec)
$date=year_format.to_s+month_format.to_s+day_format.to_s+hour_format.to_s+min_format.to_s+sec_format.to_s
  
#--------------------------
if (File.exist?($output_file))
  File.delete($root+$output_file)
else
end
  
$KEYWORD=Array.new()
$KEYWORD[0]="--- TEST PASSED ---"
$KEYWORD[1]="*E"
$KEYWORD[2]="*W"
$KEYWORD_DICT=Hash.new()
$ERROR_DICT=Hash.new()
$ERROR_TEST=Hash.new{|hsh,key| hsh[key]=[]}
$WARNING_DICT=Hash.new()
$WARNING_TEST=Hash.new{|hsh,key| hsh[key]=[]}
$sim_root=$PROJ_GEN_ROOT+"/"+$PROJ_NAME+"/verif/mem/sim/"
for i in 0..($KEYWORD.size-1)
  $KEYWORD_DICT.store($KEYWORD[i],0)
  traverse($sim_root,$KEYWORD[i])
end

puts "[Scanning Finished]"
puts ""
puts ""
puts "===============Summary of Regression Report==============="
puts "$PROJ_SRC_ROOT: "+$PROJ_SRC_ROOT+ "| $PROJ_GEN_ROOT: "+$PROJ_GEN_ROOT+ " $PROJ_NAME: "+$PROJ_NAME
puts "Repository Ver. "+ $current_version
puts "Date/Time " +date.to_s
puts ""
puts "Passed Tests: "+ $KEYWORD_DICT[$KEYWORD[0]].to_s
puts "ERROR Tests: "+ $KEYWORD_DICT[$KEYWORD[1]].to_s  
puts "WARNING Tests: "+ $KEYWORD_DICT[$KEYWORD[2]].to_s 
print_summary()
puts ""
 
p $ERROR_DICT.each
$ERROR_TESTS.each_key{|key|
  $ERROR_TESTS[key].each{|value|
    puts key.to_s+"::"+value.to_s
    }  
}
  
p $WARNING_DICT.each
$WARNING_TESTS.each_key{|key|
  $WARNING_TESTS[key].each{|value|
    puts key.to_s+"::"+value.to_s
    }  
}
puts "============================================================"
