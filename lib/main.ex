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
        

    end

    def post_tweet(username, tweet_text) do
        
        tweet = GenServer.call({:post_tweet,String.to_atom("mainserver")},{username,tweet_text}) 
        
        IO.inspect tweet
          
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