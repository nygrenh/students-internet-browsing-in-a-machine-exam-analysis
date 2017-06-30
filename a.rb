#!/usr/bin/env ruby
require 'json'
require 'byebug'
require 'descriptive_statistics'
require 'uri'

file = File.open('nayttokoe_osoitteet.json')
data = JSON.parse(file.read)
file.close

bad_performers = data.select { |d| d['points'] <= 7 }.map { |d| d['visited_links'] }
good_performers = data.select { |d| d['points'] >= 10 }.map { |d| d['visited_links'] }

def filter_essay_links(user_links)
  user_links.map do |links|
    links.select { |l| !l['essay_period'] && l['category'] != 'essay_page' }
  end
end

bad_filtered = filter_essay_links(bad_performers)
good_filtered = filter_essay_links(good_performers)

# Count of visited links
bad_link_counts = bad_filtered.map(&:length)
good_link_counts = good_filtered.map(&:length)

good_stats = good_link_counts.descriptive_statistics
bad_stats = bad_link_counts.descriptive_statistics

# Count of visited domains

def unique_visited_domains(user_links)
  user_links.map do |links|
    links.map { |link| URI(link['url'].split('q=')[0]).host }.sort.uniq
  end
end

good_domains = unique_visited_domains(good_filtered)
bad_domains = unique_visited_domains(bad_filtered)

good_domain_stats = good_domains.map(&:length).descriptive_statistics
bad_domain_stats = bad_domains.map(&:length).descriptive_statistics

def links_grouped_by_category(user_links)
  result = Hash.new { |h, k| h[k] = [] }
  user_links.map do |links|
    links.group_by { |link| link['category'] }.each do |k, v|
      result[k] << v.length
    end
  end
  # Categories with zero visits
  result.each do |k, v|
    missing_count = user_links.length - v.length
    next unless missing_count > 0
    missing_count.times { v << 0 }
  end
  stats = {}
  result.each do |k, v|
    stats[k] = v.descriptive_statistics
  end
  stats
end

good_by_category = links_grouped_by_category(good_filtered)
bad_by_category = links_grouped_by_category(bad_filtered)

byebug

puts 'Lolled'
