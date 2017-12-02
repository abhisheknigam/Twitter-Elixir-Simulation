defmodule Tweeter do
    use GenServer

    def main(args) do
        inp = process_arguments(args)
        numberofClients = 20


        if(inp == "server") do
            start_server
            IO.gets ""
            IO.puts "------------------server state---------------------"
            IO.inspect get_server_state
        else
            #start client 
            start_client
            #run_test_new
            #run_tests
            #IO.inspect getZipfDist(50)
            run_zipf_test(numberofClients)            
            IO.puts "------------------server state---------------------"
            IO.inspect get_server_state
            
        end
        #run_tests
        
       

        #IO.puts "------------------user state---------------------"
        #Enum.map(1..numberofClients,fn(x)-> IO.inspect get_user_state("node_"<>Integer.to_string(x)) end)
        #IO.inspect get_user_state("keyur")
        
       
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

    

    def getZipfDist(numberofClients) do
        distList=[]
        s=1
        c=getConstantValue(numberofClients,s)
        distList=Enum.map(1..numberofClients,fn(x)->{"node_"<>Integer.to_string(x),:math.ceil((c*numberofClients)/:math.pow(x,s))} end)
        distList
    end
        
    def getConstantValue(numberofClients,s) do
        k=Enum.reduce(1..numberofClients,0,fn(x,acc)->:math.pow(1/x,s)+acc end )
        k=1/k
        k
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
        #IO.puts "server starting"
        Node.start(String.to_atom("server@"<>get_ip_addr))
        Node.set_cookie :"choco"
        GenServer.start_link(Server, {}, name: String.to_atom("mainserver"))
    end

    def should_terminate(userList) do
        count = get_online_user_count(0,userList)
        #IO.inspect userList
        if(count == 0) do
            true
        else
            :timer.sleep(100)
            should_terminate(userList)
        end        
    end

    def get_online_user_count(count,userList) do
        
        if(length(userList) == 0 || count > 0) do
            count
        else         
            [username|userList] = userList
            if(is_user_online(elem(username,0)) == true) do
                count = count + 1
            end
            get_online_user_count(count,userList)
        end

    end
    
    def run_test_new do
        IO.inspect "register user"
        register_user("keyur","baldha")
        register_user("abhi","shek")

        login_user("keyur","baldha")
        login_user("abhi","shek")
        post_tweet("keyur","helooo")
        add_follower("abhi","keyur")

        :timer.sleep(2500)
        logout_user("keyur")
        logout_user("abhi")

    end

    
    
    
    def run_zipf_test(count) do
        
        userlist = create_users(count, [])
        IO.inspect userlist
        zipfDistList = getZipfDist(count)
        register_and_login(userlist)
        #:timer.sleep(5000)
        Enum.each(zipfDistList, fn(tuple) -> 
                spawn_link fn -> simulate_user(elem(tuple,0),count,elem(tuple,1)) end
            end
        )
        
        if(should_terminate(userlist) == true) do
            true
        end
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

        post_retweet("keyur", "abhi", 0)


        IO.inspect get_user_state("Karan")
        IO.inspect get_user_state("abhi")
        #IO.inspect get_user_state("apurv")
        #IO.inspect get_user_state("Karan")


        logout_user("keyur")
        logout_user("abhi")

        #:timer.sleep(2000)

        login_user("keyur","baldha")

        #userlist = create_users(50, [])
        #register_and_login(userlist)
        #post_random_tweets(userlist,100)
        #map_set = MapSet.new
        #map_set = add_random_followers(userlist, 50, map_set)
        #logout_all_users(userlist)


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
            #IO.puts "Tweet posted by " <> username
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

            #IO.puts "Tweet posted by " <> username
            #IO.puts "Tweet posted by" <> followerName

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

    def get_random_user(username,total_clients) do
        num = :rand.uniform(total_clients)
        new_user = "node_"<> Integer.to_string(num)
        if(username != new_user) do
            new_user
        else
            get_random_user(username,total_clients)
        end 
    end
    def create_users(number,userlist) do
        if(number == 0) do
            userlist
        else
            user = {"node_" <> Integer.to_string(number),"pwd"}
            userlist = [user | userlist]
            create_users(number-1,userlist)
        end
    end
    
    def random_hashtag(length) do
        :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
    end

    def post_tweet(username, tweet_text) do
        #tweet = GenServer.call(String.to_atom("mainserver"), {:post_tweet,{username,tweet_text}}) 
        #IO.inspect "post tweet of "<> username
        if(is_user_online(username) == true) do
            
            {:tweet,tweet} = GenServer.call({String.to_atom(username),String.to_atom("client@"<>get_ip_addr)},{:add_tweet,{tweet_text}})
        end
        #{:tweet,tweet} = GenServer.call(String.to_atom(username),{:add_tweet,{tweet_text}})
        
        IO.inspect tweet
    end

    def post_retweet(username, tweet_username, tweet_id) do
        {:tweet,tweet} = GenServer.call({String.to_atom(username),String.to_atom("client@"<>get_ip_addr)},{:retweet,{tweet_username,tweet_id}})
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
        
        GenServer.cast({String.to_atom(username),String.to_atom("client@"<>get_ip_addr)},{:go_offline,{"log out"}})
        
        #GenServer.call({String.to_atom("mainserver"),String.to_atom("server@"<>get_ip_addr)},{:logout,{username}}) 
        #retVal = true
        IO.inspect "" <> username <> " logout successful"
    end

    def login_user(username,password)  do
        #retVal = GenServer.call({String.to_atom(username),String.to_atom("client@"<>get_ip_addr)}, {:login,{username,password}}) 
        info = {username,password}
        #IO.puts "login " <> username
        GenServer.start_link(Client, info, name: String.to_atom(username))
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
        tweets = GenServer.call({String.to_atom("mainserver"),String.to_atom("server@"<>get_ip_addr)},{:get_hash_list, {hashtag}})         
    end

    def get_mention_tweets(username) do        
        IO.puts "--------------------Tweets with username "<> username
        tweets = GenServer.call({String.to_atom("mainserver"),String.to_atom("server@"<>get_ip_addr)},{:get_mentions_list, {username}})         
    end

    def add_follower(username, follower) do
        if(is_user_online(username) == true) do
            user = GenServer.call({String.to_atom(username),String.to_atom("client@"<>get_ip_addr)},{:add_follower, {follower}})   
        end      
    end

    def is_user_online(username) do
        is_online = false
       # IO.puts username
        pid = Process.whereis(String.to_atom(username))   
       # IO.inspect username <> " is  :: "
       # IO.inspect pid   
        if(pid != nil && Process.alive?(pid) == true) do
            is_online = true
        end
        is_online
    end

    def simulate_user(username,client_count,weight) do
        tweet_factor = 2
        weight  = round(weight)
        lst = Enum.concat([1..weight])
        #IO.puts "simulating " <> username
        Enum.each(lst, fn(num) -> 
            #IO.inspect num
            random_username = get_random_user(username,client_count)
            #IO.inspect random_username
            post_tweet(username,"test tweet::" <> username <> Integer.to_string(num))
            add_follower(username,random_username)
            #process_mentions(word, finalTweet)
        end
        )
        
        tweet_factor = tweet_factor - 1
        lst = Enum.concat([1..tweet_factor*weight])
        Enum.each(lst, fn(num) ->            
            post_tweet(username,"test tweet::" <> username <> Integer.to_string(num))           
        end
        )

        logout_user(username)
    end

end