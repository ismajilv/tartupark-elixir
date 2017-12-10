# Tartupark

Our aim to create a system to book a parking lot. We analyzed Tartu parking system, and created our project.
We use Phoenix framework, and Vue.js. As database our tool is PostgreSQL. In our implementation we used Google Geolocation service.
Additionally, PostGIS, and GEO dependencies are our other tools to implement map with avaliable parking lots.

Here is list of dependencies we add to build our system:
	  {:white_bread, "~> 4.1", only: [:test]}, // to implement BDD environment
      {:hound, "~> 1.0"}, // to implement white bread scenarios
      {:comeonin, "~> 4.0"}, // for password hashing
      {:pbkdf2_elixir, "~> 0.12"}, // for password hashing
      {:guardian, "~> 0.14"}, // for creating and reading token
      {:geo, "~> 1.0"} // to implement parking zones in our map

You can clone or download the repository, and run the project on your local environment.
To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
