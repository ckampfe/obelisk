defmodule Obelisk.Template do
  @moduledoc """
  This module contains various templates for building initial files
  for obelisk sites.
  """

  defmacro __before_compile__(_env) do
    for template_kind <- ["layout", "index", "post", "page"] do
      fn_name = String.to_atom("compile_" <> template_kind)

      quote do
        def unquote(fn_name)() do
          EEx.compile_file("./theme/layout/#{unquote(template_kind)}.eex")
        end
      end
    end
  end

  def create(title, kind) do
    draft_content =
      apply(
        Obelisk.Template,
        kind,
        [title]
      )

    File.write!(
      Obelisk.FS.title_to_filename(title, kind),
      draft_content
    )
  end

  def draft(title), do: post(title)

  def post(title) do
    """
    ---
    title: #{title}
    description: A new blog post
    created: #{Obelisk.Date.now}
    ---

    Welcome to your brand new obelisk post.
    """
  end

  def page(title) do
    """
    ---
    title: #{title}
    description: A new page
    ---

    Welcome to your brand new page.
    """
  end

  def config do
    """
    ---
    name: A brand new static site
    url: http://my.blog.url
    description: This is my blog about things
    language: en-us
    posts_per_page: 10
    smartquotes: false
    """
  end

  def post_template do
  """
  <div id="post">
    <h2>
      <a href="<%= @filename %>"><%= @frontmatter.title %></a>
    </h2>
    <%= @content %>
  </div>
  """
  end

  def page_template do
  """
  <div id="page">
    <%= @frontmatter.title %>
    <hr />
    <%= @content %>
  </div>
  """
  end

  def layout do
  """
  <!DOCTYPE html>
  <html>
    <head>
      <title>
        <%= if @title do %>
          <%= @title <> " - " <> @site_name %>
        <% else %>
          <%= @site_name %>
        <% end %>
      </title>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
      <%= @css %>
      <%= @js %>
    </head>

    <body>
      <div class="container">
        <h1>obelisk</h1>
        <%= @content %>
      </div>
    </body>
  </html>
  """
  end

  def index do
    """
    <div class="index">
      <%= Enum.map @content, fn(post) ->
        \"\"\"
        #\{Path.basename(post.path)}
        <hr />
        \"\"\"
      end %>
      <%= @prev %>
      <%= @next %>
    </div>
    """
  end

  def base_css do
    """
    body {
      margin: 0;
      padding: 0;
    }

    .container {
      width: 980px;
      margin: 0 auto;
    }
    """
  end
end
