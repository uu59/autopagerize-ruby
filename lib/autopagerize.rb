#require "autopagerize/version"
require "addressable/uri"
require "nokogiri"
require "httpclient"

class Autopagerize
  include Enumerable

  attr_reader :url, :client, :siteinfo, :options

  def initialize(url, siteinfo, options = {})
    @url = url
    @siteinfo = siteinfo

    @options = {
      :maxpage => 10,
      :headers => {},

      # for internal/test use
      :current_page => 1,
      :httpclient => nil,
      :site => nil,
    }.merge(options)

    @site = @options[:site]
  end

  def nextlink
    return nil unless site
    node = document.at_xpath(site["data"]["nextLink"])
    return nil unless node
    Addressable::URI.join(url, node.attributes["href"].to_s).to_s
  end

  def next
    return nil if options[:maxpage] <= options[:current_page]
    return nil if nextlink.nil?
    @next ||= Autopagerize.new(nextlink, siteinfo, options.merge(:current_page => options[:current_page] + 1, :site => site))
  end

  def each
    current = self
    yield current
    while current = current.next
      yield current
    end
  end

  def process
    @processed ||= begin
      result = document.dup

      # Insert rule:
      # https://autopagerize.jottit.com/details_of_siteinfo_(ja)
      before = site["data"]["insertBefore"]
      if before.nil? || before.length == 0 || result.at_xpath(before).nil?
        page = result.xpath(site["data"]["pageElement"]).last
        point = Nokogiri::XML::Node.new("dummy_for_autopagerize", result.document)
        page.after point
      else
        point = result.at_xpath(before)
      end

      @processed_page_elements = [self.page]
      current = self
      while current = current.next
        point.before(current.page)
        @processed_page_elements << current.page
      end
      point.remove
      @processed_document = result
      true
    end
  end

  def processed?
    @processed
  end

  def processed_document
    process
    @processed_document
  end

  def processed_page_elements
    process
    @processed_page_elements
  end

  def processed_html
    processed_document.to_xml
  end

  def site
    @site ||= siteinfo.find do |site|
      /#{normalize_regex(site["data"]["url"])}/.match(url) && site["data"]["nextLink"] && document.at_xpath(site["data"]["nextLink"])
    end
  end

  def client
    options[:httpclient] ||= HTTPClient.new
  end

  def html
    @html ||= client.get_content(url, nil, options[:headers])
  end

  def document
    @document ||= Nokogiri::HTML.parse(html)
  end

  def page
    document.xpath(site["data"]["pageElement"]).last
  end
  alias :page_element :page

  private
  def normalize_regex(re)
    # to be quiet
    # warning: nested repeat operator + and ? was replaced with '*': /^http:\/\/1stpower\.web\.fc2\.com\/comic(?:\d+)?/
    re.gsub("+)?", "*)")
  end
end
