require 'json'

# Parses JSON dumps of titles in a category
class DumpParser
  INPUT_FILENAME = "test/data/quick_intersection_20131027.json"

  def self.run
    text = File.read(INPUT_FILENAME)
    data = JSON.parse(text)
    dump_parser = new(data)
    puts dump_parser.word_frequency_analysis
  end

  def initialize(data)
    @data = data

    @page_titles = create_page_titles
    @words = @page_titles.flat_map(&:words)

    @word_frequency = determine_word_frequency
  end

  def create_page_titles
    pages = @data.fetch('pages')
    pages.map(&method(:create_page_title))
  end

  def create_page_title(page)
    page_title = page.fetch('page_title')
    PageTitle.new(page_title)
  end

  def determine_word_frequency
    words_grouped_by_word = @words.group_by { |word| word }
    words_grouped_by_word.each_with_object({}) do |(word, words), result|
      result[word] = words.length
    end
  end

  def word_frequency_analysis
    title_row = %w{Word Frequency}
    body_rows = @word_frequency.sort_by do |word, frequency|
      [-frequency, word]
    end
    rows = [title_row] + body_rows
    rows.map { |row| row.join("\t") }.join("\n")
  end
end

# Converts page titles into words
class PageTitle
  attr_reader :words

  def initialize(page_title)
    @page_title = page_title

    @words = determine_words
  end

  def determine_words
    @page_title.split('_')
  end
end
