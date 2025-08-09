require 'nokogiri'
require 'json'

ROOT_DIR = File.expand_path('..', __dir__)
FILES_DIR = File.join(ROOT_DIR, 'files')

# Module for parsing Google Knowledge Card HTML files,
# extracting carousel-type search results including images, links, and metadata.
module GoogleKCParser
  GOOGLE_BASE = "https://www.google.com"
  BASE64_PREFIX = "data:image/jpeg;base64"
  # Regex for matching scripts that set image src data dynamically using javascript. These scripts have the following format:
  # (function(){var s='data:image/jpeg;base64,/9j/4AAQ...\\x3d';var ii=['dimg_t7aUaIKFGObjxc8P7bW8kAk_5'];_setImagesSrc(ii,s);})();"
  # where s contains the image data and ii the img id. Define regex to capture image data + id
  SCRIPT_IMG_DATA_REGEX = /^\(function\(\)\{var \w='(?<data>#{Regexp.escape(BASE64_PREFIX)},[^']+)';.*\['(?<id>[^']+)'\]/

  # Parses a Google knowledge card HTML file to extract carousel results.
  #
  # @param html_file [String] filename of the HTML file located in the /files directory
  # @return [Array<Hash>] array of hashes with keys :name, :extensions, :link, and :image
  #   - :name [String] the main title/name of the carousel item
  #   - :extensions [Array<String>] optional additional info like year or subtype
  #   - :link [String] full URL to the Google search result
  #   - :image [String] base64-encoded image data or image URL
  #
  # The method also writes a JSON file with the actual parsed results to /files
  def self.parse(html_file)
    # Check if file exists
    html_file_path = File.join(FILES_DIR, html_file)
    return "File #{html_file} not found in /files directory" unless File.exist?(html_file_path)

    # Read raw HTML 
    html_raw = File.read(html_file_path)
    # Parse with Nokogiri
    html = Nokogiri::HTML(html_raw)

    # By inspecting the data we notice that all carousel-type results are enclosed in a div with an attribute 'data-attrid'
    # and value the google taxonomy for this type of results. E.g. for paintings it's "kc:/visual_art/visual_artist:works", 
    # for animal breeds it's "kc:/biology/domesticated_animal:breeds", for artist albums "kc:/music/artist:albums" and so on
    # We use this in our selector to ensure we select only knowledge card type links. We also add the a[href*="search?"] 
    # selector to avoid ad links e.g. 'watch now in netflix' when searching for a movie cast. We also add the img tag in 
    # the selector to avoid selecting links without an image (e.g. in the overview section)
    # There are other more targeted inner elements that we could use based on their class name such as "Cz5hV", "iELo6" etc 
    # but these are obfuscated names which are not reliable to use since they might change at any time causing our code 
    # to break hence we avoid them. 
    carousel_images = html.css('div[data-attrid^="kc:"] a[href*="search?"] img')

    # Store image data + id in a hash for fast image data retrieval based on image id to avoid multiple passes through the data.
    image_data = {}

    html.css('script').each do |script|
      if match = SCRIPT_IMG_DATA_REGEX.match(script.text)
        image_data[match[:id]] = match[:data]
      end
    end

    results = []

    carousel_images.each do |carousel_image|
      link = carousel_image.ancestors('a').first
      (warn "Couldn't find parent link for image tag: #{carousel_image.to_html}"; next) unless link

      image_id = carousel_image[:id]
      name, year = link.css('div > div').map(&:text).map(&:strip)

      result = {}
      result[:name]       = name
      result[:extensions] = [year] unless year.empty?
      result[:link]       = link[:href]
      # Some images have their data set dynamically which we have stored in the image_data hash.
      # The remaining use a "data-src" link instead hence we store that if present.
      result[:image]      = carousel_image["data-src"] || image_data[image_id]
      
      # Replace all \xNN hex escape sequences in image data with the actual characters
      result[:image].gsub!(/\\x([0-9a-fA-F]{2})/) { [$1].pack('H2') }

      # Insert GOOGLE_BASE to link if not present
      result[:link].insert(0, GOOGLE_BASE) unless result[:link].start_with?(GOOGLE_BASE)

      results << result
    end

    output_file = File.join(FILES_DIR, html_file.gsub('.html','-actual.json'))
    File.write(output_file, JSON.pretty_generate(results))
    
    results
  end
end
