defmodule Tweeter do
    use GenServer

    def main(args) do
     
        start_server
        run_tests
        
    end

    def start_server do
        GenServer.start_link(Server, {}, name: String.to_atom("mainserver"))
    end

    def run_tests do
        
        register_user("keyur","baldha")
        register_user("abhi","shek")
        register_user("apurv","apurv")
        register_user("Karan","Karan")

        login_user("keyur","baldha")
        login_user("abhi","shek")
        login_user("apurv","apurv")
        login_user("Karan","Karan")


        


        add_follower("abhi","keyur")
        add_follower("apurv","keyur")
        add_follower("Karan","keyur")

        add_follower("Karan","abhi")
        add_follower("keyur","abhi")

        post_tweet("keyur","helooo")
        post_tweet("keyur","jijijiij")

        post_tweet("apurv","I am IBM #Watson @keyu")
        post_tweet("Karan","I am Anita's Lover")
        post_tweet("abhi","#This is from abhi")



        IO.inspect get_user_state("apurv")
        IO.inspect get_user_state("Karan")
        

        IO.puts "------------------server state---------------------"

        IO.inspect get_server_state


        logout_user("keyur")
        logout_user("abhi")

        IO.gets ""
    end

    def post_tweet(username, tweet_text) do
        
        #tweet = GenServer.call(String.to_atom("mainserver"), {:post_tweet,{username,tweet_text}}) 
        {:tweet,tweet} = GenServer.call(String.to_atom(username),{:add_tweet,{tweet_text}})
        IO.inspect tweet
          
    end

    def get_server_state() do
        state = GenServer.call(String.to_atom("mainserver"),{:get_state,{}}) 
        state
    end

    def get_server_user_state(username) do
        user = GenServer.call(String.to_atom("mainserver"),{:get_user_state,username})         
        user
    end

    def get_user_state(username) do
        user = GenServer.call(String.to_atom(username),{:get_user_state,username})         
        user
    end
    
    def logout_user(username)  do
        GenServer.cast(String.to_atom(username),{:go_offline,{username}}) 
        retVal = true
        IO.inspect "" <> username <>" logout successful"
    end

    def login_user(username,password)  do
        retVal = GenServer.call(String.to_atom("mainserver"), {:login,{username,password}}) 
        if(retVal == true) do 
            IO.inspect "" <> username <>" login successful"
            IO.inspect get_user_state(username)
        else
            IO.inspect "" <> username <>" login unsuccessful"
        end    
    end

    def register_user(username,password) do
        retVal = GenServer.call(String.to_atom("mainserver"),{:register_user,{username,password}}) 
        if(retVal == true) do 
            IO.inspect "" <> username <>" registration successful"
        else
            IO.inspect "" <> username <>" registration unsuccessful"
        end        
    end

    def add_follower(username, follower) do
        user = GenServer.call(String.to_atom(username),{:add_follower, {follower}})         
    end
end