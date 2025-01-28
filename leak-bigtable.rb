# typed: false
# frozen_string_literal: true

require "google/cloud/bigtable"
require "objspace"

require_relative "lib/memsize_helpers"

clone_graph = !!ENV['CLONE_GRAPH']

filter = Google::Cloud::Bigtable::V2::RowFilter.new
memsize_rss_start = MemsizeHelpers.memsize_rss_in_kb
memsize_rss_current = memsize_rss_start

20.times do
  10_000.times do
    Google::Cloud::Bigtable::V2::RowFilter::Chain.new(filters: [clone_graph ? Google::Protobuf.deep_copy(filter) : filter])
  end

  GC.start
  memsize_rss_current = MemsizeHelpers.memsize_rss_in_kb

  if ENV["VERBOSE"]
    puts "Memory usage: #{memsize_rss_current} KB - ruby space #{(ObjectSpace.memsize_of_all / 1000).round(0)} KB"
  end
end

puts "Total memory growth: #{memsize_rss_current - memsize_rss_start} KB"
