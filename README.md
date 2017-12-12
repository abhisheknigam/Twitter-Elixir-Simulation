# Tweeter

To run the code 

1. Build using mix escript.build
2. Start the server using command
    escript Tweeter "server"
3. In another terminal, start client with the parameter <no. of users> using command
    escript Tweeter <no. of users>

At the end the program will terminate and will give total time to simulate that many number of users. If you want to see the user state at different stages, please uncomment the code as required. We have put IO.inspect for your convinence. We are printing the Strings, "Post tweet of <user>", "retweet by <user>" and "add follower of <user>" to show concurrency.

