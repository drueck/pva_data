# PVA Data

An Elixir [GraphQL](https://graphql.org/) API for [Portland Volleyball
Association](https://www.portlandvolleyball.org/) league data. 🏐🏐🏐

If it's still deployed there when you're reading this, you can check out the
built-in API docs and play around with the live data in Graphiql here
[https://pva-data.gigalixirapp.com/graphiql](https://pva-data.gigalixirapp.com/graphiql).

## How it Works

League information including divisions, teams, schedules, scores, and standings,
is periodically scraped from the public Portland Volleyball Association website,
transformed, and stored in memory in a GenServer process.

The GraphQL API built with [Absinthe](https://absinthe-graphql.org/) requests the
the data from the GenServer as needed.

Another GenServer coordinates periodically updating the in memory data from the
source website as well as persisting it to an external store as a backup that
can be used if the app is restarted.

## What's the Point?

I'm a volleyball player and a software engineer, and I've been playing in PVA
leagues for probably 20 years. Over the years I have played around with
different ways to improve the process of looking up my team's schedules,
scores, and standings. I sometimes just wanted to make it faster to get
directly to my team's data, to make a more mobile friendly interface that I
could use on the go and in a hurry, or even to be able to access the info on
the command line while I was at work (because cli interfaces are the best!). So
I've made a few things over the years to facilitate those goals, and because
it's an excuse to play around with different tech. First I made a mobile friendly
shortcuts page just for my teams that allowed one-click access to our data on
the regular website, and then I made the [pva](https://github.com/drueck/pva/)
cli which I've used for years now and very much enjoy, and now I'm working on
this GraphQL API.

## Why an API

The use case for this API is to allow myself or anyone else who might
interested ??? (🦗🦗🦗) to get access to the data directly so we can build
whatever interfaces we want on top of it. A web app? A mobile app? A
slack bot? Another cli interface written in node, go, or rust? When you have
access to the API it opens up a lot of possibilities. Specifically I'll
probably build a React single page app first, but who knows.

## Installation, Usage, Deployment, Testing, Contributing

If anyone is ever interested in any of those things, let me know and I can 
fill out the rest of the README. :)
