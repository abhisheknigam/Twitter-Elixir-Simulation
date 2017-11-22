defmodule Client do
    use GenServer

    def init(args) do
        username = elem(args,0)
        passwd = elem(args,0)
        state = GenServer.call(String.to_atom(mainserver),{:get_state, "mainserver"})         
        serv_resp = Map.fetch(state, String.to_atom(username)
        if(elem(serv_resp,0)== String.to_atom("ok")){
          userState = elem(serv_resp,1)
        }
        else{
          userState = {"username" => username, "password" => passwd, "tweets" => [], "follwers"=>[],"follwings"=>[] }
        }
    end 

    def upsert_user_tweet(userState, username, tweet) do
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
    end

    def upsert_user_follower(userState, username, follower) do
        if userState != null do
            followers = Map.get(userState, "followers")
            if followers != null do
                followers = [followers | follower]
            else
                followers = [follower]
            end
            userState = Map.put(userState, "followers", follower)
        end
    end

    def upsert_user_following(userState, username, following) do
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
    end

end