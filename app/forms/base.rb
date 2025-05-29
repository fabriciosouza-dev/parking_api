class Base
  attr_reader :errors

  def initialize(params = {})
    @params = params || {}
    @errors = {}
  end

  def valid?
    validate
    @errors.empty?
  end

  protected

  def validate
    raise NotImplementedError, "#{self.class.name} must implement the protected instance method validate"
  end

  def add_error(field, message)
    @errors[field] ||= []
    @errors[field] << message
  end

  def get_param(key)
    @params[key.to_s] || @params[key.to_sym]
  end
end
