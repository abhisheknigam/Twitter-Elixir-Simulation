defmodule Server do
    use GenServer

    def init(args) do
        arguments = parse_args(args)

    end

    def handle_call({:get_state ,new_message},_from,state) do  
        {:reply,state,state}
    end

    def initialize_state() do
        state = {}

    end

    def initialize_user() do
        
    end

    def upsert_user(state, username, password) do
        userState = Map.get(state, username);
        if userState == null do
            Map.put(userState, "username", username)
            Map.put(userState, "password", password)
            Map.put(state, username, userState)
        end
    end

    def upsert_user_tweet(state, username, tweet) do
        userState = Map.get(state, username);
        if userState != null do
            tweets = Map.get(userState, "tweets")
            if tweets != null do
                [allOthers|lastTweet] = tweets
                lastTweetId = elem(lastTweet,1)
                tweets = [tweets | {tweet, Integer.parse(lastTweetId+1)}]
            else
                tweets = [{tweet,0}]
            end
            userState = Map.put(userState, "tweets", tweet)
        end
        state = Map.put(state, username, userState)
    end

    def upsert_user_follower(state, username, follower) do
        userState = Map.get(state, username);
        if userState != null do
            followers = Map.get(userState, "followers")
            if followers != null do
                followers = [followers | follower]
            else
                followers = [follower]
            end
            userState = Map.put(userState, "followers", follower)
        end
        state = Map.put(state, username, userState)
    end

    def upsert_user_following(state, username, following) do
        userState = Map.get(state, username);
        if userState != null do
            followings = Map.get(userState, "following")
            if followings != null do
                followings = [followings | following]
            else
                followings = [following]
            end
            userState = Map.put(userState, "followings", following)
        end
        state = Map.put(state, username, userState)
    end

end