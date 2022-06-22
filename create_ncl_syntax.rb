#!/usr/bin/env ruby -wU

require 'nokogiri'

builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
  xml.doc.create_internal_subset(
    'plist',
    "-//Apple//DTD PLIST 1.0//EN",
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd"
  )
  xml.plist(:version => '1.0') {
    xml.dict {
      xml.key "fileTypes"
      xml.array {
        xml.string "ncl"
      }
      xml.key "name"
      xml.string "NCL"
      xml.key "scopeName"
      xml.string "source.ncl"
      xml.key "uuid"
      xml.string "43d57527-c0c4-46f3-a175-08a320bc52de"
      xml.key "patterns"
      xml.array {
        xml.dict {
          xml.key "name"
          xml.string "comment.line.source.ncl"
          xml.key "comment"
          xml.string "NCL comment"
          xml.key "match"
          xml.string ";.*$"
        }
        xml.dict {
          xml.key "name"
          xml.string "support.type.source.ncl"
          xml.key "comment"
          xml.string "NCL types"
          xml.key "match"
          xml.string "\\b(integer|float|double|string|graphic)\\b"
        }
        xml.dict {
          xml.key "name"
          xml.string "constant.numeric.source.ncl"
          xml.key "comment"
          xml.string "NCL numerics"
          xml.key "match"
          xml.string "\\b(\\+|-|\*|/)?\\d+(\\.\\d+((d|D|e|E)(\\+|-|\*|/)?\\d+)?)?\\b"
        }
        xml.dict {
          xml.key "name"
          xml.string "keyword.operator.source.ncl"
          xml.key "comment"
          xml.string "NCL operators"
          xml.key "match"
          xml.string "\\.(eq|ne|gt|ge|lt|le|not|and|or)\\."
        }
        xml.dict {
          xml.key "name"
          xml.string "keyword.control.source.ncl"
          xml.key "comment"
          xml.string "NCL control keywords"
          xml.key "match"
          xml.string "\\b(do|end|if|then|else|while|break|continue|return|load|begin|end|procedure|function|local)\\b"
        }
        xml.dict {
          xml.key "name"
          xml.string "constant.language.source.ncl"
          xml.key "comment"
          xml.string "NCL boolean"
          xml.key "match"
          xml.string "\\b(True|False)\\b"
        }
        xml.dict {
          xml.key "name"
          xml.string "constant.character.source.ncl"
          xml.key "comment"
          xml.string "NCL constructs"
          xml.key "match"
          xml.string "\\b(@|!|&|$|=>|->)\\b"
        }
        xml.dict {
          xml.key "name"
          xml.string "string.quoted.double.source.ncl"
          xml.key "comment"
          xml.string "NCL string"
          xml.key "begin"
          xml.string "\""
          xml.key "end"
          xml.string "\""
          xml.key "patterns"
          xml.array {
            xml.dict {
              xml.key "name"
              xml.string "constant.character.escape.source.ncl"
              xml.key "match"
              xml.string "\\."
            }
            xml.dict {
              xml.key "name"
              xml.string "storage.type.source.ncl"
              xml.key "comment"
              xml.string "Environment variable"
              xml.key "match"
              xml.string "\\$\\w+"
            }
          }
        }
        xml.dict {
          xml.key "name"
          xml.string "support.function.source.ncl"
          xml.key "comment"
          xml.string "NCL intrinsic functions"
          print "[Notice]: Grabing functions from NCL webpage.\n"
          page = `curl -s http://www.ncl.ucar.edu/Document/Functions/list_alpha.shtml`
          categories = ['Functions/Built-in', 'Functions/Contributed',
                        'Functions/User_contributed', 'Functions/WRF_arw', 'Graphics/Interfaces']
          string = ''
          categories.each do |category|
            page.scan(/^\s*<a href="\/Document\/#{category}\/\w*\.shtml/).each do |x|
              func = x.match(/(\w+)(\.shtml)/)[1]
              string += "#{func}|"
            end
          end
          xml.key "match"
          xml.string "\\b(#{string[0..-2]})\\b"
        }
        xml.dict {
          xml.key "name"
          xml.string "support.other.source.ncl"
          xml.key "comment"
          xml.string "Resources"
          print "[Notice]: Grabing resources from NCL website.\n"
          page = `curl -s http://www.ncl.ucar.edu/Document/Graphics/Resources/list_alpha_res.shtml`
          resources = [] # There may be duplicate links in NCL graphics resources webpage.
          string = ''
          page.scan(/^<a name="\w+"><\/a><strong>/).each do |x|
            res = x.match(/"(\w+)"></)[1]
            # Also remove the trailing '_*' stuff.
            res.gsub!(/_\w+/, '')
            if not resources.include? res
              string << "#{res}|"
              resources << res
            end
          end
          xml.key 'match'
          xml.string "\\b(#{string[0..-2]})\\b"
        }
      }
    }
  }
end

File.open('NCL.tmLanguage', 'w') do |file|
  file << builder.to_xml
end
