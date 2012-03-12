class Post < ActiveRecord::Base
  belongs_to :feed
  has_many :unreads, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  validates_uniqueness_of :url, unless: ->(post) { post.shared? }
  validates_presence_of :url
  validates_presence_of :title
  validates_presence_of :published
  validates_presence_of :content
  
  after_create :generate_unreads
  
  def self.shared
    where("shared = 't'")
  end
  
  def self.unread_for_user(user)
    joins("LEFT JOIN unreads ON posts.id = unreads.post_id").where("unreads.user_id = #{user.id}")
  end
  
  def generate_unreads
    feed.users.each do |subscriber|
      subscriber.unreads.create(post: self)
    end
  end
  
  def unread_for_user?(user)
    unreads.find_by_user_id(user.id).present? # FIXME
  end
end
