class World < Agent
  has_many :regions

  has_many :people, through: :regions
  has_many :factories, through: :regions
  has_many :markets, through: :regions
  has_many :banks, through: :regions
  has_many :customer_banks, through: :regions
  has_many :simulations

  def evaluate(cycle_count=1)
    @current_cycle ||= 1

    (1..cycle_count).each do |_|
      puts "Evaluating markets..."
      markets.shuffle.each { |market| market.evaluate(@current_cycle) }
      puts "Markets done!"

      puts "Evaluating factories..."
      factories.shuffle.each { |factory| factory.evaluate(@current_cycle) }
      puts "Factories done!"

      puts "Evaluating people..."
      people.shuffle.each  { |person| person.evaluate(@current_cycle) }
      puts "People done!"

      puts "Evaluating customer banks..."
      customer_banks.shuffle.each { |bank| bank.evaluate(@current_cycle) }
      puts "Banks done!"

      puts "Evaluating root regions..."
      regions.roots.shuffle.each { |region| region.evaluate(@current_cycle) }
      puts "Root regions done!"

      @current_cycle += 1
    end
  end

  def as_json(options=nil)
    {
      name: name,
      regions: regions.map { |r| r.as_json }
    }
  end

  def self.from_json(json)
    hash = json.class == String ? JSON.parse(json) : json
    new(name: hash["name"], regions: hash["regions"].map { |r| Region.from_json(r) })
  end

  protected

  def set_name
    self.name ||= "World-#{id}"
  end
end
