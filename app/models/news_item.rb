class NewsItem < ActiveRecord::Base
  before_validation :clean_text_fields
  before_validation :downcase_scheme
  validates_presence_of :title, :link, :published_at, :guid, :rss_feed_url_id
  validates_presence_of :description, :unless => :is_video?
  validates_url :link
  validates_uniqueness_of :guid, scope: :rss_feed_url_id, :case_sensitive => false
  validates_uniqueness_of :link, scope: :rss_feed_url_id, :case_sensitive => false
  belongs_to :rss_feed_url
  scope :recent, :order => 'published_at DESC', :limit => 10
  serialize :properties, Hash

  TIME_BASED_SEARCH_OPTIONS = ActiveSupport::OrderedHash.new
  TIME_BASED_SEARCH_OPTIONS["h"] = :hour
  TIME_BASED_SEARCH_OPTIONS["d"] = :day
  TIME_BASED_SEARCH_OPTIONS["w"] = :week
  TIME_BASED_SEARCH_OPTIONS["m"] = :month
  TIME_BASED_SEARCH_OPTIONS["y"] = :year

  def is_video?
    link =~ /^#{Regexp.escape('http://www.youtube.com/watch?v=')}.+/i
  end

  def tags
    if properties.key?(:media_content) and
        properties[:media_content][:url].present? and
        properties.key?(:media_thumbnail) and
        properties[:media_thumbnail][:url].present?
      %w(image)
    else
      []
    end
  end

  def thumbnail_url
    properties[:media_thumbnail][:url] if properties[:media_thumbnail]
  end

  def language
    rss_feed_url.language || owner_language_guess
  end

  def owner_language_guess
    first_feed = rss_feed_url.rss_feeds.first
    first_feed.owner_type == 'Affiliate' ? first_feed.owner.locale : first_feed.owner.affiliates.first.locale
  rescue Exception => e
    Rails.logger.warn "NewsItem #{self.id} is not associated with any RssFeed: #{e}"
    'en'
  end

  private

  def clean_text_fields
    %w(title description contributor subject publisher).each { |field| self.send(field+'=', clean_text_field(self.send(field))) }
  end

  def downcase_scheme
    self.link = link.sub('HTTP','http').sub('httpS','https') if link.present?
  end

  def clean_text_field(str)
    str.squish if str.present?
  end
end
