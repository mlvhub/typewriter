# Typewriter

An extremely simple static site generator, with a few conventions.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add typewriter to your list of dependencies in `mix.exs`:

        def deps do
          [{:typewriter, "~> 0.0.1"}]
        end

  2. Ensure typewriter is started before your application:

        def application do
          [applications: [:typewriter]]
        end

## Post Frontmatter Properties
TODO

## config.yaml

This file is where you specify your project specific configuration. The following parameters are supported:

### tags
All of the tags supported by your project.
### post_template
The template used to display a simple post. It receives a `post` object containing all of its information.
### posts_template
The template used to display all of the posts. It receives a `posts` list, containing all of the project's posts.
### layout_template
A default layout file to use throughout the EEx files evaluation.
### posts_dir
The directory where your posts are located.

## TODO Checklist
- [ ] Add moduletags to every module
- [ ] Simplify the FileSystem module
- [ ] Define defaults for the config file.
- [ ] Test the file system related logic.
- [X] Add an option in the config file to be able to ignore files and folders.
- [ ] Report an error when there is an empty property in a post. Issue: The tasks just timeout otherwise.
- [X] Wipe out every saved post before or after every build. Issue: When deleting a post file, the post still remains stored in the post agent in subsequent builds.
- [ ] Create an executable of the builder for simple usage with escript. Note: Already added escript, but the generation gives an error related to EEx, gotta find out what's going on.
- [ ] Finish documenting the library's usage
- [ ] Make sure the layout functionality is working fine. Feature: If the layout property is not specified in the post's frontmatter, the config one should be used.
- [ ] Expand the author support, in order to have a full description, social links, and a picture.
