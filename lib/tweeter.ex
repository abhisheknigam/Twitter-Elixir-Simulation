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
        login_user("keyur","baldha")
        login_user("abhi","shek")
        post_tweet("keyur","helooo")
        #logout_user("keyur")
        #logout_user("abhi")
    end

    def post_tweet(username, tweet_text) do
        
        tweet = GenServer.call(String.to_atom("mainserver"), {:post_tweet,{username,tweet_text}}) 
        
        IO.inspect tweet
          
    end

    def get_server_state() do
        state = GenServer.call(String.to_atom("mainserver"),{:get_state,{}}) 
        state
    end

    def get_user_state(username) do
        user = GenServer.call(String.to_atom("mainserver"),{:get_user_state,username}) 
        user
    end
    
    def logout_user(username)  do
        retVal = GenServer.call(String.to_atom("mainserver"),{:logout,{username}}) 
        if retVal == true do
            IO.inspect "" <> username <>" logout successful"
        else
            IO.inspect "" <> username <>" login unsuccessful"
        end    
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

end