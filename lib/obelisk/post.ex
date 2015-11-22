defmodule Obelisk.Post do
  def prepare(md_file, compiled_layout, compiled_post) do
    Obelisk.Document.prepare(
      "./posts/#{md_file}",
      compiled_layout,
      compiled_post
    )
  end

  def title(md) do
    String.slice(md, 11, 1000)
    |> String.replace("-", " ")
    |> String.replace(".md", "")
    |> String.capitalize
  end

  def filename_from_title(title) do
    datepart = Obelisk.Date.today
    titlepart = Obelisk.Document.dashify(title)
    "./posts/#{datepart}-#{titlepart}.md"
  end

  def list do
    Obelisk.Document.list("./posts")
    |> Enum.sort
    |> Enum.reverse
  end

  def create(title) do
    Obelisk.Template.create(title, Post)
  end

  def filename_from_title(title) do
    "./posts/#{Obelisk.Date.today}-#{Obelisk.Document.dashify(title)}.md"
  end
end
