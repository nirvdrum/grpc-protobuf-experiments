# typed: false
# frozen_string_literal: true

require "objspace"

if ENV["USE_PROTOBOUEF"]
  puts "Using protoboeuf"
  require_relative "gen/protoboeuf/types"
else
  require_relative "gen/protobuf/types_pb"
end

require_relative "lib/memsize_helpers"

filter = Proto::Leak::RowFilter.new
memsize_rss_start = MemsizeHelpers.memsize_rss_in_kb
memsize_rss_current = memsize_rss_start

5.times do
  100_000.times do
    Proto::Leak::RowFilter::Chain.new(filters: [filter])
  end

  GC.start
  memsize_rss_current = MemsizeHelpers.memsize_rss_in_kb

  if ENV["VERBOSE"]
    puts "Memory usage: #{memsize_rss_current} KB - ruby space #{(ObjectSpace.memsize_of_all / 1000).round(0)} KB"
  end
end

puts "Total memory growth: #{memsize_rss_current - memsize_rss_start} KB"
