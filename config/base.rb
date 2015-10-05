module VLCTechHub
  class << self
    def environment; (ENV['RACK_ENV'] || :development).to_sym end
    def environment= env; ENV['RACK_ENV'] = env.to_s end
    def development?; environment == :development end
    def production?;  environment == :production  end
    def test?;        environment == :test        end
  end
end
