![](https://img.shields.io/badge/Stability-Experimental-red.svg)

# Tinkerbell Docs

This is the source repo for the Tinkerbell docs. They are build using static-site generator [`mkdocs`](https://www.mkdocs.org/) and using the [`mkdocs-material`](https://squidfunk.github.io/mkdocs-material/) theme, then served by netlify to [docs.tinkerbell.org](https://docs.tinkerbell.org/). 

## Development

This repository uses [MkDocs](https://www.mkdocs.org/) as the documentation framework. If you wish, you can install `mkdocs` and `mkdocs-material` to build the docs locally. Make sure to have [Python installed](https://www.python.org/downloads/).

### Virtual environments

Before installing the dependencies of this project, you may decide create a virtual environment. This will prevent you from polluting your global environment with a lot of packages and ensure that you don't get version conflicts between different repositories.

If you dont't want to install additional dependencies, you can use the following commands to create and activate a virtual environment:

```bash
$ python -m venv .venv
$ source .venv/bin/activate
```

_Note: In some cases the above command may fail, because the `venv` module is not installed. You may then install it via `sudo apt install python3-venv`._

If you frequently work with Python and you don't mind installing and configuring a new tool, you should have a look at [virtualenvwrapper](https://virtualenvwrapper.readthedocs.io/en/latest/). With `virtualenvwrapper` you can use the following commands to create and activate your virtual environment:

```bash
$ mkvirtualenv tinkerbell-docs
$ workon tinkerbell-docs
```

To deactivate the virtual environment, regardless of which tool you are using, simply run `deactivate`.

### MkDocs

If you are using a virtual environment you can simply install all dependencies by running `pip install -r requirements.txt`.

To [install `mkdocs`](https://www.mkdocs.org/#installation):

`pip install mkdocs`

Next you'll need to [install the `mkdocs-material` theme](https://squidfunk.github.io/mkdocs-material/getting-started/#installation):

`pip install mkdocs-material`

To build locally, clone the repo and from `tinkerbell-docs`, run:

`mkdocs serve`

## Contributing to the Tinkerbell Docs

All the markdown source files for the documentation are in the `docs/` folder. Find the file that you want to update and edit it. Then open a Pull Request with your changes. Make sure that the build passes, and take a look at the netlify preview to see your changes staged on the website.

### Page metadata

Currently the metadata for the page is yaml formatted, with two fields: title and date. If you edit a doc, update the date to when you made your edits. 

### Adding Images

All the images for the docs are in the `images/` folder. To pull the image into your doc, use a relative link to the image file. Example:

```
![Architecture](/images/architecture-diagram.png)
```

### Adding a page

If you would like to submit a new page to the documentation, be sure to add it to the `nav` section in mkdocs.yml. This will ensure that the page appears in the table of contents.