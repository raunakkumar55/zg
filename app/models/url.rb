require 'uri'
class Url < ApplicationRecord

  REDIS_NAMESPACE_PREFIX = "URL:Shortener:"
  REDIS_SHORTENER_HASH_LONG = "#{REDIS_NAMESPACE_PREFIX}Long#"
  REDIS_SHORTENER_HASH_SHORT = "#{REDIS_NAMESPACE_PREFIX}Short#"
  # 62 characters in total as base
  ALLOWED_CHARACTER_SPACE = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".split(//)
  EXPIRY_TIME_IN_SECONDS = 3600 * 24 #24 hrs
  RANDOM_SALT_LENGTH = 4

  #get short url from long url
  def self.get_short_url(long_url)
    long_url = sanitize(long_url)
    url_md5 = get_md5(long_url)
    #do a lookup in redis localcache
    shortened_url = LocalCache.get("#{REDIS_SHORTENER_HASH_LONG}#{url_md5}")
    if(shortened_url.blank?)
      #couldn't find in redis, do a look up in table
      db_record = Url.where(:url_hash => url_md5).select([:short_url]).first
      shortened_url = db_record.present? ? db_record[:short_url] : generate_short_url(long_url, url_md5)
    end
    #set in local cache
    LocalCache.set("#{REDIS_SHORTENER_HASH_LONG}#{url_md5}", shortened_url, {:ex => EXPIRY_TIME_IN_SECONDS})
    LocalCache.set("#{REDIS_SHORTENER_HASH_SHORT}#{shortened_url}", long_url, {:ex => EXPIRY_TIME_IN_SECONDS})
   return shortened_url
  end

  #get long url from short url
  def self.get_long_url(short_url)
    #do a cache lookup
    long_url = LocalCache.get("#{REDIS_SHORTENER_HASH_SHORT}#{short_url}")
    if long_url.nil?
      #do a db lookup
      db_record = Url.where(:short_url => short_url).select([:long_url, :url_hash]).first
      return nil if db_record.blank?
      long_url = db_record[:long_url]
      url_hash = db_record[:url_hash]
      #set in local cache
      LocalCache.set("#{REDIS_SHORTENER_HASH_LONG}#{url_hash}", short_url, {:ex => EXPIRY_TIME_IN_SECONDS})
      LocalCache.set("#{REDIS_SHORTENER_HASH_SHORT}#{short_url}", long_url, {:ex => EXPIRY_TIME_IN_SECONDS})
    end
    return long_url
  end

  def self.get_md5(str)
    Digest::MD5.hexdigest(str)
  end


  ##########################################################
  ##################### Private Methods ####################
  ##########################################################

  private

  def self.get_main_domain(url)
    scheme = URI.parse(url).scheme
    url = "http://#{url}" if scheme.nil?
    host = URI.parse(url).host.downcase
    host.start_with?('www.') ? host[4..-1] : host
  end

  def self.sanitize(long_url)
    uri = URI(long_url)
    sanitized_url = get_main_domain(long_url)
    sanitized_url += uri.query.present? ? '?'+uri.query.to_s : ""
    sanitized_url += uri.fragment.present? ? '#'+uri.fragment.to_s : ""
    return sanitized_url
  end

  def self.convert_uid_to_short(uid)
    surl = ''
    base = ALLOWED_CHARACTER_SPACE.length
    while uid > 0
      surl << ALLOWED_CHARACTER_SPACE[uid.modulo(base)]
      uid /= base
    end
    surl.reverse
  end

  def self.generate_short_url(url, url_hash)
    primary_id = create_record_and_get_id
    #generate a key using primary_id
    short_url = convert_uid_to_short(primary_id)
    Url.update(primary_id, :long_url => url, :short_url => short_url, :url_hash => url_hash)
    return short_url
  end

  def self.create_record_and_get_id
    #create a new record and return its id
    Url.create.id
  end
end

