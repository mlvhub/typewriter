[![Build Status](https://travis-ci.org/mlvhub/typewriter.svg?branch=master)](https://travis-ci.org/mlvhub/typewriter) [![Coverage Status](https://coveralls.io/repos/github/mlvhub/typewriter/badge.svg?branch=master)](https://coveralls.io/github/mlvhub/typewriter?branch=master)

# Typewriter

An extremely simple static site generator, with a few conventions.

## Installation

If you only want to run the script without much hassle, just run:

        mix escript.install https://github.com/mlvhub/typewriter/raw/master/typewriter

Otherwise, you can clone and setup the project yourself, then run:

        mix escript.build

To generate the Typewriter script.

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add typewriter to your list of dependencies in `mix.exs`:

        def deps do
          [{:typewriter, "~> 0.0.1"}]
        end

  2. Ensure typewriter is started before your application:

        def application do
          [applications: [:typewriter]]
        end

## Usage

### Using the Script

`typewriter $PROJECT_PATH`

## Post Frontmatter Properties
TODO

## config.yaml

This file is where you specify your project specific configuration. This file **must** be in the root of your project. The following parameters are supported:

### tags
All of the tags supported by your project.
**Default:** `[]`
### post_template
The template used to display a simple post. It receives a `post` object containing all of its information.
**Default:** `"templates/post.html.eex"`
### posts_template
The template used to display all of the posts, generally used to list all your posts. It receives a `posts` list, containing all of the project's posts.
**Default:** `"templates/posts.html.eex"`
### layout_template
A default layout file to use throughout the EEx files evaluation.
**Default:** `"templates/layout.html.eex"`
### posts_dir
The directory where your posts are located.
**Default:** `"posts"`
### ignored_dirs
A list of directories you want to be ignored.
**Default:** `"[]"`
### ignored_files
A list of files you want to be ignored.
**Default:** `"[]"`

## TODO Checklist
- [ ] Add a Logger module to improve visiblity of what's being done and show errors.
- [ ] Improve the CLI Usability.
- [ ] Add moduletags to every module.
- [ ] Finish documenting the library's usage.
- [ ] Make sure the layout functionality is working fine. Feature: If the layout property is not specified in the post's frontmatter, the config one should be used.
- [ ] Expand the author support, in order to have a full description, social links, and a picture.
