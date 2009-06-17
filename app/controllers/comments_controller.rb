class CommentsController < ApplicationController
  
  no_login_required
  skip_before_filter :verify_authenticity_token
  before_filter :find_page
  before_filter :set_host

  def index
    @page.selected_comment = @page.comments.find_by_id(flash[:selected_comment])
    @page.request = request
    render :text => @page.render
  end
  
  def create
    comment = @page.comments.build(params[:comment])
    comment.request = @page.request = request
    if Comment.inverse_captcha_enabled?
      # The inverse captcha key attribute (looks something like ick_niwom) cannot
      # be set via mass assignment (there's no way to know what the key name is
      # ahead of time to specify via attr_accessible in the Comment model) so it
      # needs to be plucked out of the posted comment params and set directly.
      (params[:comment].keys - Comment.accessible_attributes.to_a).each do |attr|
        if attr =~ /\Aick_(.*)\z/
          if Comment.hash_value($1) == params[:comment][:inverse_captcha_key]
            comment.send "#{attr}=", params[:comment][attr]
          end
        end
      end
    end
    comment.save!
    
    clear_single_page_cache(comment)
    if Radiant::Config['comments.notification'] == "true"
      if comment.approved? || Radiant::Config['comments.notify_unapproved'] == "true"
        CommentMailer.deliver_comment_notification(comment)
      end
    end
    
    flash[:selected_comment] = comment.id
    redirect_to "#{@page.url}comments#comment-#{comment.id}"
  rescue ActiveRecord::RecordInvalid
    @page.last_comment = comment
    render :text => @page.render
 # rescue Comments::MollomUnsure
    #flash, en render :text => @page.render
  end
  
  private
  
    def find_page
      url = params[:url]
      url.shift if defined?(SiteLanguage) && SiteLanguage.count > 1
      @page = Page.find_by_url(url.join("/"))
    end
    
    def set_host
      CommentMailer.default_url_options[:host] = request.host_with_port
    end
    
    def clear_single_page_cache(comment)
      if comment && comment.page
        Radiant::Cache::EntityStore.new.purge(comment.page.url)
        Radiant::Cache::MetaStore.new.purge(comment.page.url)
      end
    end
  
end
