# Compare the frequency of words from the Japanese and Australian lists
class FrequencyComparer
  AUSTRALIAN_FREQUENCY_FILENAME = 'data/australian_frequency_20131027c.txt'
  JAPANESE_FREQUENCY_FILENAME = 'data/japanese_frequency_20131027b.txt'
  DIFFERENCE_FILENAME = 'data/frequency_difference_20131027c.txt'

  def self.run
    frequency_comparer = new(australian_frequency_data, japanese_frequency_data)
    File.write(DIFFERENCE_FILENAME, frequency_comparer.comparison_analysis)
  end

  def self.australian_frequency_data
    FrequencyData.new_using_filename(AUSTRALIAN_FREQUENCY_FILENAME)
  end

  def self.japanese_frequency_data
    FrequencyData.new_using_filename(JAPANESE_FREQUENCY_FILENAME)
  end

  def initialize(australian_frequency_data, japanese_frequency_data)
    @australian_frequency_data = australian_frequency_data
    @japanese_frequency_data = japanese_frequency_data

    @comparison = create_frequency_comparison
  end

  def create_frequency_comparison
    words = (@australian_frequency_data.words + @japanese_frequency_data.words).uniq
    rows = words.map(&method(:create_comparison_for_word))
    rows.sort_by { |_word, _australian_frequency, _japanese_frequency, difference| difference}
  end

  def create_comparison_for_word(word)
    australian_frequency = @australian_frequency_data.frequency_for(word)
    japanese_frequency = @japanese_frequency_data.frequency_for(word)
    difference = australian_frequency - japanese_frequency
    [word, australian_frequency, japanese_frequency, difference]
  end

  def comparison_analysis
    title_row = ['Word', 'Australian frequency', 'Japanese frequency', 'Difference']
    body_rows = @comparison
    rows = [title_row] + body_rows
    rows.map{ |row| row.join("\t") }.join("\n")
  end
end

# Frequency data for a single country
class FrequencyData
  attr_reader :words

  def self.new_using_filename(filename)
    text = File.read(filename)
    new(text)
  end

  def initialize(text)
    @text = text

    @frequency = determine_frequency
    @words = @frequency.keys
  end

  def determine_frequency
    lines = @text.split("\n").drop(1)
    rows = lines.map do |line|
      strings = line.split("\t")
      word = strings.first
      frequency = Integer(strings.last)
      [word, frequency]
    end
    Hash[rows]
  end

  def frequency_for(word)
    @frequency.fetch(word, 0)
  end
end
