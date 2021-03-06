
TorqueBox.configure do
  environment 'biscuit' => 'gravy', 'dir' => File.expand_path(File.dirname(__FILE__))
  
  environment { 
    HAM :biscuit
    FOO :bar
  }

  options_for :messaging, :default_message_encoding => :marshal_base64
  
  options_for Backgroundable, :disabled => true

  pool :foo, :type => :bounded, :min => 0, :max => 6, :lazy => false

  pool :cheddar do
    type :bounded
    min 0
    max 6
    lazy true
  end

  job AJob, :name => :a_job, :cron => '*/1 * * * * ?'

  #job AJob do
    #cron '*/1 * * * * ?'
  #end
  job ConfiguredJob do
    cron '*/1 * * * * ?'
    config do 
      ham 'biscuit'
    end
  end
  queue '/queue/a-queue', :durable => false
  queue '/queue/another-queue', :durable => false
  queue '/queue/flavor-queue', :durable => false
  queue '/queue/configured-job-queue', :durable => false
  
  queue '/queue/job-queue' do
    durable false
  end

  queue '/queue/another-queue', :durable => false do
    processor AProcessor, :concurrency => 2, :selector => "steak = 'salad'", :config => { :foo => :bar }, :xa => false
  end

  queue '/queue/yet-another-queue' do
    durable false
    processor AProcessor do
      concurrency 2
      selector "steak = 'salad'"
      config(:foo => :bar)
      xa true
    end
  end

  queue '/queue/singleton-queue' do
    durable false
    processor AProcessor do
      singleton true
    end
  end

  topic '/topic/a-topic', :durable => false

  ruby :version => '1.9'

  service AService, :name => 'ham', :config => { :foo => :bar }

  service AnotherService do
    name 'biscuit'
  end

  service AnotherService

  service ConfiguredService do
    name 'condiments'
    config do
      flavor 'with honey'
    end
  end

  
  web  do
    context '/torquebox-rb'
    session_timeout '1234 m'
  end
  
  authentication :ham, :domain => 'torquebox-auth'
  authentication :biscuit do
    domain 'torquebox-auth'
  end
end
