---
title: Welcome
date: 2021-02-02
---

If you are you are interested in contributing to Tinkerbell, _Welcome!_ and we are thankful you are here.

Tinkerbell is an open source project made of different components, and a lot of the code is written in Go, but it is not the only way to make a contribution.
We use and rely on a lot of different technologies such as: iPXE, Docker, Prometheus, Kubernetes and much more.

The projects inside Tinkerbell are designed to be as independent as possible, some are ready and others have a long way to go.
In general, deciding where you want to contribute depends on what you are working towards.

The best way to start is to join the `#tinkerbell` channel over on the [CNCF Slack] or the [Contributor Mailing list].
You can find more about how we communicate on the [COMMUNICATION page] in the [tinkerbell/.github] repo.

## Contributing to the Codebase

You can find all our projects on [GitHub].
Have a look at issues and pull requests and if you can't figure out anything you want to do, ping us on Slack.

Currently, we are doing a lot of work around:

- CI/CD - not only for our projects but also for the reusable actions we ship to [ArtifactHub].
  You can find them in the [tinkerbell/hub] repo.
- We are refactoring our Go binaries to be friendly and flexible using Cobra and Viper.
- We have to write an end-to-end testing framework that we can use to run integration tests on the entire project.
- Documentation, documentation, documentation!

Some advice for getting started is to figure out a way to scope your contribution to a single repository.
This is a good practice because it simplifies development and helps us to avoid breaking changes.

At this current stage we are far from out first stable release, which means that occasionally we will have breaking changes.
For more on our policy about breaking changes, check out the [proposal regarding breaking changes].

## Proposals

Tinkerbell uses a proposals repository over in [tinkerbell/proposals] to share ideas, discuss, and collaborate on Tinkerbell in a public manner.

Proposal workflow is explained in [Proposal 001], where the information required to write your own proposal or to understand the state of a current proposal.

## Contributing for Other Contributors

We think every developer has their own tool chain and mindset when it comes to development environment and we can't have one that works for every developer.

The idea for the Contributors section of the docs is to collect and share the various ways we develop Tinkerbell in order to share practical tips or to serve as inspiration for contributing to the project.

If you want to contribute how you spin up and hack on the various pieces of Tinkerbell components, or lessons you have learned while doing so, please write up and submit a PR to the [tinkerbell/docs] repository.
We are collecting this info in the Contributors section (this section) of the docs.

## Terms and Stewardship

The [tinkerbell/.github] repository contains all the information relating to the license and code of conduct.

- [Contributor Covenant Code of Conduct]
- [License]

It also contains documents on project owner responsibilities and maintainers' information.

- [Owners]
- [Maintainers]

[artifacthub]: https://artifacthub.io/packages/search?page=1&org=tinkerbell-community
[cncf slack]: https://slack.cncf.org/
[communication page]: https://github.com/tinkerbell/.github/blob/master/COMMUNICATION.md
[contributor covenant code of conduct]: https://github.com/tinkerbell/.github/blob/main/CODE_OF_CONDUCT.md
[contributor mailing list]: https://github.com/tinkerbell/.github/blob/main/COMMUNICATION.md#contributors-mailing-list
[github]: https://github.com/tinkerbell
[license]: https://github.com/tinkerbell/.github/blob/main/LICENSE
[maintainers]: https://github.com/tinkerbell/.github/blob/main/MAINTAINERS.md
[owners]: https://github.com/tinkerbell/.github/blob/main/OWNERS.md
[proposal 001]: https://github.com/tinkerbell/proposals/tree/main/proposals/0001
[proposal regarding breaking changes]: https://github.com/tinkerbell/proposals/blob/main/proposals/0011/README.md
[tinkerbell/docs]: https://github.com/tinkerbell/tinkerbell-docs
[tinkerbell/.github]: https://github.com/tinkerbell/.github
[tinkerbell/hub]: https://github.com/tinkerbell/hub
[tinkerbell/proposals]: https://github.com/tinkerbell/proposals
