---
title: Contributing
---

If you are you are interested in contributing to Tinkerbell, _Welcome!_ and we are thankful you are here.

Tinkerbell is an open source project made of different components, and a lot of the code is written in Go, but it is not the only way to make a contribution.
We use and rely on a lot of different technologies such as: iPXE, Docker, Prometheus, Kubernetes and much more.

The projects inside Tinkerbell are designed to be as independent as possible, some are ready and others have a long way to go.
In general, deciding where you want to contribute depends on what you are working towards.

The best way to start is to join the [#tinkerbell] channel over on the [CNCF Community Slack] or the [Contributor Mailing list].
You can find more about how we communicate on the [COMMUNICATION page] in the [tinkerbell/.github] repo.

## Contributing to the Codebase

You can find all our projects on [GitHub].
Have a look at issues and pull requests and if you can't figure out anything you want to do, ping us on Slack.

Some advice for getting started is to figure out a way to scope your contribution to a single repository.
This is a good practice because it simplifies development and helps us to avoid breaking changes.

At this current stage we are far from out first stable release, which means that occasionally we will have breaking changes.
For more on our policy about breaking changes, check out the [proposal regarding breaking changes].

## Proposals

Tinkerbell uses a proposals repository over in [tinkerbell/proposals] to share ideas, discuss, and collaborate on Tinkerbell in a public manner.

Proposal workflow is explained in [Proposal 001], where the information required to write your own proposal or to understand the state of a current proposal.

## Triage

The [Community Triage Party call] takes place **every other Tuesday** at **3pm UTC (11am ETC/8am PST)** - join us to learn more about Tinkerbell!

Regularly triaging incoming issues and pull requests is critical to the health of an open-source project.
The triage process ensures that communication flows openly between users and contributors, even as people vacation or move to new projects.
In particular:

- Lower issue response latency encourages users to become contributors
- Lower PR review latency encourages first-time contributors to become regular
- Labeled issues help the community to prioritize work

All community members are welcome and encouraged to join and help us triage Tinkerbell.
It's a great way to learn more about how the project functions, and gain exposure to different parts of the codebase.

### Triage access

Open an issue in the [Tinkerbell .github repo] to request triage access if you do not already have access to add labels to issues.

At the beginning of our Community Triage Party call, we will also ask at the beginning of the call if anyone requires triage access to participate.

### Daily Triage Process

The goal of daily triage is to be the initial point of contact for an incoming issue or pull request.
Anyone can participate on any day of the week!

The dashboard of items requiring a response can be found at the [Daily Triage Dashboard].
Each box of items is defined by a rule and has a listed `Resolution` action.
Once the requested action has been taken, the issue will disappear from the list.

- _Unresponded issues_ need a follow-up by someone who is a member of the Tinkerbell organization
- _Review Ready_ PRs require a code review follow-up
- _Unkinded issues_ are those requiring a label describing the kind of issue.
  In Tinkerbell, we use:
  - `enhancement`, `bug`, `documentation`, `question`, `todo`, `idea`, `epic`

Other labels we use are:

- `Good First Issue` - bug has a proposed solution, can be implemented without further discussion.
- `Help wanted` - if the bug could use help from the open-source community

### Bi-weekly Community Triage Process

The goal of bi-weekly triage is to catch items that may have fallen through the cracks.

The dashboard of items requiring a response can be found at the [Bi-Weekly Triage Dashboard].
Each box of items is defined by a rule and has a listed `Resolution` action.
Once the defined action has been taken, the issue will disappear from the list.

At the beginning of the call, we will ask if anyone requires triage permissions to participate.

- _Stale Pull Requests_ are PRs that appear to be going nowhere.
  If we haven't heard back from the user in 30 days, the PR should be closed with care.
  The author can reopen it when they are ready.

### Prioritization

!! note
These labels have not yet been finalized - but are based on what is used in other CNCF projects.

If the issue is not question, it needs a [priority label]:

- `priority/critical-urgent`: someone's top priority ASAP, such as security issue or issue that causes data loss.
  Rarely used, to be resolved within 5 days.
- `priority/important-soon`: high priority for the team.
  To be resolved within 8 weeks.
- `priority/important-longterm`: a long-term priority.
  To be resolved within a year.
- `priority/backlog`: agreed that this would be good to have, but not yet a priority.
  Consider tagging as `help wanted`
- `priority/awaiting-more-evidence`: may be useful, but there is not yet enough evidence to support inclusion on the backlog.

### Example follow-ups

When a user submits a pull request or issue, it's essential to be respectful of the time the user has invested in opening the issue.
Be kind.

These are some templates that you can use as [Github Saved replies] for easy access during triage.

#### Stale PR with an outstanding comment

> @xx - It appears that this PR is doing the right thing and is very close to being merged! There is only one PR comment to resolve, and the PR will also need to be rebased against the latest code from the main branch.
>
> If we don't hear back within the next two weeks, we will likely close this PR as part of our PR grooming policy. If this happens, you can reopen this PR at any point once the required changes are made.
>
> Thank you for your contribution, and I hope to hear back from you soon!

### Needs more information

> I don't yet have a clear way to replicate this issue. Do you mind adding some additional details? Here is additional information that would be helpful:
>
> - The exact command lines used
> - Logs or command-line output
>
> Thank you for sharing your experience!

#### Closing: Duplicate Issue

> This issue appears to be a duplicate of #X. Do you mind if we move the conversation there?
>
> This way we can centralize the content relating to the issue. If you feel that this issue is not a duplicate, please reopen it using `/reopen`. If you have additional information to share, please add it to the new issue.
>
> Thank you for reporting this!

#### Closing: Lack of Information

If an issue hasn't been active for more than 8 weeks, and the author has been pinged at least once, then it can be closed.

> Hey @author -- hopefully it's OK if I close this - there wasn't enough information to make it actionable, and some time has already passed. If you are able to provide additional details, you add a comment, and we will reopen it.
>
> Here is additional information that may be helpful to us:
>
> \* Whether the issue occurs with the latest Tinkerbell release
>
> \* The exact command-lines used
>
> Thank you for sharing your experience!

#### Closing: Very stale PR

Once a PR is 30 days old and pinged at least twice, it's safe to close it:

> Closing this PR as stale. Please reopen this PR when you are ready to retake a look at it. Thank you for your contribution!

[bi-weekly triage dashboard]: https://triage.meyu.us/s/weekly
[community triage party call]: https://equinix.zoom.us/j/96016156757?pwd=nzzkczzmbfdvsm9ubhnzahryngdvdz09
[daily triage dashboard]: https://triage.meyu.us/s/daily
[github saved replies]: https://docs.github.com/en/get-started/writing-on-github/working-with-saved-replies/using-saved-replies
[priority label]: https://github.com/kubernetes/community/blob/master/contributors/guide/issue-triage.md#define-priority
[tinkerbell .github repo]: https://github.com/tinkerbell/.github/issues


## Terms and Stewardship

The [tinkerbell/.github] repository contains all the information relating to the code of conduct.

- [Contributor Covenant Code of Conduct]

The [tinkerbell/org] repository contains all the information relating to the license and documents on project owner responsibilities and maintainer information.

- [License]
- [Maintainers]
- [Owners]

[cncf community slack]: https://slack.cncf.io/
[communication page]: https://github.com/tinkerbell/org/blob/main/COMMUNICATION.md
[contributor covenant code of conduct]: https://github.com/tinkerbell/.github/blob/main/CODE_OF_CONDUCT.md
[contributor mailing list]: https://github.com/tinkerbell/org/blob/main/COMMUNICATION.md#contributors-mailing-list
[github]: https://github.com/tinkerbell
[license]: https://github.com/tinkerbell/org/blob/main/LICENSE
[maintainers]: https://github.com/tinkerbell/org/blob/main/MAINTAINERS.md
[owners]: https://github.com/tinkerbell/org/blob/main/OWNERS.md
[proposal 001]: https://github.com/tinkerbell/proposals/tree/main/proposals/0001
[proposal regarding breaking changes]: https://github.com/tinkerbell/proposals/blob/main/proposals/0011/README.md
[tinkerbell/.github]: https://github.com/tinkerbell/.github
[#tinkerbell]: https://app.slack.com/client/T08PSQ7BQ/C01SRB41GMT
[tinkerbell/org]: https://github.com/tinkerbell/org
[tinkerbell/proposals]: https://github.com/tinkerbell/proposals
