require 'dry/monads'
require 'dry/validation'

class BaseService
  extend Dry::Initializer
  include Dry::Monads[:result]
  extend Dry::Core::ClassAttributes

  defines :permissible_errors
  permissible_errors []

  def self.call(*args)
    validation = process_args(args) { |value| self::Schema.call(value) }
    return Failure.new(validation.errors(full: true).reduce('') { |a, e| a + "#{e.text};" }) unless validation.success?

    process_args(args) { |value| new(**value).call }
  rescue StandardError => e
    handle_error(e)
  end

  def self.handle_error(error)
    raise error unless permissible_errors.any? { |type| error.is_a? type }

    Failure.new(error.to_s)
  end

  def self.process_args(args)
    is_hash = args.size == 1 && args.first.is_a?(Hash)

    yield(is_hash ? args.first : args)
  end
end
