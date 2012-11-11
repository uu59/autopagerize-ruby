# Autopagerize gem

Autopagerize gem works as such extensions:

- [AutoPager Chrome](https://chrome.google.com/webstore/detail/autopager-chrome/mmgagnmbebdebebbcleklifnobamjonh?hl=ja)
- [AutoPagerize](https://chrome.google.com/webstore/detail/autopagerize/igiofjhpmpihnifddepnpngfjhkfenbp)
- [AutoPatchWork](https://chrome.google.com/webstore/detail/autopatchwork/aeolcjbaammbkgaiagooljfdepnjmkfd?hl=ja)

## Usage

You must download SITEINFO from <http://wedata.net/databases/AutoPagerize/items_all.json>

    $ curl http://wedata.net/databases/AutoPagerize/items_all.json > siteinfo.json 

    require "rubygems"
    require "multi_json"
    require "autopagerize"

    siteinfo = MultiJson.load(File.read("siteinfo.json"))
    url = "http://www.google.com/search?q=test"
    page = Autopagerize.new(url, siteinfo)
    puts page.processed_html

## Advance Usage

    require "rubygems"
    require "multi_json"
    require "autopagerize"

    siteinfo = MultiJson.load(File.read("siteinfo.json"))
    url = "http://apod.nasa.gov/apod/ap090903.html"
    apod = Autopagerize.new(url, siteinfo, {
      :maxpage => 30,
      :headers => {
        "User-Agent" => "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)",
      },
    })
    apod.each do |page|
      img = page.page_element.at_xpath('//a/img/..')
      next unless img
      puts URI.join(url, img.attributes["href"].to_s).to_s
    end

## Installation

Add this line to your application's Gemfile:

    gem 'autopagerize'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install autopagerize


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
