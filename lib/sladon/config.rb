require 'sladon'

class Sladon::Config
  def self.properties
    @properties ||= []
  end

  def self.property(name)
    name = name.to_s.to_sym
    return if properties.include?(name)

    properties << name
    attr_writer(name)

    define_method(name) do
      return instance_variable_get("@#{name}") if instance_variable_defined?("@#{name}")

      instance_variable_set("@#{name}", ENV["SLADON_#{name.to_s.upcase}"])
    end
  end

  def initialize(options = {})
    options.each_pair do |key, val|
      next unless properties.include?(key.to_s.to_sym)
      instance_variable_set("@#{key}", val)
    end
  end

  property :base_url
  property :bearer_token
  property :webhook_url
end
