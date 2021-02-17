---
title: Welcome
date: 2021-02-02
---

If you are you are interested in contributing to Tinkerbell, _Welcome!_, and we are thankful you are here.

Tinkerbell is an open source project made of different components, a lot of the code is written in Go but it is not the only way to make a contribution obviously we use and rely on a lot of different technologies such as: iPXE, Docker, Promethues, Kubernetes, Golang and much more.

The projects inside Tinkerbell are designed to be as independent as possible, some are ready, others have a long way to go, but in general, deciding where you want to contribute depends on what you are working towards.

I am sure you will be able to find what you are looking for, the best way to start here is to join Slack if you want or the Contributor Mailing list, you can find more about this topic in the ["COMMUNICATION page"](https://github.com/tinkerbell/.github/blob/master/COMMUNICATION.md#contributors-mailing-list).

## Contributing to the Codebase

You can find all our projects on [GitHub](https://github.com/tinkerbell). Have a look at issues and pull requests and if you can't figure out anything you want to do, ping us on Slack.

Currently we are doing a lot of work around:

* CI/CD not only for our projects but also for the reusable actions we ship to [ArtifactHub](https://artifacthub.io/packages/search?page=1&org=tinkerbell-community), you can find them to [tinkerbell/hub](https://github.com/tinkerbell/hub).
* We are refactoring our Go binaries to be friendly and flexible using Cobra, Viber.
* We have to write an end to end test framework that we can use to test the entire project in integration
* Documentation, documentation, documentation!

Some advice for getting started is to figure out a way to scope your contribution to a single repository. 

This is a good practice because it simplifies the development but it also forces us to avoid breaking changes. 

At this current stage we are far from out first stable release, it means that it is a perfect time to actually have breaking changes, you can read more about [this topic at the proposal](https://github.com/tinkerbell/proposals/blob/master/proposals/0011/README.md).

## Proposals

Tinkerbell uses a proposals repository over in [`tinkerbell/proposals`](https://github.com/tinkerbell/proposals).

Proposal workflow is explained in proposal 001. 

## Contributing for Other Contributors

We think every developer has their own tool chain and mindset when it comes to development environment and we can't have one that works for every developer.

The idea for the Contributors section of the docs is to collect and share the various ways we develop Tinkerbell in order to share practical tips or to serve as inspiration for contributing to the project.

If you want to contribute how you spin up and hack on the various pieces of Tinkerbell components, or lessons you have learned while doing so, please write up and submit a PR to the [`tinkerbell/docs`](https://github.com/tinkerbell/tinkerbell-docs) repository. We are collecting this info in the Contributors section (this section) of the docs.

## Terms and Stewardship

The [`tinkerbell/.github`](https://github.com/tinkerbell/.github) repository contains all the information relating to the license and code of conduct.

- [Contributor Covenant Code of Conduct](https://github.com/tinkerbell/.github/blob/master/CODE_OF_CONDUCT.md)
- [License](https://github.com/tinkerbell/.github/blob/master/LICENSE)

It also contains documents on project owner responsibilities and maintainers' information.

- [Owners](https://github.com/tinkerbell/.github/blob/master/OWNERS.md)
- [Maintainers](https://github.com/tinkerbell/.github/blob/master/MAINTAINERS.md)
