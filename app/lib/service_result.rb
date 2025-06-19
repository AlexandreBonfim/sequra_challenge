class ServiceResult
  attr_reader :payload, :errors

  def initialize(success:, payload: nil, errors: [])
    @success = success
    @payload = payload
    @errors = Array(errors).compact
    freeze
  end

  def success?
    @success
  end

  def failure?
    !@success
  end

  def self.success(payload = nil)
    new(success: true, payload: payload)
  end

  def self.failure(errors = [], payload = nil)
    new(success: false, payload: payload, errors: errors)
  end
end
