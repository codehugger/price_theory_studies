class Region < Agent
  has_ancestry
  belongs_to :world, optional: true

  has_many :banks
  has_many :customer_banks, foreign_key: 'region_id', class_name: 'CustomerBank'
  has_many :factories
  has_many :markets
  has_many :people
  has_one :central_bank
  has_one :government
  has_one :labour_market

  before_validation :set_name

  alias_method :regions, :children

  def world() super || root.world end
  def country?() root? end

  def as_json(options=nil)
    {
      name: name,
      regions: regions.map { |r| r.as_json(options=nil) },
      customer_banks: customer_banks.map { |b| b.as_json(options=nil) },
      factories: factories.map { |f| f.as_json(options=nil) },
      markets: markets.map { |m| m.as_json(options=nil) },
      people: people.map { |p| p.as_json(options=nil) },
      central_bank_name: central_bank.try(:name),
      labour_market: labour_market.nil? ? nil : labour_market.as_json(options=nil),
      government: government.nil? ? nil : government.as_json
    }
  end

  def self.from_json(json)
    hash = json.class == String ? JSON.parse(json) : json
    obj = new(name: hash["name"])
    hash["regions"].each { |x| obj.children.new(Region.from_json(x)) }
    hash["customer_banks"].each { |x| obj.customer_banks.new(CustomerBank.from_json(x)) }
    hash["factories"].each { |x| obj.factories.new(Factory.from_json(x)) }
    hash["markets"].each { |x| obj.markets.new(Market.from_json(x)) }
    hash["people"].each { |x| obj.people.new(Person.from_json(x)) }
    obj.central_bank = Bank.from_json(hash["central_bank"]) unless hash["central_bank"].nil?
    obj.labour_market = LabourMarket.from_json(hash["labour_market"]) unless hash["labour_market"].nil?
    obj.government = Government.from_json(hash["government"]) unless hash["government"].nil?
    obj
  end

  def evaluate(cycle)
  end

  protected

  def set_name
    self.name ||= "#{world.name.gsub(/\s/, '')}-Region-#{id}"
  end
end
