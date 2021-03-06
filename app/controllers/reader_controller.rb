class ReaderController < ApplicationController
  before_filter :authenticate_user!, except: [:create_post, :bookmarklet, :email_comment]
  protect_from_forgery :except => [:create_post, :bookmarklet, :email_comment]
  
  def index
    redirect_to "/reader/posts/#{params[:post_id]}" if params[:post_id].present?
    @shared, @unshared = current_user.subscriptions(:include => :feeds).partition {|s| s.feed.shared?}
    
    @entries = current_user.unreads(:include => :posts).unshared.order("published ASC").limit(10).map(&:post)
    
    @unread_counts, @shared_unread_count = current_user.unread_counts

    @title = "(#{@unread_count = @unread_counts.values.sum})"
    @shared_unread_count = current_user.shared_unread_count_total
    @regular_unread_count = @unread_count - @shared_unread_count
  end
  
  def posts
    @entry = Post.find(params[:id])
    render "single"
  end
  
  def mine
    @shares = current_user.feed.posts.revshared.limit(10)
    render "mine"
  end
  
  def entries
    @entries = Post.for_options(current_user, params[:date_sort], params[:items_filter], @page = params[:page].to_i, params[:feed_id])
    if feed = Feed.find_by_id(@feed_id = params[:feed_id])
      @feed_name = (feed.title || feed.feed_url) 
    end
    render layout: false
  end
  
  def mark_as_read
    post = Post.find(params[:post_id])
    Unread.find_by_user_id_and_post_id(current_user.id, post.id).try(:destroy)
    render json: {feed_id: post.feed.id}
  end
  
  def mark_as_unread
    post = Post.find(params[:post_id])
    unless (u = Unread.find_by_user_id_and_post_id(current_user.id, post.id))
      u = Unread.create(post_id: post.id, user_id: current_user.id)
    end
    render json: {feed_id: post.feed.id}
  end
  
  def post_share
    post = Post.find(params[:post_id])
    unless (share = current_user.feed.posts.find_by_original_post_id(params[:post_id]))
      current_user.feed.posts.create(post.attributes.merge(shared: true, original_post_id: post.id, created_at: Time.now))
    end
    render text: "OK"
  end
  
  def post_unshare
    post = current_user.feed.posts.find_by_original_post_id(params[:post_id])
    post.try(:destroy)
    render text: "OK"
  end
  
  def share_with_note
   post = Post.find(params[:post_id])
    unless (share = current_user.feed.posts.find_by_original_post_id(params[:post_id]))
      current_user.feed.posts.create(post.attributes.merge(shared: true, original_post_id: post.id, note: params[:note_content], created_at: Time.now))
    end
    render text: "OK"
  end
  
  def create_comment
    post = Post.find(params[:post_id])
    comment = post.comments.create(content: params[:comment_content], user: current_user)
    render partial: "reader/comment", :locals => {comment: comment}
  end
  
  def delete_comment
    comment = Comment.find_by_id(params[:comment_id])
    if comment && comment.user == current_user
      comment.destroy
    end
    render text: "OK"
  end
  
  def edit_comment
    comment = Comment.find_by_id(params[:comment_id])
    if comment && comment.user == current_user
      comment.update_attributes({content: params[:comment_content]})
    end
    render partial: "reader/comment", :locals => {comment: comment}
  end
  
  def create_post
    @post = User.find_by_share_token(params[:token]).feed.posts.create(
      content: params[:content],
      url: params[:url],
      note: params[:note],
      title: params[:title],
      published: Time.now,
      shared: true
    )
    @post.update_attributes({original_post_id: @post.id})
    @origin = params[:origin]
    render layout: false
  end
  
  def mark_all_as_read
    if feed_id = params[:feed_id]
      if feed_id == "shared"
        current_user.unreads.shared.destroy_all
      else
        current_user.unreads.for_feed(feed_id).destroy_all
      end
    else
      current_user.unreads.unshared.destroy_all
    end
    render text: "OK"
  end
  
  def edit_note
    entry = Post.find(params[:post_id])
    entry.update_attributes!({note: params[:content]})
    render partial: "reader/entry_note", :locals => {entry: entry}
  end
  
  def delete_note
    entry = Post.find(params[:post_id])
    entry.update_attributes!({note: nil})
    render text: "OK"
  end
  
  def quickpost
    p = current_user.feed.posts.create(
      content: params[:content],
      title: params[:title],
      published: Time.now,
      url: "#quickpost",
      shared: true,
      author: "#{current_user.name} (Quickpost)"
    )
    p.update_attributes({original_post_id: p.id})
    render text: "OK"
  end
  
  def bookmarklet
    @token = params[:token]
    respond_to do |format|
      format.js
    end
  end
  
  def email_comment
    Report.create(report_type: "cloudmailin", content: {html: params[:html]})
    post = Post.find(params[:subject][/\(post_id: (\d+)\)/, 1])
    user = User.find_by_email(params[:from])
    content = params[:html].split('<div class="gmail_quote">').first.gsub("\r", "").gsub("\n", "").gsub(/(\<br\>)*$/, "").gsub(/(\<div\>)*$/, "")
    post.comments.create(user: user, content: content)
    render :text => "OK", :status => 200
  end
end
