defmodule Client do
    use GenServer

    def init(state) do
        {:ok,state}
    end 

    def add_to_follower_dashboards(finalTweet, followings) do
        if length(followings) > 0 do
            [following | followings] = followings
            GenServer.call(String.to_atom(following), {:add_to_dashboard, {finalTweet}})
            add_to_follower_dashboards(finalTweet, followings) 
        end
    end

    def upsert_user_tweet(userState, tweet) do
        username = Map.get(userState, "username")
        if userState != nil do
            tweets = Map.get(userState, "tweets")
            if tweets != nil && length(tweets) > 0 do
                [lastTweet|allOthers] = tweets
                lastTweetId = elem(lastTweet,1)
                finalTweet = {tweet, Integer.parse(lastTweetId)+1, :calendar.universal_time(), username}
                tweets = [finalTweet | tweets]
            else
                finalTweet = {tweet,0,:calendar.universal_time(), username}
                tweets = [finalTweet]
            end

            #Parse Tweet for Hashtag and Mentions
            parse_tweet(finalTweet)

            #Send Tweet to follower dashboard
            followings = Map.get(userState, "followings")
            add_to_follower_dashboards(finalTweet, followings)
            
            #Add tweet to user state
            userState = Map.put(userState, "tweets", tweets)
        end
        {finalTweet, userState}
    end

    def add_follower(username, follower) do
        pid = Process.whereis(String.to_atom(username))

        if(pid != nil && Process.alive?(pid) == true) do   
            GenServer.call(String.to_atom(follower), {:add_to_following_alive, {username}}) 
        else
            GenServer.call(String.to_atom("mainserver"), {:add_to_following_dead, {username, follower}}) 
        end

        GenServer.call(String.to_atom(username), {:add_to_follower, {follower}})
    end

    def upsert_user_follower(userState, follower) do
        if userState != nil do
            followers = Map.get(userState, "followers")
            if followers != nil do
                followers = [follower | followers]
            else
                followers = [follower]
            end
            userState = Map.put(userState, "followers", follower)
        end
        {follower, userState}
    end

    def upsert_user_following(userState, following) do
        if userState != nil do
            followings = Map.get(userState, "following")
            if followings != nil do
                followings = [following | followings]
            else
                followings = [following]
            end
            userState = Map.put(userState, "followings", following)
        end
        {following, userState}
    end

    def upsert_user_dashboard(userState, tweet) do
        dashboard = Map.get(userState, "dashboard")
        dashboard = [tweet|dashboard]
        userState = userState.put(userState, "dashboard", dashboard)
    end

    def process_hashtags(word, tweet) do
        if String.first(word)=="#" do
            GenServer.call(String.to_atom("mainserver"), {:add_hashtag, {word,tweet}})
        end 
    end

    def process_mentions(word, tweet) do
        if String.first(word) == "@" do
            GenServer.call(String.to_atom("mainserver"), {:add_mentions, {word,tweet}})
        end
    end

    def parse_tweet(finalTweet) do
        tweet = elem(finalTweet, 0)
        split_tweet = String.split(tweet);
        Enum.each(split_tweet, fn(word) -> 
            process_hashtags(word, tweet)
            process_mentions(word, tweet)
        end
        )
    end

    def handle_call({:add_to_dashboard ,new_message}, _from, userState) do
        upsert_user_dashboard(userState, elem(new_message,0))
        {:reply, {:ok}, userState}
    end

    def handle_call({:go_offline ,new_message}, _from, userState) do
        username = Map.get(userState,"username");
        GenServer.call(String.to_atom("mainserver"), {:update_user_state, {username,userState}})
        Genserver.stop(String.to_atom(username),:shutdown, 5000)
        {:reply, true, userState}
    end

    def handle_call({:add_tweet ,new_message}, _from, userState) do
        tweet = elem(new_message,0)
        {tweet, userState} = upsert_user_tweet(userState, tweet)
        {:reply,{:tweet,tweet}, userState}
    end

    def handle_call({:add_to_following_alive ,new_message}, _from, userState) do
        following = elem(new_message,0)
        {following, userState} = upsert_user_following(userState, following)
        {:reply,following,userState}
    end

    def handle_call({:add_to_follower ,new_message}, _from, userState) do
        follower = elem(new_message,0)
        {follower, userState} = upsert_user_follower(userState, follower)
        {:reply,follower,userState}
    end

    def handle_call({:get_tweets ,new_message}, _from, userState) do
        if userState != nil do
            tweets = Map.get(userState, "tweets")
        end
        {:reply,{:tweets,tweets}, userState}
    end

    def handle_call({:get_user_state ,new_message}, _from, userState) do
        {:reply, userState, userState}
    end

end

#{:news,size} = GenServer.call({:bit_coin,String.to_atom(server_name)},{:print_message,"Keyur"}, :infinity)    