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

  let(:mock_pages) do
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

    [first, second, third]
  end

  let(:client) do
    client = HTTPClient.new
    mock_pages.each do |html|
      client.test_loopback_response << html
    end
    client
  end

  it "#processed?" do
    a = Autopagerize.new("http://bar/", siteinfo, :httpclient => client)
    a.processed?.should be_false
    a.process
    a.processed?.should be_true
  end

  context "found" do
    let(:autopagerize) do
      Autopagerize.new("http://bar/", siteinfo, :httpclient => client)
    end

    it "#processed_document" do
      doc = autopagerize.processed_document
      doc.xpath('//page').length.should == 3
    end

    it "#processed_page_elements" do
      autopagerize.processed_page_elements.length.should == 3
    end

    it "#each" do
      autopagerize.to_enum.to_a.length.should == 3
    end

    it "#nextlink" do
      autopagerize.nextlink.should == "http://bar/next.html"
    end

    it "#next" do
      autopagerize.next.class.should == Autopagerize
    end

    it "#html" do
      autopagerize.html.should == mock_pages.first
    end

    it "#page_element" do
      page = autopagerize.page_element
      page.node_name.should == "page"
    end
  end

  context "not found" do
    let(:autopagerize) do
      Autopagerize.new("http://unknown/", siteinfo, :httpclient => client)
    end

    it "#processed_document equals #document" do
      autopagerize.processed_document.should == autopagerize.document
    end

    it "#processed_page_elements equals []" do
      autopagerize.processed_page_elements.should == []
    end

    it "#page_element" do
      autopagerize.page_element.should be_nil
    end

    it "#nextlink" do
      autopagerize.nextlink.should be_nil
    end

    it "#next" do
      autopagerize.next.should be_nil
    end

    it "#each" do
      autopagerize.to_enum.to_a.should == [autopagerize]
    end

    it "#html" do
      autopagerize.html.should == mock_pages.first
    end
  end
end
