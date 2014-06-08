#!/usr/bin/env ruby -wU

if File.exist?("NCL.sublime-completions")
    print "[Warning]: NCL.sublime-completions exists, delete it!\n"
    File.delete("NCL.sublime-completions")
end

completion_file = File.new("NCL.sublime-completions", "w+")
completion_file.write("{\n")
completion_file.write("    \"scope\": \"source.ncl\",\n")
completion_file.write("    \"completions\":\n")
completion_file.write("    [\n")

url_prefix = "http://www.ncl.ucar.edu"

print "[Notice]: Grabing function definitions from NCL website.\n"
page1 = `curl -s #{url_prefix}/Document/Functions/list_alpha.shtml`

categories = ['Functions/Built-in', 'Functions/Contributed', 'Functions/WRF_arw', 'Graphics/Interfaces']
categories.each do |category|
   func_fields = page1.scan(/<a href="\/Document\/#{category}\/\w*\.shtml/)
   func_fields.each do |func_field|
       func = func_field.match(/(\w+)(\.shtml)/)[1]
       func_url = "#{url_prefix}#{func_field.match(/<a href="(.*)/)[1]}"
       page2 = `curl -s #{func_url}`
       puts "[Notice]: Creating completion for #{func}."
       completion_file.write("        { \"trigger\": \"#{func}\", \"contents\": \"#{func}(")
       prototype = page2.match(/(function|procedure) \w+ \(([^\)]*)\)$/m)[2].strip
       i = 1
       prototype.each_line do |line|
           arg = line.split(" ")[0].strip
           completion_file.write("${#{i}:#{arg}}")
           completion_file.write(", ") if i != prototype.lines.count
           i += 1
       end
       completion_file.write(")\" },\n")
   end
end

print "[Notice]: Grabing graphics resources from NCL website.\n"
page1 = `curl -s http://www.ncl.ucar.edu/Document/Graphics/Resources/list_alpha_res.shtml`

resources = [] # There may be duplicate links in NCL graphics resources webpage.
res_fields = page1.scan(/^<a name="\w+/)
res_fields.each do |res_field|
    res = res_field.match(/(\w+)$/)[1]
    if not resources.include?(res)
        completion_file.write("        \"#{res}\",\n")
        resources.push(res)
    end
end

completion_file.write("    ]\n")
completion_file.write("}\n")
