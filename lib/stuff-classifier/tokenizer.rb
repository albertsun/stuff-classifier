# encoding: utf-8

require "lingua/stemmer"
require "tokenizer"

class StuffClassifier::Tokenizer
  require  "stuff-classifier/tokenizer/tokenizer_properties"
  
  def initialize(opts={})
    @language = opts.key?(:language) ? opts[:language] : "en"
    @properties = StuffClassifier::Tokenizer::TOKENIZER_PROPERTIES[@language]
    @tokenizer = Tokenizer::Tokenizer.new(@language)
    
    @stemming = opts.key?(:stemming) ? opts[:stemming] : true
    if @stemming
      @stemmer = Lingua::Stemmer.new(:language => @language)
    end
  end

  def language
    @language
  end

  # def preprocessing_regexps=(value)
  #   @preprocessing_regexps = value
  # end

  # def preprocessing_regexps
  #   @preprocessing_regexps || @properties[:preprocessing_regexps]
  # end

  def ignore_words=(value)
    @ignore_words = value
  end

  def ignore_words
    @ignore_words || @properties[:stop_word]
  end

  def stemming?
    @stemming || false
  end

  def each_word(string)
    string = string.strip
    return if string == ''

    words = []
    @tokenizer.tokenize(string).each do |w|
      next if w == '' || ignore_words.member?(w.downcase)

      if stemming?
        w = @stemmer.stem(w).downcase
        w.gsub!(/[^\w]/u,"")
        next if ignore_words.member?(w) or w.size < 3
      else
        w = w.downcase
      end

      words << (block_given? ? (yield w) : w)
    end

    return words
  end

private 

  # def stemable?(word)
  #   # word =~ /^\p{Alpha}+$/
  #   word =~ /^[\w']+$/
  # end
  
end
