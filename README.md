# GoogleKCParser

## Overview
`GoogleKCParser` is a Ruby module designed to parse Google Knowledge Carousel (KC) HTML files. It extracts carousel items such as artworks, animal breeds, artist albums, movie cast lists etc by analyzing the HTML structure and embedded data.

## Project Structure
```
├── bin
│   └── run_parser.rb # Script for running the parser from the command line
├── files # Contains input HTML files and expected output JSON files
├── lib
│   └── google_kc_parser.rb # Parser module source code
└── test
    └── test_parser.rb # File for testing the parser using multiple carousel formats
```

## Usage

### Running the parser from the command line

To parse an HTML file and output the extracted carousel data as JSON:

```bash
ruby bin/run_parser.rb <html_file>
```
Example:

```bash
ruby bin/run_parser.rb van-gogh-paintings.html
```
This will parse the file located in the files/ directory and output JSON results in a van-gogh-paintings-actual.json file and to stdout.


### Running the parser from IRB

1. Start `irb` in the project root directory:

   ```bash
   irb
   ```
2. Require the parser module
   ```bash
   require_relative './lib/google_kc_parser'
   ```
3. Call the parser method with the HTML filename (located in files/):
    ```ruby
    results = GoogleKCParser.parse('van-gogh-paintings.html')
    puts results
    ```
## Running Tests
Tests are implemented using Ruby’s built-in Test::Unit framework.

To run all tests:
```bash
ruby test/test_parser.rb
```
The following google queries are currently tested: 
1. van gogh paintings
2. dog breeds
3. michael jackson albums
4. stranger things cast

The test suite verifies there's an exact match between the expected results and the actual results by verifying result-per-result and field-by-field. The query HTML files and the expected JSON results for the above queries are already present in the files/ directory. 

Feel free to test more queries. You need to add the HTML page together with the expected output in json in the files/ directory. They need to follow the following format e.g. for 
'dog breeds': dog- breeds.html and dog-breeds-expected.json. The expected json should be an array of hashes with keys name, link, image, extensions. Order of results **does matter**.
## Notes
This parser focuses on Google Knowledge Carousel results by targeting specific HTML data attributes and embedded JavaScript.
Image data that is embedded as base64 or dynamically injected by scripts is properly decoded and extracted.
The parser is designed to be extensible for different carousel formats.
If you have any questions or need further assistance, feel free to reach out!
