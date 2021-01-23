defmodule CelestialWeb.HeroView do
  use CelestialWeb, :view
  alias CelestialWeb.HeroView

  def render("index.json", %{heroes: heroes}) do
    %{data: render_many(heroes, HeroView, "hero.json")}
  end

  def render("show.json", %{hero: hero}) do
    %{data: render_one(hero, HeroView, "hero.json")}
  end

  def render("hero.json", %{hero: hero}) do
    %{
      id: hero.id,
      name: hero.name,
      class: hero.class,
      hair_color: hero.hair_color,
      hair_style: hero.hair_style,
      level: hero.level,
      job_level: hero.job_level,
      hero_level: hero.hero_level,
      xp: hero.xp,
      job_xp: hero.job_xp,
      hero_xp: hero.hero_xp
    }
  end
end
