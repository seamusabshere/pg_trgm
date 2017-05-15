require "spec_helper"

def postgres_similarity(v1, v2)
  ActiveRecord::Base.connection_pool.with_connection do |c|
    c.select_value "SELECT similarity(#{c.quote v1}, #{c.quote v2})"
  end.to_f
end

def postgres_trigrams(v)
  raw = ActiveRecord::Base.connection_pool.with_connection do |c|
    c.select_value "SELECT show_trgm(#{c.quote v.to_s})"
  end
  if raw == '{}'
    Set.new
  else
    PgArray.new(raw).to_a.to_set
  end
end

def each_faker
  Faker.constants(false).map do |m|
    Faker.const_get(m)
  end.select do |m|
    m.is_a?(Module)
  end.each do |m|
    m.methods(false).select do|f|
      m.method(f).arity == 0
    end.each do |f|
      yield m, f
    end
  end
end

RSpec.describe PgTrgm do

  describe 'trigrams' do
    it 'does cat' do
      expect(PgTrgm.trigrams('cat')).to match_array(['  c', ' ca', 'cat', 'at '])
    end
    it 'does foo|bar' do
      expect(PgTrgm.trigrams('foo|bar')).to match_array(['  f', ' fo', 'foo', 'oo ', '  b', ' ba', 'bar', 'ar '])
    end
    each_faker do |m, f|
      it "has same trigrams on #{m}.#{f}" do
        16.times do
          v = m.send(f).to_s
          correct = postgres_trigrams v
          got = PgTrgm.trigrams v
          if correct.any? { |vv| vv =~ /0x.{6,}/ }
            puts "skipping #{v} cause weird pg trgms"
            next
          end
          expect(got).to eq(correct), "#{v.inspect} (expected #{correct.inspect}, got #{got.inspect})"
        end
      end
    end
  end

  describe 'similarity' do
    each_faker do |m, f|
      it "has same similarity on #{m}.#{f}" do
        16.times do
          v1 = m.send(f).to_s
          v2 = m.send(f).to_s
          if [v1, v2].any? { |v| postgres_trigrams(v).any? { |vv| vv =~ /0x.{6,}/ } }
            puts "skipping #{v1.inspect} and #{v2.inspect} cause weird chars"
            next
          end
          correct = postgres_similarity v1, v2
          got = PgTrgm.similarity v1, v2
          expect(got).to be_within(0.0001).of(correct), "#{v1.inspect} vs #{v2.inspect} (expected #{correct}, got #{got})\n#{postgres_trigrams(v1).inspect}\n#{PgTrgm.trigrams(v1).inspect}\n#{postgres_trigrams(v2).inspect}\n#{PgTrgm.trigrams(v2).inspect}"
        end
      end
    end
  end

end
