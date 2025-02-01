require "objspace"

module MemsizeHelpers
  def self.memsize_rss_in_kb
    # Get a single field from ps for the pid in question.
    %x(ps -p "#{$$}" -o rss=).strip.to_i
  end

  def self.reset!
    @memsize_rss_start = memsize_rss_in_kb
  end
  reset!

  # Put commas in number to make it easier to read.
  def self.format_with_delimiter(number)
    s = number.to_s
    # Start at the right side (the period or the end).
    i = s.index('.') || s.size
    # Step back toward the beginning and insert a comma between every 3 digits.
    s.insert(i -= 3, ',') while i > 3
    s
  end

  def self.check_usage
    GC.start
    # Set this so that the report can see the last value from this position.
    @memsize_rss_last = MemsizeHelpers.memsize_rss_in_kb

    if verbose?
      # Put newline first to keep these aligned in the middle of the benchmkark-ips output.
      printf "\n[Memory usage: %11s KB - ruby space %7s KB]",
        format_with_delimiter(@memsize_rss_last),
        format_with_delimiter((ObjectSpace.memsize_of_all / 1000).round(0))
    end
  end

  def self.memsize_rss_start
    @memsize_rss_start
  end

  def self.memsize_rss_last
    # Get value from last loop iteration if there was one else request it.
    @memsize_rss_last ||= MemsizeHelpers.memsize_rss_in_kb
  end

  # Print usage from last check or current value.
  def self.report_usage
    printf "\nTotal memory growth: %12s KB\n",
      format_with_delimiter(memsize_rss_last - memsize_rss_start)

    # This can be handy to watch from a benchmark but shouldn't be used when looking at the speed results.
    if verbose? && defined?(Benchmark)
      puts "\n\nNOTE: Benchmark speed results will be skewed by the ObjectSpace.memsize_of_all call performed in VERBOSE mode and should be discarded.\n\n"
    end
  end

  def self.verbose?
    ENV["VERBOSE"]
  end
end
