module MemsizeHelpers
  def self.memsize_rss_in_kb
    %x(ps -p "#{$$}" -o rss=).strip.to_i
  end
end
