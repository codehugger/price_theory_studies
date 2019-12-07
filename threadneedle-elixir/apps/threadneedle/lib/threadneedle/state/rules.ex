defmodule Threadneedle.State.Rules do
  alias __MODULE__

  defstruct state: :initialized, round_state: nil

  def new(), do: %Rules{}

  #############################################################################
  # Execution
  #############################################################################

  def check(%Rules{state: state} = rules, :start) when state in [:initialized],
    do: {:ok, %Rules{rules | state: :running, round_state: :round_started}}

  def check(%Rules{state: state} = rules, :stop) when state in [:running, :paused],
    do: {:ok, %Rules{rules | state: :stopped, round_state: nil}}

  def check(%Rules{state: state} = rules, :pause) when state in [:running],
    do: {:ok, %Rules{rules | state: :paused}}

  def check(%Rules{state: state} = rules, :resume) when state in [:paused],
    do: {:ok, %Rules{rules | state: :running}}

  def check(%Rules{state: state} = rules, :next_round) when state in [:running],
    do: {:ok, %Rules{rules | state: :running, round_state: :start}}

  def check(%Rules{state: :running, round_state: round_state} = rules, :step) do
    case round_state do
      :start -> {:ok, %Rules{rules | round_state: :production}}
      :production -> {:ok, %Rules{rules | round_state: :salaries}}
      :salaries -> {:ok, %Rules{rules | round_state: :benefits}}
      :benefits -> {:ok, %Rules{rules | round_state: :debts}}
      :debts -> {:ok, %Rules{rules | round_state: :end}}
    end
  end

  #############################################################################
  # Start of Round
  #############################################################################

  def check(%Rules{state: :running, round_state: :start} = rules, :add_bank),
    do: {:ok, rules}

  def check(%Rules{state: :running, round_state: :start} = rules, :add_factory),
    do: {:ok, rules}

  def check(%Rules{state: :running, round_state: :start} = rules, :add_government),
    do: {:ok, rules}

  def check(%Rules{state: :running, round_state: :start} = rules, :add_person),
    do: {:ok, rules}

  #############################################################################
  # During Round
  #############################################################################

  def check(%Rules{state: :running, round_state: :production} = rules, action)
      when action in [:produce_goods, :provide_services],
      do: {:ok, rules}

  def check(%Rules{state: :running, round_state: :salaries} = rules, :pay_salary),
    do: {:ok, rules}

  def check(%Rules{state: :running, round_state: :benefits} = rules, :pay_benefit),
    do: {:ok, rules}

  def check(%Rules{state: :running, round_state: :debts} = rules, :pay_loan),
    do: {:ok, rules}

  def check(%Rules{state: :running, round_state: :end} = rules, :request_loan),
    do: {:ok, rules}

  #############################################################################
  # End of Round
  #############################################################################

  def check(_state, _action), do: :error
end
