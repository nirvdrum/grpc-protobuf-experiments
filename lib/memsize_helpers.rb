module MemsizeHelpers
  def self.memsize_rss_in_kb
    _, size = %x(ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}").strip.split.map(&:to_i)
    size
  end
end
