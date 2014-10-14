#!/usr/bin/env ruby -wU

if File.exist? 'NCL.sublime-completions'
  print "[Warning]: NCL.sublime-completions exists, delete it!\n"
  File.delete 'NCL.sublime-completions'
end

completion_file = File.new 'NCL.sublime-completions', 'w+'
completion_file << "{\n"
completion_file << "    \"scope\": \"source.ncl\",\n"
completion_file << "    \"completions\":\n"
completion_file << "    [\n"

url_prefix = 'http://www.ncl.ucar.edu'

print "[Notice]: Grabing function definitions from NCL website.\n"
page1 = `curl -s #{url_prefix}/Document/Functions/list_alpha.shtml`

categories = ['Functions/Built-in', 'Functions/Contributed', 'Functions/User_contributed', 'Functions/WRF_arw', 'Graphics/Interfaces']
categories.each do |category|
  page1.scan(/^\s*<a href="\/Document\/#{category}\/\w*\.shtml/).each do |x|
    func = x.match(/(\w+)(\.shtml)/)[1]
    func_url = "#{url_prefix}#{x.match(/<a href="(.*)/)[1]}"
    page2 = `curl -s #{func_url}`
    puts "[Notice]: Creating completion for #{func}."
    completion_file << "        { \"trigger\": \"#{func}\", \"contents\": \"#{func}("
    begin
      prototype = page2.match(/(function|procedure) \w+ \(([^\)]*)\)$/m)[2].strip
    rescue
      print page2.match(/(function|procedure) \w+ \(([^\)]*)\)$/m)
      print "[Error]: Failed to extract prototype for #{func}!"
      exit
    end
    i = 1
    prototype.each_line do |line|
      arg = line.split(" ")[0].strip
      completion_file << "${#{i}:#{arg}}"
      completion_file << ", " if i != prototype.lines.count
      i += 1
    end
    completion_file << ")\" },\n"
  end
end

print "[Notice]: Grabing graphics resources from NCL website.\n"
page1 = `curl -s #{url_prefix}/Document/Graphics/Resources/list_alpha_res.shtml`

resources = [] # There may be duplicate links in NCL graphics resources webpage.
page1.scan(/^<a name="\w+"><\/a><strong>/).each do |x|
  res = x.match(/"(\w+)"></)[1]
  # Also remove the trailing '_*' stuff.
  res.gsub!(/_\w+/, '')
  if not resources.include? res
    completion_file << "        \"#{res}\",\n"
    resources << res
  end
end

print "[Notice]: Grabing resource codes from NCL website.\n"
codes = []
page1.scan(/<code>\w+<\/code>/).each do |x|
  code = x.match(/>(\w+)</)[1]
  if not codes.include? code
    completion_file << "        \"#{code}\",\n"
    codes << code
  end
end

print "[Notice]: Grabing color tables from NCL website.\n"
page1 = `curl -s #{url_prefix}/Document/Graphics/color_table_gallery.shtml`

color_tables = []
page1.scan(/^<td>\w+<br>$/).each do |x|
  color_table = x.match(/>(\w+)</)[1]
  if not color_tables.include? color_table
    completion_file << "        \"#{color_table}\",\n"
    color_tables << color_table
  end
end

completion_file.write("    ]\n")
completion_file.write("}\n")
