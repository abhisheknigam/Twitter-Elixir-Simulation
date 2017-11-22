defmodule Server do
    use GenServer

    def init(args) do
       # arguments = parse_args(args)
        %{"users" => %{}, "hashtags" => %{}, "mentions" => %{}}
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

    def register_user() do
        
    end
    
    def handle_call({:get_state ,new_message},_from,state) do  
        {:reply,state,state}
    end

    #call_backs

end