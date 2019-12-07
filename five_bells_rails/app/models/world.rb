class World < ApplicationRecord
  has_many :customer_banks, foreign_key: 'world_id', class_name: 'CustomerBank'
  has_many :factories
  has_many :markets
  has_many :people
  has_many :statistics

  has_one :central_bank
  has_one :government
  has_one :labour_market

  def cycle() current_cycle end

  def evaluate()
    raise 'Simulation halted' if self.halted
    (1..cycle_step_size).each do |_|
      puts "Evaluating markets..."
      markets.shuffle.each { |market| market.evaluate }
      puts "Markets done!"

      puts "Evaluating factories..."
      factories.shuffle.each { |factory| factory.evaluate }
      puts "Factories done!"

      puts "Evaluating people..."
      people.shuffle.each  { |person| person.evaluate }
      puts "People done!"

      puts "Evaluating customer banks..."
      customer_banks.shuffle.each { |bank| bank.evaluate }
      puts "Banks done!"

      update!(current_cycle: self.current_cycle += 1)

      # record statistics and reset
      markets.each { |m| m.record_stats_and_reset_internals }
      factories.each { |m| m.record_stats_and_reset_internals }
      people.each { |m| m.record_stats_and_reset_internals }
      customer_banks.each { |m| m.record_stats_and_reset_internals }
    end
  rescue Exception => e
    update!(halted: true)
    raise e
  end

  def as_json(options=nil)
    {
      name: name,
      worlds: worlds.map { |r| r.as_json }
    }
  end

  def self.from_json(json)
    hash = json.class == String ? JSON.parse(json) : json
    new(
      name: hash["name"],
      customer_banks: hash["customer_banks"].map { |cb| CustomerBank.from_json(cb) }
    )
  end

  protected

  def set_name
    self.name ||= "World-#{id}"
  end
end
