defmodule Threadneedle.Core.Government do
  @moduledoc """
  Represents a governmental entity within a Threadneedle simulation.

  A government holds a registry for

    - People
    - Banks
    - Factories
    - Markets
    - Regions (sub-governments)

  Optionally, a government can also define

    - A parent government (making this government a region within that government)
    - A central bank used by the government
    - A commercial bank used by the government

  A government that handles taxes also defines

    - A collection of tax policies which are then applied and collected from the relevant
    entities registered in the government.
  """

  alias Threadneedle.Core.{Bank, Factory, Loan, Market, Person}
  alias __MODULE__, as: Govt

  use StructBuilder

  defstruct name: "Government",
            type: :basel2,
            government: nil,
            central_bank: nil,
            bank: nil,
            labour_market: nil,
            banks: %{},
            people: %{},
            employees: %{},
            factories: %{},
            markets: %{},
            regions: %{},
            tax_policies: %{},
            treasuries: %{},
            capital_multiplier: 10.0

  @doc """
  Adds a person to the government.

  ## Examples

      iex> {:ok, govt} = Govt.new(%{type: :basel2}) |> Govt.add_person(%Person{name: "test person"})
      iex> govt
      %Govt{
        people: %{"test person" =>
          %Person{
            name: "test person"
          }
        }
      }
  """
  def add_person(%Govt{} = govt, %Person{} = person) do
    case Map.has_key?(govt.people, person.name) do
      true -> {:error, "person_name_taken"}
      _ -> {:ok, struct(govt, people: Map.put(govt.people, person.name, person))}
    end
  end

  @doc """
  Adds a bank to the government.

  ## Examples

      iex> {:ok, govt} = Govt.new(%{type: :basel2}) |> Govt.add_bank(%Bank{bank_no: "test bank"})
      iex> govt
      %Govt{
        banks: %{"test bank" =>
          %Bank{
            bank_no: "test bank"
          }
        }
      }
  """
  def add_bank(%Govt{} = govt, %Bank{} = bank) do
    case Map.has_key?(govt.banks, bank.bank_no) do
      true -> {:error, :bank_name_taken}
      _ -> {:ok, struct(govt, banks: Map.put(govt.banks, bank.bank_no, bank))}
    end
  end

  @doc """
  Adds a factory to the government.

  ## Examples

      iex> {:ok, govt} = Govt.new(%{type: :basel2}) |> Govt.add_factory(%Factory{name: "Test Factory"})
      iex> govt
      %Govt{
        factories: %{"Test Factory" =>
          %Factory{name: "Test Factory"}
        }
      }
  """
  def add_factory(%Govt{} = govt, %Factory{} = factory) do
    case Map.has_key?(govt.factories, factory.name) do
      true -> {:error, :factory_name_taken}
      _ -> {:ok, struct(govt, factories: Map.put(govt.factories, factory.name, factory))}
    end
  end

  @doc """
  Adds a market to the government.

  ## Examples

      iex> {:ok, govt} = Govt.new(%{type: :basel2}) |> Govt.add_market(%Market{name: "Test Market"})
      iex> govt
      %Govt{
        markets: %{"Test Market" =>
          %Market{name: "Test Market"}
        }
      }
  """
  def add_market(%Govt{} = govt, %Market{} = market) do
    case Map.has_key?(govt.markets, market.name) do
      true -> {:error, :market_name_taken}
      _ -> {:ok, struct(govt, markets: Map.put(govt.markets, market.name, market))}
    end
  end

  @doc """
  Adds a region (government) to this `govt` and assigns itself as the `government` for that region (parent).

  ## Examples

      iex> {:ok, govt} = %Govt{name: "Test Country"} |> Govt.add_region(%Govt{name: "Test Region"})
      iex> govt
      %Govt{
        name: "Test Country",
        regions: %{"Test Region" =>
          %Govt{
            name: "Test Region",
            government: %Govt{type: :basel2, name: "Test Country"}
          }
        }
      }
  """
  def add_region(%Govt{} = govt, %Govt{} = region) do
    case Map.has_key?(govt.regions, region.name) do
      true ->
        {:error, :regin_name_taken}

      _ ->
        {:ok,
         struct(govt,
           regions: Map.put(govt.regions, region.name, struct(region, government: govt))
         )}
    end
  end

  @doc """
  Adds a treasury bond to this government.

  ## Examples

      iex> loan = %Loan{loan_no: "Test Loan", owner_account_no: "loan", loan_type: "simple", capital: 1, frequency: 1, duration: 1}
      iex> {:ok, govt} = Govt.new(%{type: :basel2}) |> Govt.add_treasury(loan)
      iex> govt
      %Govt{
        treasuries: %{"Test Loan" =>
          %Loan{
            loan_no: "Test Loan",
            owner_account_no: "loan",
            loan_type: "simple",
            capital: 1,
            frequency: 1,
            duration: 1
          }
        }
      }
  """
  def add_treasury(%Govt{} = govt, %Loan{} = treasury) do
    case Map.has_key?(govt.treasuries, treasury.loan_no) do
      true -> {:error, :loan_number_taken}
      _ -> {:ok, struct(govt, treasuries: Map.put(govt.treasuries, treasury.loan_no, treasury))}
    end
  end

  @doc """
  Calculates the governments total debt (outstanding capital).

      iex> {:ok, govt} = Govt.new(%{type: :basel2}) |> Govt.add_treasury(
      ...>   %Loan{
      ...>     loan_no: "Test Loan",
      ...>     owner_account_no: "loan",
      ...>     loan_type: "simple",
      ...>     capital: 1,
      ...>     frequency: 1,
      ...>     duration: 1
      ...>    })
      iex> Govt.treasury_debt_total(govt)
      1
  """
  def treasury_debt_total(%Govt{} = govt) do
    govt.treasuries
    |> Enum.map(fn {_, x} -> Loan.capital_outstanding(x) end)
    |> Enum.sum()
  end
end
