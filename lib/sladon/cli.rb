require 'thor'
require 'sladon'

class Sladon::CLI < Thor
  def start
    client = Sladon::Client.new(config)

    client.start
  end

  private

  def config
    @config ||= Sladon::Config.new
  end
end
