# Compare the frequency of words from the Japanese and Australian lists
class FrequencyComparer
  # Not actually Australian
  AUSTRALIAN_FREQUENCY_FILENAME = '../akihito/results/frequent_last_names/frequent_names_not_japan_20150404b.txt'
  JAPANESE_FREQUENCY_FILENAME = '../akihito/results/frequent_last_names/frequent_names_japan_20150404b.txt'
  # DIFFERENCE_FILENAME = 'data/frequency_difference_20131107a.txt'

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
    lines.each_with_object({}).each_with_index do |(line, result), i|
      strings = line.split("\t")
      next unless strings.count == 2
      word, frequency_string = strings
      word = word.downcase
      next if word.empty?
      next if word.length == 1
      fail "Blank word #{word.inspect} on line #{i}" if word =~ /^ *$/
      fail "Invalid line no #{i} #{line.inspect}" if strings.last.to_i.zero?
      frequency = Integer(frequency_string)
      result[word] = frequency
    end
  end

  def frequency_for(word)
    @frequency.fetch(word.downcase, 0)
  end
end
