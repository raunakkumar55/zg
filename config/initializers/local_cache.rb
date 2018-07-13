require "redis"
redis_config = {:host => "localhost", :port => 6379, :db => 1}
LocalCache = Redis::Namespace.new("pushup", :redis => Redis.new(redis_config))