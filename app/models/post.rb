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
  
  def self.for_user(user)
    joins("JOIN feeds ON feeds.id = posts.feed_id JOIN subscriptions ON feeds.id = subscriptions.feed_id")
      .where("subscriptions.user_id = #{user.id}")
  end
  
  def self.for_feed(feed_id)
    joins("JOIN feeds ON feeds.id = posts.feed_id").where("feeds.id = #{feed_id}")
  end
  
  def self.chron
    order("published ASC")
  end
  
  def self.revchron
    order("published DESC")
  end
  
  def self.unread_for_user(user)
    joins("JOIN unreads ON posts.id = unreads.post_id").where("unreads.user_id = #{user.id}")
  end
  
  def self.for_options(user, date_sort, items_filter, feed_id=nil)
    if feed_id.present?
      posts = for_feed(feed_id)
      posts = posts.unread_for_user(user) if items_filter == "unread"
    else
      posts = (items_filter == "unread" ? unread_for_user(user) : for_user(user))
    end
    posts = (date_sort == "chron" ? posts.chron : posts.revchron)
    return {unread_count: posts.unread_for_user(user).count, entries: posts.limit(10)}
  end
  
  def self.shared
    where("shared = 't'")
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
