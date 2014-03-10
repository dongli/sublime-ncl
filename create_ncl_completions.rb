#!/usr/bin/env ruby

if File.exist?("NCL.sublime-completions")
    print "[Warning]: NCL.sublime-completions exists, check it since the creation process may be long!\n"
    exit
end

completion_file = File.new("NCL.sublime-completions", "w+")
completion_file.write("{\n")
completion_file.write("    \"scope\": \"source.ncl\",\n")
completion_file.write("    \"completions\":\n")
completion_file.write("    [\n")

print "[Notice]: Grabing function definitions from NCL website.\n"
page1 = `lynx -dump http://www.ncl.ucar.edu/Document/Functions/list_alpha.shtml`
page1.encode!('UTF-8', 'UTF-8', :invalid => :replace, :replace => '')

categories = ['Functions/Built-in', 'Functions/Contributed', 'Functions/WRF_arw', 'Graphics/Interfaces']
categories.each do |category|
    func_urls = page1.scan(/http:\/\/www\.ncl\.ucar\.edu\/Document\/#{category}\/\w*\.shtml/)
    func_urls.each do |func_url|
        func = func_url.match(/(\w+)(\.shtml)/)[1]
        page2 = `lynx -dump #{func_url}`
        page2.encode!('UTF-8', 'UTF-8', :invalid => :replace, :replace => '')
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
page1 = `lynx -dump http://www.ncl.ucar.edu/Document/Graphics/Resources/list_alpha_res.shtml`
page1.encode!('UTF-8', 'UTF-8', :invalid => :replace, :replace => '')

resources = [] # There may be duplicate links in NCL graphics resources webpage.
categories = ['Graphics/Resources']
categories.each do |category|
    res_urls = page1.scan(/http:\/\/www\.ncl\.ucar\.edu\/Document\/#{category}\/\w+\.shtml#[a-z]\w+$/)
    res_urls.each do |res_url|
        res = res_url.match(/(\w+)$/)[1]
        if not resources.include?(res)
            completion_file.write("        \"#{res}\",\n")
            resources.push(res)
        end
    end
end

completion_file.write("    ]\n")
completion_file.write("}\n")
