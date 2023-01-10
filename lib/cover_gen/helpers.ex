defmodule CoverGen.Helpers do
  alias Litcovers.Character

  def create_prompt(idea_prompt, style_prompt, gender, :subject) do
    "mdjrny-v4 style #{random_portrait()}, #{idea_prompt}, #{get_character_prompt(gender)}, #{style_prompt}"
  end

  def create_prompt(idea_prompt, style_prompt, _gender, :object) do
    "#{idea_prompt}, #{style_prompt}"
  end

  defp random_portrait do
    ["Side profile portrait", "Close up portrait", "Symmetrical face portrait"] |> Enum.random()
  end

  def get_celeb_name(gender, is_famous) do
    case Character.get_random_celeb(gender, is_famous) do
      nil ->
        ""

      celeb ->
        celeb.name
    end
  end

  def get_character_prompt(gender) do
    famous_celeb = get_celeb_name(gender, true)
    not_famous_celeb = get_celeb_name(gender, false)

    "#{not_famous_celeb} as #{famous_celeb}"
  end
end
