require 'securerandom'

class ShortenedUrl < ActiveRecord::Base
  validates :short_url, uniqueness: true
  validates :long_url, :short_url, presence: true

  belongs_to :submitter,
    class_name: 'User',
    foreign_key: :user_id,
    primary_key: :id

  def self.random_code
    while true
      random_code = SecureRandom.urlsafe_base64
      break unless ShortenedUrl.exists?(short_url: random_code)   # searches id by default
    end

    random_code
  end

  def self.create_for_user_and_long_url!(user, long_url)
    shortened_url = ShortenedUrl.new(
      long_url: long_url,
      short_url: random_code,
      user_id: user.id
    )
    shortened_url.save! # not create!
  end

end
