require 'securerandom'

class ShortenedUrl < ActiveRecord::Base
  validates :short_url, uniqueness: true
  validates :long_url, :short_url, presence: true
  validate :no_more_than_5_in_last_minute         # validate, not validates

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

  def self.prune
    visits.destroy_all("created_at < '#{1.day.ago.to_formatted_s(:db)}'")
  end

  def no_more_than_5_in_last_minute
    recent_posts = ShortenedUrl.where(user_id: user_id).
                where("created_at > ?", 1.minute.ago.to_formatted_s(:db))
    if recent_posts.count > 5
      errors[:base] << "Can't create more than 5 short URLs in a minute!"
    end
  end

  def num_clicks
    visits.count
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques
    visits.where("created_at > ?", 60.minutes.ago.to_formatted_s(:db))
  end

end
