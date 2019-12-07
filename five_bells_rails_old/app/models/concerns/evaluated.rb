module Evaluated
  include ActiveSupport::Concern

  def evaluate(cycle)
    raise NotImplementedError, self.class.name
  end
end
