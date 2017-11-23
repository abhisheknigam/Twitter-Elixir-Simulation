defmodule MainModule do
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
        logout_user("keyur")
        logout_user("abhi")
    end

    def post_tweet(username, tweet_text) do
        
        tweet = GenServer.call({:post_tweet,String.to_atom("mainserver")},{username,tweet_text}) 
        
        IO.inspect tweet
          
    end

    def get_server_state() do
        state = GenServer.call({:get_state,String.to_atom("mainserver")},{}) 
        state
    end

    def get_user_state(username) do
        user = GenServer.call({:get_user_state,String.to_atom("mainserver")},username) 
        user
    end
    def logout_user(username)  do
        retval = GenServer.call({:logout,String.to_atom("mainserver")},{username}) 
        if(retVal == true) do 
            IO.inspect "" <> username <>" logout successful"
        else
            IO.inspect "" <> username <>" login unsuccessful"
        end    
    end

    def login_user(username,password)  do
        retval = GenServer.call({:login,String.to_atom("mainserver")},{username,password}) 
        if(retVal == true) do 
            IO.inspect "" <> username <>" login successful"
            IO.inspect get_user_state(username)
        else
            IO.inspect "" <> username <>" login unsuccessful"
        end    
    end

    def register_user(username,password) do
        retval = GenServer.call({:register_user,String.to_atom("mainserver")},{username,password}) 
        if(retVal == true) do 
            IO.inspect "" <> username <>" registration successful"
        else
            IO.inspect "" <> username <>" registration unsuccessful"
        end        
    end

end