![][stability badge]

# Tinkerbell Docs

This is the source repo for the Tinkerbell docs.
They are build using static-site generator [MkDocs] and using the [mkdocs-material] theme, then served by netlify to [docs.tinkerbell.org].

## Development

This repository uses [MkDocs] as the documentation framework and [Poetry] to manage it's dependencies.
Make sure to have [Python] installed.
If you wish, you can install `mkdocs` and other dependencies to build the docs locally by running the following commands

```sh
poetry install
poetry run mkdocs serve
```

If you wish to work within a development environment you can use Poetry's virtualenv environment:

```sh
$ poetry install
$ poetry shell
```

To deactivate the virtual environment, simply run `deactivate`.

## Contributing to the Tinkerbell Docs

All the markdown source files for the documentation are in the `docs/` folder.
Find the file that you want to update and edit it.
Then open a Pull Request with your changes.
Make sure that the build passes, and take a look at the netlify preview to see your changes staged on the website.

### Page metadata

Currently the metadata for the page is yaml formatted, with two fields: title and date.
If you edit a doc, update the date to when you made your edits.

### Adding Images

All the images for the docs are in the `images/` folder.
To pull the image into your doc, use a relative link to the image file.
Example:

```markdown
![Architecture]
```

### Adding a page

If you would like to submit a new page to the documentation, be sure to add it to the `nav` section in mkdocs.yml.
This will ensure that the page appears in the table of contents.

[architecture]: /images/architecture-diagram.png
[docs.tinkerbell.org]: https://docs.tinkerbell.org/
[mkdocs]: https://www.mkdocs.org/
[mkdocs-material]: https://squidfunk.github.io/mkdocs-material/
[poetry]: https://python-poetry.org/
[python]: https://www.python.org/downloads/
[stability badge]: https://img.shields.io/badge/Stability-Experimental-red.svg
