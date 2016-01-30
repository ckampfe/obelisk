defmodule Obelisk.FS do
  def html_filename(page_num) do
    Obelisk.Config.config
    |> Map.get(:blog_index)
    |> with_index_num(page_num)
    |> build_index_path
  end

  def with_build_path(filename) do
    Path.join([".", "build", filename])
  end

  def md_to_html_extension(path) do
    path
    |> Path.basename(".md")
    |> (&(&1 <> ".html")).()
  end

  def list(kind) do
    path_for(kind) |> File.ls!
  end

  def filename_to_title(md) do
    String.slice(md, 11, 1000)
    |> String.replace("-", " ")
    |> String.replace(".md", "")
    |> String.capitalize
  end

  def title_to_filename(title, kind) do
    date = Obelisk.Date.today

    combined =
      case kind do
        :post -> date <> "-" <> title
        :page -> title
        :draft -> date <> "-" <> title
      end

    Path.join(to_string(kind) <> "s", "#{Obelisk.Compiler.dashify(combined)}.md")
  end

  def path_for(kind) do
    Path.join(".", to_string(kind) <> "s")
  end

  def last_page?([]), do: true
  def last_page?(_),  do: false

  def with_index_num(nil, 1), do: "index.html"
  def with_index_num(nil, page_num), do: "index#{page_num}.html"
  def with_index_num(index_filename, 1), do: index_filename
  def with_index_num(index_filename, page_num) do
    extension = Path.extname(index_filename)
    path = Path.rootname(index_filename, extension)
    path <> to_string(page_num) <> extension
  end

  def make_path(nil), do: nil
  def make_path(path) do
    case Path.dirname(path) do
      "."     -> nil
      subpath -> Path.join("./build", subpath) |> File.mkdir_p
    end
  end

  defp build_index_path(path), do: Path.join([".", "build", path])

  def built_asset_files(kind) do
    File.ls!("./build/assets/#{kind}")
    |> Enum.sort
    |> Enum.map(&("assets/#{kind}/#{&1}"))
    |> Enum.filter(&(!File.dir?("./build/#{&1}")))
  end

  def copy_dir(from, to), do: File.cp_r(from, to)
end
