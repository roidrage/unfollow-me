load File.join(APP_ROOT, 'config', 'environment.rb')

loop do
  begin
    Follower.sync_with_twitter
  rescue Exception => e
    RAILS_DEFAULT_LOGGER.warn("Synchronizing caused an error: #{e}")
  end
  sleep $sleepy_time * 1
end
