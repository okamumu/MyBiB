require 'active_support'
require 'active_support/core_ext'
require 'liquid'

require './ldbib.rb'

# template = "Hello {{ hoge }}"
# p binding = { hoge: "World" }.with_indifferent_access
# p binding2 = {'hoge' => 'test'}
# p res = Liquid::Template.parse(template)
# puts res.render(binding)
#

include LDBib

Filters[:citekey] = nil
Filters[:type] = nil

doc = load_gists("journal.yml", "8f9092b69ab2bbe5a84001684eaf984c", Keys, Filters, :array)
p doc.to_ruby[0] # １回本当の yaml を経由して ruby objects へ

# TODO
#  - rake で to_bibtex と (gists posts?) to_yaml で jekyll _data へのコピーくらいが運用簡単かな？
