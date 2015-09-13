defmodule Obelisk.Post do
  def prepare(md_file, compiled_layout, compiled_post) do
    Obelisk.Document.prepare(
      "./posts/#{md_file}",
      compiled_layout,
      compiled_post
    )
  end

  def write(post) do
    File.write(
      post.path,
      post.document
    )

    post
  end

  def title(md) do
    String.slice(md, 11, 1000)
    |> String.replace("-", " ")
    |> String.replace(".markdown", "")
    |> String.capitalize
  end

  def list do
    File.ls!("./posts")
    |> Enum.sort
    |> Enum.reverse
  end

  def create(title) do
    File.write(filename_from_title(title), Obelisk.Templates.post(title))
  end

  def filename_from_title(title) do
    datepart = Chronos.today |> Chronos.Formatter.strftime("%Y-%0m-%0d")
    titlepart = String.downcase(title) |> String.replace(" ", "-")
    "./posts/#{datepart}-#{titlepart}.md"
  end
end
