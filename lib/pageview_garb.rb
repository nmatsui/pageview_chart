# -*- encoding: utf-8 -*-

require 'date'
require 'yaml'
require 'garb'

class GoogleAnalytics
  CONF_FILE = "config.yaml"

  def initialize
    conf = YAML.load_file(CONF_FILE)
    Garb.proxy_address  = conf["proxy"]["address"]
    Garb.proxy_port     = conf["proxy"]["port"].to_i
    Garb.proxy_user     = conf["proxy"]["user"]
    Garb.proxy_password = conf["proxy"]["password"]

    Garb::Session.login(conf["garb"]["session"]["user"],
                        conf["garb"]["session"]["password"])
    @profile = Garb::Management::Profile.all.detect {|p|
      p.web_property_id == conf["garb"]["profile"]["id"] &&
      p.title           == conf["garb"]["profile"]["title"]
    }
  end

  def pageviews(start_date, end_date, page_limit)
    colors = [
      "#ffff00",
      "#55aaff",
      "#ff0000",
      "#00ff00",
      "#ff0080",
      "#ff8000",
      "#8000ff",
      "#dfdfdf",
      "#0000ff",
      "#aa8055",
      "#aaaa55"
    ]
    raise if page_limit > colors.length
    
    result = Hash.new
    @profile.days({
      :sort       => :day,
      :start_date => start_date,
      :end_date   => end_date
    }).each do |total|
      result["total"] ||= Hash.new
      result["total"][:pageviews] ||= Array.new
      result["total"][:pageviews].push(total.pageviews.to_i)
      result["total"][:color] ||= colors.shift
    end
    @profile.alls({
      :sort       => :pageviews.desc,
      :limit      => page_limit,
      :start_date => start_date,
      :end_date   => end_date
    }).each do |toppage|
      @profile.days({
        :sort       => :day,
        :start_date => start_date,
        :end_date   => end_date,
        :filters    => { :page_path.eql => toppage.page_path }
      }).each do |page|
        result[toppage.page_title] ||= Hash.new
        result[toppage.page_title][:pageviews] ||= Array.new
        result[toppage.page_title][:pageviews].push(page.pageviews.to_i)
        result[toppage.page_title][:color] ||= colors.shift
      end
    end
    result
  end

  def referrers(start_date, end_date)
    sources = [
      {:name => "(direct)", :color => "#55aaff"},
      {:name => "google",   :color => "#ff0000"},
      {:name => "t.co",     :color => "#00ff00"},
      {:name => "facebook", :color => "#ff0080"},
      {:name => "gigazine", :color => "#ffff00"},
      {:name => "atmarkit", :color => "#ff8000"},
      {:name => "hatena",   :color => "#8000ff"}
    ]

    result = Hash.new
    sources.each do |source|
      @profile.days({
        :sort       => :day,
        :start_date => start_date,
        :end_date   => end_date,
        :filters    => { :source.contains => source[:name] }
      }).each do |page|
        result[source[:name]] ||= Hash.new
        result[source[:name]][:pageviews] ||= Array.new
        result[source[:name]][:pageviews].push(page.pageviews.to_i)
        result[source[:name]][:color] ||= source[:color]
      end
    end
    result
  end

  def sources
    @profile.sources({
      :sort => :pageviews.desc
    }).each do |source|
      puts "#{source.source}#{source.referral_path} : #{source.pageviews}"
    end
  end

  class Alls
    extend Garb::Model

    dimensions :pagePath, :pageTitle
    metrics    :pageviews
  end

  class Days
    extend Garb::Model

    dimensions :day
    metrics    :pageviews
  end

  class Sources
    extend Garb::Model

    dimensions :source, :referralPath
    metrics    :pageviews
  end
end
