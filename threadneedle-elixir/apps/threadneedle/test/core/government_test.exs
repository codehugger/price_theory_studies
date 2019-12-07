defmodule GovernmentTest do
  use ExUnit.Case

  alias Threadneedle.Core.Government, as: Govt
  alias Threadneedle.Core.{Bank, Factory, Market, Loan, Person}

  doctest Threadneedle.Core.Government
end
