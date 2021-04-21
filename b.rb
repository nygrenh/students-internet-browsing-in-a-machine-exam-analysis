#!/usr/bin/env ruby
require 'json'
require 'byebug'
require 'descriptive_statistics'
require 'uri'

file = File.open('nayttokoe_osoitteet.json')
data = JSON.parse(file.read)
file.close

d2 = data.map do |o|
  links = o['visited_links'].select { |l| !l['essay_period'] && l['category'] != 'essay_page' }.count
  o['visited_domains'] = o['visited_links'].select { |l| !l['essay_period'] && l['category'] != 'essay_page' }.map { |link| URI(link['url'].split('q=')[0]).host }.sort.uniq.count
  # all categories: ["essay_page", "stack_overflow", "google", "tmc", "other", "mooc_fi", "course_material", "javadoc"]
  l = o['visited_links'].select { |l| !l['essay_period'] && l['category'] != 'essay_page' }
  o['stack_overflow'] = l.select {|o| o['category'] == 'stack_overflow'}.count
  o['google'] = l.select {|o| o['category'] == 'google'}.count
  o['tmc'] = l.select {|o| o['category'] == 'tmc'}.count
  o['other'] = l.select {|o| o['category'] == 'other'}.count
  o['mooc_fi'] = l.select {|o| o['category'] == 'mooc_fi'}.count
  o['course_material'] = l.select {|o| o['category'] == 'course_material'}.count
  o['javadoc'] = l.select {|o| o['category'] == 'javadoc'}.count
  o['visited_links'] = links
  o
end

require 'csv'
CSV.open('points_links.csv', 'w') do |csv|
  csv << d2.first.keys
  d2.each do |d|
    csv << d.values
  end
end

# byebug

puts 'lolled'
