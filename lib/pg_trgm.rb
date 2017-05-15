require 'pg_trgm/version'

require 'set'

module PgTrgm
  def self.trigrams(v)
    memo = Set.new
    v.to_s.split(/[\W_]+/).each do |word|
      next if word.empty?
      # Each word is considered to have two spaces prefixed and one space suffixed when determining the set of trigrams contained in the string
      word = "  #{word.downcase} "
      word.chars.each_cons(3).map do |cons|
        memo << cons.join
      end
    end
    memo
  end

  # inspired by https://gist.github.com/komasaru/41b0c93e264be75eabfa
  def self.similarity(v1, v2)
    v1_trigrams = PgTrgm.trigrams v1
    v2_trigrams = PgTrgm.trigrams v2
    return 0 if v1_trigrams.empty? and v2_trigrams.empty?
    count_dup = (v1_trigrams & v2_trigrams).length
    count_all = (v1_trigrams + v2_trigrams).length
    count_dup / count_all.to_f
  end
end
