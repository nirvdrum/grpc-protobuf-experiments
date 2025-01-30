# typed: false
# frozen_string_literal: true

clone_graph = !!ENV['CLONE_GRAPH']

if ENV["USE_PROTOBOUEF"]
  puts "Using protoboeuf"
  require_relative "gen/protoboeuf/types"
else
  require_relative "gen/protobuf/types_pb"
end

require_relative "lib/memsize_helpers"

filter = Proto::Leak::RowFilter.new

10.times do
  100_000.times do
    Proto::Leak::RowFilter::Chain.new(filters: [clone_graph ? Google::Protobuf.deep_copy(filter) : filter])
  end

  MemsizeHelpers.check_usage
end

MemsizeHelpers.report_usage
