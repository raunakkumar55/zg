class UrlsController < ApplicationController

  # Ideally we should include it in api:V1 namespacing to have a control over versioning
  # & supporting older clients as well
  skip_before_action :verify_authenticity_token
  before_action :validate_url, only: [:shorten]

  def new
    @url = Url.new
  end

  def shorten
    long_url = params[:long_url]
    short_url = Url.get_short_url(long_url)
    # Ideally base url should be in constant and under redirect link
    # so that we can track redirection as well, keeping url structure uniform
    render json: {:status => 200, :short_url => request.base_url+"/"+short_url}
  end

  def index
    # Restricting it to 20, Not paginating for now
    @urls = Url.all.limit(20)
  end

  def inflate
    long_url = Url.get_long_url(params[:short_token])
    @url = URI(long_url)
    if @url.scheme.blank?
     @url.scheme = "http"
     @url.path = "//"+@url.path
   end
  end







  private

  def validate_url
    # regex = /^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+$/i
    # regex =~ params[:long_url]
  end


end
