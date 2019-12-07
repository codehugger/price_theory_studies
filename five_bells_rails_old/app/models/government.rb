class Government < Agent
  belongs_to :region
  has_one :government_bank
  has_one :bank, through: :government_bank

  def as_json(options=nil)
    { name: name, initial_bank_name: bank.try(:name) }
  end

  def self.from_json(json)
    hash = json.class == String ? JSON.parse(json) : json
    new(name: hash["name"])
  end

  protected

  def set_name
    self.name ||= "Government #{generate_number_sequence(6)}"
  end
end
