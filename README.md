obelisk
=======

Static Site Generator written in Elixir.

## Creating a new obelisk project

To create a new obelisk project, we use `mix`

    $ mix new blog

We then modify our dependencies within `mix.exs` to include obelisk, as well as the Erlang
library yamerl.

    defp deps do
      [{:obelisk, github: "ckampfe/obelisk"},
       {:yamerl, github: "yakaz/yamerl"}]
    end

Next we need to download obelisk and compile it

    $ mix deps.get
    $ mix deps.compile

Initialize a project with:

    $ mix obelisk.init

Build the project with:

    $ mix obelisk.build

Once our project is built, we can check it out by starting the server.

    $ mix obelisk.server

Now browse to `http://localhost:4000`

## Structure

    /
    /site.yml
    /theme/
    /theme/assets/
    /theme/assets/css/
    /theme/assets/js/
    /theme/assets/img/
    /theme/layout
    /posts/
    /drafts/
    /pages/

## Creating a new post

Obelisk expects blog post content to be located in the `/posts` directory, with filenames using the format `YYYY-mm-dd-post-title.md`. Any file matching this pattern will be processed and built into the `/build` directory.

You can use the `post` command to quickly create a new post with todays date, although creating the file manually will also work.

    $ mix obelisk.post "New obelisk feature"

## Creating a draft

Drafts are intended to hold works in progress, and won't be compiled into the `/build` directory when running the build command. Create one like so:

    $ mix obelisk.draft "Still working on this"

## Creating a page

Pages are non-temporal content, such as an about page, which are built in the same way as posts, but not included in the site's RSS feed. These files can have any name, and need not start with a date stamp. For example `./pages/about-me.md` is a fine filename to use.

    $ mix obelisk.page "About Me"

## Front matter

Like other static site generators, posts should include front matter at the top of each file.

    ---
    layout: post
    title: My brand new blog post
    created: 2015-10-12
    ---

    Post content goes here

Now within the `post.eex` template, which we'll talk about a bit further down, we can access these value like this:

    <div class="post">
      <h1><%= @frontmatter.title %></h1>
      <h3><%= @frontmatter.created %></h3>
      Body text here!
    </div>

## The asset pipeline

The asset pipeline is extremely simple at this stage. Anything under your `/theme/assets` directory is copied to `/build/assets` when the `mix obelisk.build` task is run.

## Layouts

Everything under the `/theme/layout` directory is used to build up your site.

`post.eex` (or similar) is the template which wraps blog post content. The `@content` variable is used within this template to specify the location that the converted markdown content is injected.

`page.eex` (or similar) is the template which wraps page content. The `@content` variable is used within this template to specify the location that the converted markdown content is injected.

`index.eex` (or similar) is the template which wraps your index page, which for now is intented to hold the list of blog posts. This template provides 3 variables. Similar to the post template, the index template provides `@content`, which is the list of blog posts (at this stage as html links). The other two variables, `@next` and `@prev` provide links to move between index pages. Each index page contains 10 blog posts, ordered from newest to oldest. The pages are created with the following pattern:

    index.html
    index2.html
    ...
    index8.html

`layout.eex` (or similar) is the template which wraps every page. This is the template that should include your `<html>`, `<head>` and `<body>` tags. This template provides 3 variables also. Again, the `@content` variable is provided, which specifies where to inject the content from whichever page is being built. Additionally, the `@css` and `@js` variables are provided, which include the html markdown for all of the files (not folders) directly under `/build/assets/css` and `/build/assets/js` respectively. These files are written to the page in alphabetical order, so if a particual order is required (i.e reset.css first), then the current solution is to rename the files to match the order in which they should be imported:

    /assets/css/0-reset.css
    /assets/css/1-layout.css
    /assets/css/2-style.css
