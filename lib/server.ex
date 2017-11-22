defmodule Server do
    use GenServer

    def init(args) do
       # arguments = parse_args(args)
        %{"users" => %{}, "hashtags" => %{}, "mentions" => %{}}
    end

    

    def initialize_state() do
        state = {}

    end

    def initialize_new_user(username, passwd) do
        {"username" => username, "password" => passwd, "tweets" => [], "follwers"=>[],"follwings"=>[] }
    end

    def register_user(users,username, passwd) do
        new_user_state = initialize_new_user(username, passwd)
        users = Map.put(users,username,new_user_state)
        users
    end
    
    def handle_call({:get_state ,new_message},_from,state) do  
        {:reply,state,state}
    end

    def handle_call({:register_user ,new_user_info},_from,state) do  
        
        #new_user_info -> {username,password}

        username = elem(new_user_info, 0)
        password = elem(new_user_info,1)
        retValue = false
        if(state["users"][username] == nil) do
            #add user
            retValue =  true
            users = register_user(Map.get(state,"users"),username,password)
            state = Map.put(state,"users",users)            
        end
        {:reply,retValue,state}
    end

    #dump user state on server
    def handle_call({:update_user_state ,user},_from,state) do  
        
        users = Map.get(state, "users")

        users = Map.put(users,Map.get(user,"username"),user)
        state = Map.put(state,"users",users)
        
        {:reply,state,state}
    end

    #get user state
    def handle_call({:get_user_state ,username},_from,state) do  
        
        users = Map.get(state, "users")

        user = Map.get(users,username)       
        
        {:reply,user,state}
    end
    
    #call_backs

end