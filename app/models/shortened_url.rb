require 'securerandom'

class ShortenedUrl < ActiveRecord::Base
  validates :short_url, uniqueness: true
  validates :long_url, :short_url, presence: true

  belongs_to :submitter,
    class_name: 'User',
    foreign_key: :user_id,
    primary_key: :id

  has_many :visits,
    class_name: 'Visit',
    foreign_key: :shortened_url_id,
    primary_key: :id

  has_many :visitors, -> { distinct },
    through: :visits,
    source: :visitor

  def self.random_code
    while true
      random_code = SecureRandom.urlsafe_base64
      break unless ShortenedUrl.exists?(short_url: random_code)   # searches id by default
    end

    random_code
  end

  def self.create_for_user_and_long_url!(user, long_url)
    ShortenedUrl.create!(
      long_url: long_url,
      short_url: random_code,
      user_id: user.id
    )
  end

  def num_clicks
    visits.count
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques
    visits.where(:created_at => (10.minutes.ago..Time.new))
  end
end
