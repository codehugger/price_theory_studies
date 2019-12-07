defmodule Threadneedle.Core.BaselRiskProfile do
  alias Threadneedle.Core.{Loan, Government}

  @loan_risk_types ~w(construction mortgage government ibl)a
  @loan_risk_matrix %{construction: 0.25, mortgage: 0.5, government: 1.0, ibl: 1.0}

  def loan_risk_weighting(_profile, %Loan{}), do: 1.0

  def loan_risk_weighting(_profile, %Loan{risk_type: risk_type})
      when risk_type in @loan_risk_types do
    @loan_risk_matrix[risk_type]
  end

  def capital_multiplier(_profile, %Government{} = gov), do: gov.capital_multiplier
end

alias Threadneedle.Protocol.RiskProfile
alias Threadneedle.Core.BaselRiskProfile

defimpl RiskProfile, for: BaselRiskProfile do
  def loan_risk_weighting(profile, loan), do: BaselRiskProfile.loan_risk_weighting(profile, loan)
  def capital_multiplier(profile, gov), do: BaselRiskProfile.capital_multiplier(profile, gov)
end
