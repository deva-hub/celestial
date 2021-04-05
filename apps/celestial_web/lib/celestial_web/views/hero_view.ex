defmodule CelestialWeb.CharacterView do
  use CelestialWeb, :view
  alias CelestialWeb.CharacterView

  def render("index.json", %{characters: characters}) do
    %{data: render_many(characters, CharacterView, "character.json")}
  end

  def render("show.json", %{character: character}) do
    %{data: render_one(character, CharacterView, "character.json")}
  end

  def render("character.json", %{character: character}) do
    %{
      id: character.id,
      name: character.name,
      class: character.class,
      hair_color: character.hair_color,
      hair_style: character.hair_style,
      level: character.level,
      job_level: character.job_level,
      hero_level: character.hero_level,
      xp: character.xp,
      job_xp: character.job_xp,
      hero_xp: character.hero_xp
    }
  end
end
