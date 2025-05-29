require 'mongo'

module Database
  class << self
    def client
      @client ||= Mongo::Client.new(
        ['mongo:27017'],
        database: ENV['MONGODB_DATABASE'] || 'parking_api'
      )
    end

    def collection(name)
      client[name]
    end
  end
end
