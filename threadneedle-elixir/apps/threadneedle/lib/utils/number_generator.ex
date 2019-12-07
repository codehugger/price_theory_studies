defmodule NumberGenerator do
  use Puid, bits: 32, chars: "ABCDEF1234567890"

  def generate(opts) when is_list(opts) or is_map(opts) do
    "#{opts[:prefix]}#{generate()}#{opts[:postfix]}"
  end
end
