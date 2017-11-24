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
all_performers = data.map { |d| d['visited_links'] }

def filter_essay_links(user_links)
  user_links.map do |links|
    links.select { |l| !l['essay_period'] && l['category'] != 'essay_page' }
  end
end

bad_filtered = filter_essay_links(bad_performers)
good_filtered = filter_essay_links(good_performers)
all_filtered = filter_essay_links(all_performers)

# Count of visited links
bad_link_counts = bad_filtered.map(&:length)
good_link_counts = good_filtered.map(&:length)
all_link_counts = all_filtered.map(&:length)

good_stats = good_link_counts.descriptive_statistics
bad_stats = bad_link_counts.descriptive_statistics
all_stats = all_link_counts.descriptive_statistics

# Count of visited domains

def unique_visited_domains(user_links)
  user_links.map do |links|
    links.map { |link| URI(link['url'].split('q=')[0]).host }.sort.uniq
  end
end

good_domains = unique_visited_domains(good_filtered)
bad_domains = unique_visited_domains(bad_filtered)
all_domains = unique_visited_domains(all_filtered)

good_domain_stats = good_domains.map(&:length).descriptive_statistics
bad_domain_stats = bad_domains.map(&:length).descriptive_statistics
all_domain_stats = all_domains.map(&:length).descriptive_statistics

def links_grouped_by_category(user_links)
  result = Hash.new { |h, k| h[k] = [] }
  user_links.map do |links|
    links.group_by { |link| link['category'] }.each do |k, v|
      result[k] << v.length
    end
  end
  # Categories with zero visits
  result.each do |_k, v|
    missing_count = user_links.length - v.length
    next unless missing_count > 0
    missing_count.times { v << 0 }
  end
  #return result
  stats = {}
  result.each do |k, v|
    stats[k] = v.descriptive_statistics
  end
  stats
end

good_by_category = links_grouped_by_category(good_filtered)
bad_by_category = links_grouped_by_category(bad_filtered)
all_by_category = links_grouped_by_category(all_filtered)

good_googles = good_performers.flat_map do |performer|
  performer
    .select { |l| l['category'] == 'google' && !l['essay_period'] }
    .select { |l| l['title'].length < 200}
    .map { |l| l['title'].gsub(' - Google Search', '') }.uniq
end.sort

bad_googles = bad_performers.flat_map do |performer|
  performer
    .select { |l| l['category'] == 'google' && !l['essay_period'] }
    .select { |l| l['title'].length < 200}
    .map { |l| l['title'].gsub(' - Google Search', '') }.uniq
end.sort

good_so = good_performers.flat_map do |performer|
  performer
    .select { |l| l['category'] == 'stack_overflow' && !l['essay_period'] }
    .select { |l| l['title'].length < 200}
    .map { |l| l['title'].gsub(' - Stack Overflow', '') }.uniq
end.sort

bad_so = bad_performers.flat_map do |performer|
  performer
    .select { |l| l['category'] == 'stack_overflow' && !l['essay_period'] }
    .select { |l| l['title'].length < 200}
    .map { |l| l['title'].gsub(' - Stack Overflow', '') }.uniq
end.sort

byebug

puts 'Lolled'
