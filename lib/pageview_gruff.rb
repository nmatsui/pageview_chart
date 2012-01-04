# -*- encoding: utf-8 -*-

require 'yaml'
require 'gruff'

class Chart
  CONF_FILE = "config.yaml"

  def initialize(width=800, height=600)
    conf = YAML.load_file(CONF_FILE)
    @gruff = Gruff::Line.new("#{width}x#{height}")
    @gruff.font                     = conf["gruff"]["font"]
    @gruff.title_font_size          = conf["gruff"]["title_size"]
    @gruff.legend_font_size         = conf["gruff"]["legend_size"]
    @gruff.legend_box_size          = conf["gruff"]["legend_size"]
    @gruff.marker_font_size         = conf["gruff"]["legend_size"]
    @gruff.suppress_legend_wrapping = true
    @gruff.legend_left_margin       = conf["gruff"]["legend_left"]
  end

  def write(title, labels, y_max, y_increment, data, filename)
    @gruff.title            = title
    @gruff.labels           = Hash[*labels.map.with_index {|label, idx|
                                                            [idx, label]
                                                          }.select {|tuple|
                                                            tuple.last != ""
                                                          }.flatten
                                  ]
    @gruff.maximum_value    = y_max
    @gruff.minimum_value    = 0
    @gruff.y_axis_increment = y_increment
    data.keys.each do |series|
      pv = data[series][:pageviews].reduce(:+)
      puts "#{series}:#{data[series][:pageviews]}"
      @gruff.data("#{series} :: #{pv}PV", 
                  data[series][:pageviews], 
                  data[series][:color])
    end
    @gruff.write(filename)
  end
end
