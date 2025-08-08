#!/usr/bin/env ruby
# Script to parse a Google Knowledge Carousel HTML file and output extracted results as JSON.
# Usage: ./run_parser.rb <html_file>

require_relative '../lib/google_kc_parser'

if ARGV.empty?
  puts "Usage: #{$0} <html_file>"
  exit 1
end

html_file = ARGV[0]

begin
  results = GoogleKCParser.parse(html_file)
  puts JSON.pretty_generate(results)
rescue => e
  warn "Error parsing file #{html_file}: #{e.message}"
  exit 1
end
