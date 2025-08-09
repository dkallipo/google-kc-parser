#!/usr/bin/env ruby
# Test suite for GoogleKCParser module.
# Dynamically defines tests for various Google Knowledge Carousel HTML files and compares
# parser output against expected JSON results.

require_relative '../lib/google_kc_parser'
require 'test/unit'

class GoogleKCParserTest < Test::Unit::TestCase
  # Dynamically defines a test method for the given query
  # Loads the corresponding HTML file and compares parser output with expected JSON.
  def self.define_parser_test(query)
    define_method("test_#{query.gsub(' ','_')}") do
      html_file = query.gsub(' ','-') + '.html'
      actual_results = GoogleKCParser.parse(html_file)

      assert actual_results.is_a?(Array), "Expected results to be an array but was #{actual_results.class}"

      expected_results_file = File.join(FILES_DIR, html_file.gsub('.html','-expected.json'))
      expected_results = JSON.parse(File.read(expected_results_file), symbolize_names:true)

      assert_equal expected_results.count, actual_results.count, "results count"

      expected_results.each_with_index do |expected_result, i|
        [:name, :extensions, :link, :image].each do |field|
          assert_equal expected_result[field], actual_results[i][field], "#{field} for result #{i}"
        end
      end
    end
  end

  define_parser_test('van gogh paintings')
  define_parser_test('dog breeds')
  define_parser_test('michael jackson albums')
  define_parser_test('stranger things cast')
end
