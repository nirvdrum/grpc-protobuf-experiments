# typed: false
# frozen_string_literal: true

clone_graph = !!ENV['CLONE_GRAPH']

if ENV["USE_PROTOBOUEF"]
  puts "Using protoboeuf"
  require_relative "gen/protoboeuf/simple"
else
  require_relative "gen/protobuf/simple_pb"
end

require_relative "lib/memsize_helpers"

datum = Proto::Leak::Recursive.new

10.times do
  1_000_000.times do
    Proto::Leak::Recursive.new(data: [clone_graph ? Google::Protobuf.deep_copy(datum) : datum])
  end

  MemsizeHelpers.check_usage
end

MemsizeHelpers.report_usage
