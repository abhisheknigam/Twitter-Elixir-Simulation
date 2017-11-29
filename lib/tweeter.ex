defmodule Tweeter do
    use GenServer

    def main(args) do
     
        inp = process_arguments(args)
        if(inp == "server") do
            start_server
        else
            
            #start client 
            start_client
            run_test_new
        end
        #run_tests
        IO.gets ""
    end
    def start_client do

        Node.start(String.to_atom("client@"<>get_ip_addr))
        Node.set_cookie :"choco"
        Node.connect(String.to_atom("server@"<>get_ip_addr))
        IO.puts "connected to server::"        

        # retVal = GenServer.call({String.to_atom("mainserver"),String.to_atom("server@"<>get_ip_addr)},{:register_user,{username,password}}) 
        # if(retVal == true) do 
        #     IO.inspect "" <> username <>" registration successful"
        # else
        #     IO.inspect "" <> username <>" registration unsuccessful"
        # end   

    end

    def process_arguments(arguments) do
        {_, [input], _} = OptionParser.parse(arguments)
        input = to_string input
        input
    end

    def get_ip_addr do
        {:ok,lst} = :inet.getif() 
        x = elem(List.first(lst),0)
        addr =  to_string(elem(x,0)) <> "." <>  to_string(elem(x,1)) <> "." <>  to_string(elem(x,2)) <> "." <>  to_string(elem(x,3))
        addr  
    end

    def start_server do
        IO.puts "server starting"
        Node.start(String.to_atom("server@"<>get_ip_addr))
        Node.set_cookie :"choco"
  
        GenServer.start_link(Server, {}, name: String.to_atom("mainserver"))
    end

    def run_test_new do
        IO.inspect "register user"
        register_user("keyur","baldha")
        

        login_user("keyur","baldha")
        post_tweet("keyur","helooo")
        :timer.sleep(2500)
        logout_user("keyur")

    end
    def run_tests do
        
        register_user("keyur","baldha")
        register_user("abhi","shek")
        register_user("apurv","apurv")
        register_user("Karan","Karan")

        login_user("keyur","baldha")
        :timer.sleep(2500)
        login_user("keyur","baldha")
        
        :timer.sleep(11500)
        login_user("abhi","shek")
        login_user("apurv","apurv")
        login_user("Karan","Karan")


        add_follower("abhi","keyur")
        add_follower("apurv","keyur")
        add_follower("Karan","keyur")
        login_user("Karan","Karan")
        add_follower("Karan","abhi")
        add_follower("keyur","abhi")

        post_tweet("keyur","helooo")
        post_tweet("keyur","jijijiij")

        post_tweet("apurv","I am IBM #Watson @keyu")
        post_tweet("Karan","I am Anita's Lover")
        post_tweet("abhi","#This is from abhi")
        
        
        IO.inspect get_hashtag_tweets("This")

        post_retweet("abhi", "apurv", 0)


        IO.inspect get_user_state("Karan")
        IO.inspect get_user_state("abhi")
        #IO.inspect get_user_state("apurv")
        #IO.inspect get_user_state("Karan")


        logout_user("keyur")
        logout_user("abhi")

        #:timer.sleep(2000)

        login_user("keyur","baldha")

        userlist = create_users(50, [])
        register_and_login(userlist)
        post_random_tweets(userlist,100)
        map_set = MapSet.new
        map_set = add_random_followers(userlist, 50, map_set)
        logout_all_users(userlist)


        IO.puts "------------------server state---------------------"
        IO.inspect get_server_state

        IO.puts "------------------user state---------------------"
        IO.inspect get_user_state("keyur")
        
        IO.gets ""
    end


    def logout_all_users(userlist) do
        Enum.each(userlist, 
            fn(user) -> 
                logout_user(elem(user,0))   
            end
        )
    end

    def post_random_tweets(userlist,count) do
        userCount = length(userlist)        
        if(count == 0) do

        else
            user = :rand.uniform(userCount)           
            username = elem(Enum.at(userlist,user-1),0)
            IO.puts "Tweet posted by " <> username
            shouldAddHashTag = :rand.uniform(2) - 1
            hashtagStr = "" 
            if(shouldAddHashTag == 0) do
                hashtagStr = "#" <> random_hashtag(5)
            end
            post_tweet(username,"test tweet::: " <> hashtagStr <> " " <> Integer.to_string(count))
            :timer.sleep(50) 
            post_random_tweets(userlist,count-1)
        end
    end

    def add_random_followers(userlist, count, map_set) do
        userCount = length(userlist)        
        if(count == 0) do

        else
            user = :rand.uniform(userCount)           
            username = elem(Enum.at(userlist,user-1),0)
            follower = :rand.uniform(userCount)
            followerName = elem(Enum.at(userlist,follower-1),0)

            IO.puts "Tweet posted by " <> username
            IO.puts "Tweet posted by" <> followerName

            IO.inspect username <> "-" <> followerName
            pairExists = MapSet.member?(map_set, username <> "-" <> followerName)
            
            if(pairExists != nil && username != followerName) do
                add_follower(username, followerName)
                map_set = MapSet.put(map_set, username <> "-" <> followerName)
            end 
            add_random_followers(userlist, count-1, map_set)
        end
        map_set
    end

    def register_and_login(userlist) do
        Enum.each(userlist, 
            fn(user) -> 
                register_user(elem(user,0), elem(user,1))   
                :timer.sleep(100)             
                login_user(elem(user,0), elem(user,1))
            end
        )
    end

    def create_users(number,userlist) do
        if(number == 0) do
            userlist
        else
            user = {"user_" <> Integer.to_string(number),"pwd"}
            userlist = [user | userlist]
            create_users(number-1,userlist)
        end
    end
    
    def random_hashtag(length) do
        :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
    end

    def post_tweet(username, tweet_text) do
        #tweet = GenServer.call(String.to_atom("mainserver"), {:post_tweet,{username,tweet_text}}) 
        {:tweet,tweet} = GenServer.call({String.to_atom(username),String.to_atom("client@"<>get_ip_addr)},{:add_tweet,{tweet_text}})
        IO.inspect tweet
    end

    def post_retweet(username, tweet_username, tweet_id) do
        {:tweet,tweet} = GenServer.call(String.to_atom(username),{:retweet,{tweet_username,tweet_id}})
        IO.inspect tweet
          
    end

    def get_server_state() do
        state = GenServer.call({String.to_atom("mainserver"),String.to_atom("server@"<>get_ip_addr)},{:get_state,{}}) 
        state
    end

    def get_server_user_state(username) do
        user = GenServer.call({String.to_atom("mainserver"),String.to_atom("server@"<>get_ip_addr)},{:get_user_state,username})         
        user
    end

    def get_user_state(username) do
        user = GenServer.call(String.to_atom(username),{:get_user_state,username})         
        user
    end
    
    def logout_user(username)  do
        
        GenServer.call({String.to_atom("mainserver"),String.to_atom("server@"<>get_ip_addr)},{:logout,{username}}) 
        retVal = true
        IO.inspect "" <> username <>" logout successful"
    end

    def login_user(username,password)  do
        #retVal = GenServer.call({String.to_atom(user),String.to_atom("client@"<>get_ip_addr)}, {:login,{username,password}}) 
        GenServer.start_link(Client, {username,password}, name: String.to_atom(username))
        # if(retVal == true) do 
        #     IO.inspect "" <> username <>" login successful"
        #     IO.inspect get_user_state(username)
        # else
        #     IO.inspect "" <> username <>" login unsuccessful"
        # end    
    end

    def register_user(username,password) do
        retVal = GenServer.call({String.to_atom("mainserver"),String.to_atom("server@"<>get_ip_addr)},{:register_user,{username,password}}) 
        if(retVal == true) do 
            IO.inspect "" <> username <>" registration successful"
        else
            IO.inspect "" <> username <>" registration unsuccessful"
        end        
    end

    def get_hashtag_tweets(hashtag) do
        IO.puts "----------------------------Tweets with hashtag "<> hashtag
        tweets = GenServer.call(String.to_atom("mainserver"),{:get_hash_list, {hashtag}})         
    end

    def get_mention_tweets(username) do        
        IO.puts "--------------------Tweets with username "<> username
        tweets = GenServer.call(String.to_atom("mainserver"),{:get_mentions_list, {username}})         
    end

    def add_follower(username, follower) do
        user = GenServer.call(String.to_atom(username),{:add_follower, {follower}})         
    end
end