# Multiplayer Party Game

Try it live at https://mpg.fly.dev/

Open in multiple tabs & experience a Jackbox-style game inspired by [🐺 One Night Ultimate Werewolf](https://boardgamegeek.com/boardgame/147949/one-night-ultimate-werewolf)!

## Demo

https://github.com/jccr/mpg/assets/5132652/d6eb0948-1876-4fd9-996a-80e64722968b

## Project Brief
> **Preface:** On June of 2022, I took on this project during my time as an Engineering Partner at [Commit.dev](https://commit.dev/for-developers/).
> 
> I had an opportunity to embark on a 1-week solo hackathon project, the goal being to build anything that would help me grow as a developer, and to present the final results to a panel of peers and mentors.
>
> I've long desired to work in an environment that offers an experience as close to pure functional programming as possible. Thus my motivation for this project.
>
> You can find my original document for the following section [here](https://docs.google.com/document/d/1E0oKTJPyJD0mtTJk2UiyeR4K8kukih0GgAw-jmVewv4/edit?usp=sharing).

### Pitch
Create a social multiplayer game in the style of [Jackbox](https://www.jackboxgames.com/how-to-play/) using [Elixir](https://elixir-lang.org/) and [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html) where participants connect to a shared site from their individual clients.

The game should be simple and easy to play within 5 minutes for the purposes of a reduced scope and demonstration.

### Details

The goal of this project is for me to learn the Elixir programming language by creating my own  server-rendered HTML experience using Phoenix LiveView. Using this framework will allow me to focus on the implementation and to practice using a declarative, functional and immutable programming model where the hard job of real-time rendering and networked state synchronization is pre-handled.

> _“LiveView strips away layers of abstraction, because it solves both the client and server in a single abstraction. HTTP almost entirely falls away. No more REST. No more JSON. No GraphQL APIs, controllers, serializers, or resolvers. You just write HTML templates, and a stateful process synchronizes it with the browser, updating it only when needed. And there's no JavaScript to write.”_ – Chris McCord, [How We Got to LiveView](https://fly.io/blog/how-we-got-to-liveview/)

For the actual game experience I will implement something that is fun to play and engaging in a single round. My candidate game will be [One Night Ultimate Werewolf](https://boardgamegeek.com/boardgame/147949/one-night-ultimate-werewolf) which is designed for 3-10 players with a duration of 5-10 minutes (5 minutes or less for the demo implementation). The goal is to make the game minimally functional with reduced efforts on UI/UX, meaning more effort will be put on the backend instead of the frontend.

The application will consist of a create or join game page, game lobby page, and the active game page. A lobby will be created and an invite code to join will be displayed. The code is shared to all participants to use and join the lobby. The lobby creator will start the game when all have joined. 

### Deliverables
- A playable multiplayer game demo powered by Elixir and Phoenix.
- Deployed to live infrastructure for anyone to play.
    - Use PaaS Heroku-like for Elixir Phoenix: https://fly.io/docs/getting-started/elixir/

### To think about
- I’m learning to use functional programming fulltime in a project, with new technology, which means I will encounter blockers or slowdowns. The good news is that Elixir and Phoenix look to be highly productive.
- The game I chose might have hidden complexity that I haven’t thought about, I may need to simplify or pivot to something else while still learning the language and framework. (Multiplayer tic-tac-toe instead of a tabletop replica)
- I will need to create HTML pages using a templating system that I haven’t used before, moving away from my mindset of React that I’ve been using for years.
- I wish to have HOP demo session participants volunteer and play the game, live, as part of my presentation.
- Handling latency or lag by having players joining from multiple parts of the world. 
- Support for re-joining the game if a disconnection occurs.
- The ecosystem of information around this technology is less than say JS and React, which could mean I’ll be on my own with less resources available for reference.

### Stretch Goals
- Player profiles, avatars, game history (adding a database)
- Extensibility or generic abstractions to make other types of games.
- Create a [Commit Zero](https://github.com/commitdev/zero) template for Elixir and integrate with it
- Design an original game with original graphical/sound assets

## Development Notes

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

### Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
