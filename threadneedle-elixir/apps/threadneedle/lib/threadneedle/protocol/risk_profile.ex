defprotocol Threadneedle.Protocol.RiskProfile do
  @doc "Determines the risk factor for loans given a loan type"
  def loan_risk_weighting(profile, loan)

  @doc "Determines the capital multiplier for banks"
  def capital_multiplier(profile, government)
end

defimpl Threadneedle.Protocol.RiskProfile, for: Any do
  def loan_risk_weighting(_, _), do: 0.0
  def capital_multiplier(_, _), do: 0.0
end
