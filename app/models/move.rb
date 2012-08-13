class Move
  include ActiveRecord::Validations

  attr_accessor :src, :dest
end
