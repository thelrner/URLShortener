class ShortenedUrl < ActiveRecord::Base
  validates :short_url, uniqueness: true
  validates :long_url, :short_url, presence: true
end
