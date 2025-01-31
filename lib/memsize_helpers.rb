require "objspace"

module MemsizeHelpers
  def self.memsize_rss_in_kb
    %x(ps -p "#{$$}" -o rss=).strip.to_i
  end

  def self.reset!
    @memsize_rss_start = memsize_rss_in_kb
  end
  reset!

  def self.check_usage
    GC.start
    if verbose?
      # Put newline first to keep these aligned in the middle of the benchmkark-ips output.
      printf "\n[Memory usage: %11s KB - ruby space %7s KB]",
        format_number(MemsizeHelpers.memsize_rss_in_kb),
        format_number((ObjectSpace.memsize_of_all / 1000).round(0))
    end
  end

  def self.format_number(n)
    n.to_s.reverse.scan(/\d{1,3}/).join(",").reverse
  end

  def self.report_usage
    GC.start
    printf "Total memory growth: %12s KB\n",
      format_number(MemsizeHelpers.memsize_rss_in_kb - @memsize_rss_start)

    if verbose? && defined?(Benchmark)
      puts "\n\nNOTE: Benchmark speed results will be wildly skewed by the ObjectSpace.memsize_of_all call performed in VERBOSE mode and should be discarded.\n\n"
    end
  end

  def self.verbose?
    ENV["VERBOSE"]
  end
end
