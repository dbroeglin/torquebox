
class RootController < ApplicationController

  include TorqueBox::Injectors

  def index
  end

  # Be sure we're using torquebox cache
  def torqueboxey
    @cache_type = Rails.cache.class.name
    @cache_mode = Rails.cache.clustering_mode
  end

  def cachey
    Rails.cache.write( "taco", "crunchy" )
    @cache_value = Rails.cache.read( "taco" )
  end

  def cacheytx
    TorqueBox.transaction do
      Rails.cache.write( "taco", "crunchy" )
    end
    @cache_value = Rails.cache.read( "taco" )
    render "root/cachey"
  end

  def cacheytxthrows
    Rails.cache.write( "taco", "soft" )
    begin
      TorqueBox.transaction do
        Rails.cache.write( "taco", "crunchy" )
        raise "I like it soft"
      end
    rescue Exception => e
      # Exception should be "I like it soft"
    end
    @cache_value = Rails.cache.read( "taco" )
    render "root/cachey"
  end

  # The Rails.cache is using ActiveSupport::Cache::TorqueBoxStore which
  # defaults to invalidation mode. That mode does not replicate or
  # distribute values across nodes. So, we'll use an alacarte cache
  # to test clustered values

  # Clustered tests
  def clustery
    @cache_type = defaultcache.class.name
    @cache_mode = defaultcache.clustering_mode
    render "root/torqueboxey"
  end

  def putcache
    key = params['symbol'] ? :mode : 'mode'
    defaultcache.put( key, "clustery" )
    @cache_value = defaultcache.get( key )
    render "root/cachey"
  end

  def getcache
    key = params['symbol'] ? :mode : 'mode'
    @cache_value = defaultcache.get( key )
    render "root/cachey"
  end

  def writecache
    storecache.write( "mode", "clustery" )
    @cache_value = storecache.read( "mode" )
    render "root/cachey"
  end

  def readcache
    @cache_value = storecache.read( "mode" )
    render "root/cachey"
  end

  def putrepl
    replcache.put( "mode", "clustery" )
    @cache_value = replcache.get( "mode" )
    render "root/cachey"
  end

  def getrepl
    @cache_value = replcache.get( "mode" )
    render "root/cachey"
  end

  def putprocessor
    # causes the processor to write to the cache
    queue = fetch( '/queue/simple_queue' )
    message = { :action => "write", :message => "clustery" } 
    queue.publish( message )

    # wait until the processor has spun up and placed the message in
    # the cache
    queue = fetch( '/queue/backchannel' )
    queue.receive( :timeout => 30000 )

    @cache_value = "success"
    render "root/cachey"
  end

  def getprocessor
    # cause the processor to read from the cache 
    # and publish the value to backchannel
    queue = fetch( '/queue/simple_queue' )
    message = { :action => "read" }
    queue.publish( message )

    queue = fetch( '/queue/backchannel' )
    @cache_value = queue.receive( :timeout => 30000 )
    render "root/cachey"
  end

  protected
  def defaultcache
    @defaultcache ||= TorqueBox::Infinispan::Cache.new
  end

  def replcache
    @replcache ||= TorqueBox::Infinispan::Cache.new(:name=>'testrepl', :mode=>:repl)
  end

  def storecache
    @storecache ||= ActiveSupport::Cache::TorqueBoxStore.new(:mode=>:dist, :name=>'distributed_cache_test')
  end

end
