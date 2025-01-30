# typed: false
# frozen_string_literal: true

require "google/cloud/bigtable"

require_relative "lib/memsize_helpers"

clone_graph = !!ENV['CLONE_GRAPH']

filter = Google::Cloud::Bigtable::V2::RowFilter.new
MemsizeHelpers.reset!

20.times do
  10_000.times do
    Google::Cloud::Bigtable::V2::RowFilter::Chain.new(filters: [clone_graph ? Google::Protobuf.deep_copy(filter) : filter])
  end

  MemsizeHelpers.check_usage
end

MemsizeHelpers.report_usage
