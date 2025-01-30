module MemsizeHelpers
  def self.memsize_rss_in_kb
    _, size = %x(ps -p "#{$$}" -o pid=,rss=).strip.split.map(&:to_i)
    size
  end
end
