defmodule Obelisk.Draft do
  def compile(md_file) do
    Obelisk.Document.compile "./drafts/#{md_file}", Obelisk.Layout.post
  end

  def title(md) do
    String.slice(md, 11, 1000)
    |> String.replace("-", " ")
    |> String.replace(".md", "")
    |> String.capitalize
  end

  def filename_from_title(title) do
    titlepart = Obelisk.Document.dashify(title)
    "./drafts/#{Obelisk.Date.today}-#{titlepart}.md"
  end

  def create(title) do
    Obelisk.Template.create(title, Draft)
  end
end
