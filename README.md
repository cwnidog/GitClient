# GitClient
#baseSearch
-----------
* Create a main menu to our app using a static table view
* Create a network controller and implement a method that fetches repositories based on a search term. Instead of pointing the request at the Actual Github API server, use the node script provided in the class repository and point the request at your own machine. Since our apps aren't authenticated with Github yet we will hit the rate limit after 5 unauthenticated calls from our IP. The node script is called server.js. Just run it with your node command in terminal.
* Create a RepositoryViewController and parse through the JSON returned fromm the server into struct model objects and display the results in a table view.
* Add a UISearchBar to your RepositoryViewController and fire your network call from there. Tomorrow once we are authenticated we will actually use that search
term to get the right data back.
