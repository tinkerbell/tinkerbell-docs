---
title: Triage
date: 2021-08-24
---

!!! note
The [Community Triage Party call](https://equinix.zoom.us/j/96016156757?pwd=NzZkczZMbFdvSm9ubHNzaHRYNGdvdz09) takes place **every other Tuesday** at **3pm UTC (11am ETC/8am PST)** - join us to learn more about Tinkerbell!

## Summary

Regularly triaging incoming issues and pull requests is critical to the health of an open-source project. The triage process ensures that communication flows openly between users and contributors, even as people vacation or move to new projects. In particular:

- Lower issue response latency encourages users to become contributors
- Lower PR review latency encourages first-time contributors to become regular
- Labeled issues help the community to prioritize work

All community members are welcome and encouraged to join and help us triage Tinkerbell. It's a great way to learn more about how the project functions, and
gain exposure to different parts of the codebase.

## Triage access

Open an issue in the [Tinkerbell .github repo](https://github.com/tinkerbell/.github/issues) to request triage access if you do not already have access to add labels to issues.

At the beginning of our Community Triage Party call, we will also ask at the beginning of the call if anyone requires triage access to participate.

## Daily Triage Process

The goal of daily triage is to be the initial point of contact for an incoming issue or pull request. Anyone can participate on any day of the week!

The dashboard of items requiring a response can be found at the [Daily Triage Dashboard](http://triage.meyu.us:32374/s/daily). Each box of items
is defined by a rule and has a listed `Resolution` action. Once the requested action has been taken, the issue will disappear from the list.

- _Unresponded issues_ need a follow-up by someone who is a member of the Tinkerbell organization
- _Review Ready_ PRs require a code review follow-up
- _Unkinded issues_ are those requiring a label describing the kind of issue. In Tinkerbell, we use:
  - `enhancement`, `bug`, `documentation`, `question`, `todo`, `idea`, `epic`

Other labels we use are:

- `Good First Issue` - bug has a proposed solution, can be implemented without further discussion.
- `Help wanted` - if the bug could use help from the open-source community

## Bi-weekly Community Triage Process

The goal of bi-weekly triage is to catch items that may have fallen through the cracks.

The dashboard of items requiring a response can be found at the [Bi-Weekly Triage Dashboard](http://triage.meyu.us:32374/s/weekly). Each box of items
is defined by a rule and has a listed `Resolution` action. Once the defined action has been taken, the issue will disappear from the list.

At the beginning of the call, we will ask if anyone requires triage permissions to participate.

- _Stale Pull Requests_ are PRs that appear to be going nowhere. If we haven't heard back from the user in 30 days, the PR should be closed with care. The author can reopen it when they are ready.

## Prioritization

!! note
These labels have not yet been finalized - but are based on what is used in other CNCF projects.

If the issue is not `question`, it needs a [priority label](https://github.com/kubernetes/community/blob/master/contributors/guide/issue-triage.md#define-priority):

- `priority/critical-urgent`: someone's top priority ASAP, such as security issue or issue that causes data loss. Rarely used. to be resolved within 5 days.
- `priority/important-soon`: high priority for the team. To be resolved within 8 weeks.
- `priority/important-longterm`: a long-term priority. To be resolved within a year.
- `priority/backlog`: agreed that this would be good to have, but not yet a priority. Consider tagging as `help wanted`
- `priority/awaiting-more-evidence`: may be useful, but there is not yet enough evidence to support inclusion on the backlog.

## Example follow-ups

When a user submits a pull request or issue, it's essential to be respectful of the time the user has invested in opening the issue. Be kind.

These are some templates that you can use as [Github Saved replies](https://docs.github.com/en/github/writing-on-github/working-with-saved-replies/using-saved-replies) for easy access during triage.

### Stale PR with an outstanding comment

> @xx - It appears that this PR is doing the right thing and is very close to being merged! There is only one PR comment to resolve, and the PR will also need to be rebased against the latest code from the main branch.
>
> If we don't hear back within the next two weeks, we will likely close this PR as part of our PR grooming policy. If this happens, you can reopen this PR at any point once the required changes are made.
>
> Thank you for your contribution, and I hope to hear back from you soon!

## Needs more information

> I don't yet have a clear way to replicate this issue. Do you mind adding some additional details? Here is additional information that would be helpful:
>
> - The exact command lines used
> - Logs or command-line output
>
> Thank you for sharing your experience!

### Closing: Duplicate Issue

> This issue appears to be a duplicate of #X. Do you mind if we move the conversation there?
>
> This way we can centralize the content relating to the issue. If you feel that this issue is not a duplicate, please reopen it using `/reopen`. If you have additional information to share, please add it to the new issue.
>
> Thank you for reporting this!

### Closing: Lack of Information

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

### Closing: Very stale PR

Once a PR is 30 days old and pinged at least twice, it's safe to close it:

> Closing this PR as stale. Please reopen this PR when you are ready to retake a look at it. Thank you for your contribution!
