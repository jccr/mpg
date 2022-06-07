defmodule Mpg.Game do
  def create() do
    Nanoid.generate(4, "23456789ABCDEFGHJKMNPQRSTUVWXYZ")
  end
end
