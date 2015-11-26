defmodule Obelisk.RSS do
  def build_feed(posts) do
    config = Obelisk.Config.config
    channel = RSS.channel(
      Map.get(config, :name),
      Map.get(config, :url),
      Map.get(config, :description),
      Obelisk.Date.now,
      Map.get(config, :language, "en-us")
    )

    items = compile_rss(posts)
    feed = RSS.feed(channel, items)
    File.write("./build/blog.rss", feed)
  end

  defp compile_rss(posts) do
    config = Obelisk.Config.config
    base_url = Map.get(config, :url, "")

    posts
    |> Enum.map(&get_item_info(&1, base_url))
    |> Enum.map(&build_item/1)
  end

  defp build_item({title, description, filename, url}) do
    RSS.item(
      title,
      description,
      String.slice(filename, 0, 10),
      url,
      url
    )
  end

  defp get_item_info(item, base_url) do
    filename = Path.basename(item.path)

    {
      Map.get(item.frontmatter, :title),
      Map.get(item.frontmatter, :description),
      filename,
      base_url <> "/" <> filename
    }
  end
end
