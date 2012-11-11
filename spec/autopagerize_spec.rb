# -- coding: utf-8

require "spec_helper"

describe Autopagerize do
  let(:siteinfo) do
    json = MultiJson.dump [
      {
        :data => {
          :url => "^http://foo/",
          :nextLink => "nomatch",
        },
      },
      {
        :data => {
          :url => "^http://bar/",
          :pageElement => "//page",
          :nextLink => "//a",
        }
      },
      {
        :data => {
          :url => "^http://baz/",
          :pageElement => "//foobar",
          :nextLink => "//a",
        }
      },
    ]
    MultiJson.load(json)
  end

  it "should autopagerize" do
    first = <<-HTML
    <!doctype html>
    <page>first page</page>
    <a href="next.html">next link</a>
    HTML

    second = <<-HTML
    <!doctype html>
    <page>next.html</page>
    <a href="morenext.html">go to final page</a>
    HTML

    third = <<-HTML
    <!doctype html>
    <page>final page</page>
    HTML

    client = HTTPClient.new
    client.test_loopback_response << first << second << third
    a = Autopagerize.new("http://bar/", siteinfo, :httpclient => client)
    a.nextlink.should == "http://bar/next.html"
    a.to_enum.to_a.length.should == 3
  end
end
