require 'open-uri'

class ThetaPhoto
  attr_reader :image_uri, :page_uri, :type

  def initialize(tweet)
    @page_uri = tweet.urls.map(&:expanded_url).find do |uri|
      uri.host == 'theta360.com' && uri.path =~ %r{^/s/}
    end
    fetch_image_uri if @page_uri
    @type = :theta_photo if valid?
  end

  def fetch_image_uri
    page = Nokogiri::HTML(open(@page_uri.to_s))
    og_images = page.css(%q{meta[property='og:image']})
    if og_images && og_images[0]
      @image_uri = (URI.parse(og_images[0]['content']) rescue nil)
    end
  end

  def valid?
    @image_uri && @page_uri
  end

  def to_json
    self.to_h.to_json
  end

  def to_h
    {
      image_url: @image_uri.to_s,
      page_url: @page_uri.to_s,
      type: @type
    }
  end
end
