defmodule Obelisk.Site do
  def initialize do
    create_default_theme
    create_content_dirs
    Obelisk.Post.create("Welcome to Obelisk")
    File.write './site.yml', Obelisk.Template.config
  end

  def clean do
    File.rm_rf "./build"
    File.mkdir "./build"
  end

  def create_default_theme do
    File.mkdir "./theme"
    File.mkdir "./theme"
    create_assets_dirs
    create_layout_dirs
  end

  defp create_assets_dirs do
    File.mkdir "./theme/assets"
    File.mkdir "./theme/assets/css"
    File.mkdir "./theme/assets/js"
    File.mkdir "./theme/assets/img"
    File.write "./theme/assets/css/base.css", Obelisk.Template.base_css
  end

  defp create_content_dirs do
    File.mkdir "./posts"
    File.mkdir "./drafts"
    File.mkdir "./pages"
  end

  defp create_layout_dirs do
    File.mkdir "./theme/layout"
    File.write "./theme/layout/post.eex", Obelisk.Template.post_template
    File.write "./theme/layout/layout.eex", Obelisk.Template.layout
    File.write "./theme/layout/index.eex", Obelisk.Template.index
    File.write "./theme/layout/page.eex", Obelisk.Template.page_template
  end
end
