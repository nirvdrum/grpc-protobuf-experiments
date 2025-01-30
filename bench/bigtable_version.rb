# typed: false
# frozen_string_literal: true

require "benchmark/ips"
require "bundler/inline"

version = ENV["BIGTABLE_VERSION"]
gemfile do
  gem "google-cloud-bigtable", "= #{version}"
end

require "google/cloud/bigtable"

Google::Cloud::Bigtable::VERSION.then do |v|
  if v.to_s != version
    fail("BigTable version #{v} != #{version}")
  end

  puts "# Using BigTable version #{v}"
end

require_relative "../lib/memsize_helpers"

def run
  20.times do
    100_000.times do
      yield
    end
    MemsizeHelpers.check_usage
  end
end

test_type = ENV['BIGTABLE_TEST']

def new_row_filter
  Google::Cloud::Bigtable::V2::RowFilter.new
end

# Instantiate this outside the loop so that if there is leaked memory
# attached it will show up in the final report.
filter = new_row_filter

Benchmark.ips do |x|
  x.config(iterations: 2)

  x.report("bigtable-#{version} #{sprintf "%12s", test_type}") do
    run do
      filters = [
        # In 2.11.0 these RowFilter methods return a cached frozen instance.
        # In 2.11.1 they return a new instance each time.
        Google::Cloud::Bigtable::RowFilter.pass,
        Google::Cloud::Bigtable::RowFilter.block,
        Google::Cloud::Bigtable::RowFilter.sink,
        Google::Cloud::Bigtable::RowFilter.strip_value,
      ].map(&:to_grpc)

      case test_type
      when "long-lived"
        # Include our own long-lived instance.
        filters << filter
      when "short-lived"
        filters << new_row_filter
      when "deep_copy"
        filters << filter
        filters = filters.map { |f| Google::Protobuf.deep_copy(f) }
      else
        fail("Unknown BIGTABLE_TEST value '#{test_type}")
      end

      Google::Cloud::Bigtable::V2::RowFilter::Chain.new(filters:)
    end
  end

  x.save! ENV.fetch("BENCH_HOLD", "#{__FILE__}.hold")

  x.compare!(order: :baseline)
end

MemsizeHelpers.report_usage
