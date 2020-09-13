# tinkerbell-docs
Repo for initial Tinkerbell docs to MkDocs

To [install MkDocs](https://www.mkdocs.org/#installation):

You need to have Python installed.

Run `pip install mkdocs`

Next you'll need to install the [MkDocs Material](https://github.com/squidfunk/mkdocs-material) theme, run `pip install mkdocs-material`

Then you'll need to enable versioning. To do that:
Install the plugin using pip:

`pip install mkdocs-versioning`

Next, add the following lines to your mkdocs.yml:

`plugins:
  - search
  - mkdocs-versioning:
      version: 0.3.0`

Since we have no plugins entry in your config file yet, you'll likely also want to add the search plugin. MkDocs enables it by default if there is no plugins entry set.

Everything should be ready to go, just run `mkdocs serve`
