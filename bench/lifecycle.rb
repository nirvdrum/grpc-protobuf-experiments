# typed: false
# frozen_string_literal: true

require "benchmark/ips"

if ENV["USE_PROTOBOUEF"]
  puts "Using protoboeuf"
  require_relative "../gen/protoboeuf/simple"
else
  require_relative "../gen/protobuf/simple_pb"
end

require_relative "../lib/memsize_helpers"

def run
  10.times do
    1_000_000.times do
      yield
    end
    MemsizeHelpers.check_usage if MemsizeHelpers.verbose?
  end
end

datum = Proto::Leak::Recursive.new

Benchmark.ips do |x|
  x.config(iterations: 2)

  x.report("long-lived") do
    run do
      Proto::Leak::Recursive.new(data: [datum])
    end
  end

  x.report("short-lived") do
    run do
      short = Proto::Leak::Recursive.new
      Proto::Leak::Recursive.new(data: [short])
    end
  end

  x.report("deep_copy") do
    run do
      Proto::Leak::Recursive.new(data: [Google::Protobuf.deep_copy(datum)])
    end
  end

  x.hold! ENV.fetch("BENCH_HOLD", "#{__FILE__}.hold")

  x.compare!(order: :baseline)
end

MemsizeHelpers.report_usage
