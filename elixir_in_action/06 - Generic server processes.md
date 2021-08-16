# Capítulo 6 - Generic server processes

Generic servers (`GenServer`, como é nomeado o módulo) são implementados através do framework OTP,
que está intimamente ligado à uma dada versão da linguagem.

## Building a generic server process
Um server process geralmente tem que realizar as seguintes ações:
+ Criar um processo separado
+ Executar uma recursão infinita dentro do processo gerado
+ Manter o estado do processo
+ Reagir à mensagens
+ Enviar uma reposta aos processos que o invocam

A implementação um GenServer (na unha) do autor se pauta na divisão entre trechos de código mais
genéricos versus específicos e assume que a forma mais natural de se fazer tal divisão é através
de módulos. Assume-se que tais módulos devam ter um conjunto de funções "mínimas" que sejam capazes
de atender às ações listadas acimas.

As seguintes funções de exemplo foram implementadas:
+ `start` -> Para gerar o processo e definir o estado inicial
+ `loop` -> Gerar a recursão infinita, recebendo mensagens e enviando respostas sincronamente
+ `call` -> Gera requisições para o server process

```elixir
defmodule ServerProcess do
    def start(callback_module) do
        spawn(fn ->
            initial_state = callback_module.init()
            loop(callback_module, initial_state)
        )
    end
    
    defp loop(callback_module, current_state) do
        receive do
            {request, caller} ->
                {response, new_state} = callback_module.handle_call(
                    request,
                    current_state
                )
                
                send(caller, {:response, response})
                
                loop(callback_module, new_state)
        end
    end
    
    def call(server_pid, request) do
        send(server_pid, {request, self()})
        
        receive do
            {:response, response} ->
                response
        end
    end
end
```

Abaixo segue uma implementação de um server que armazena chaves e valores:

```elixir
defmodule KeyValueServer do
    def init do
        %{}
    end
    
    def handle_call({:put, key, value}, state) do
        {:ok, Map.put(state, key, value)}
    end
    
    def handle_call({:get, key}, state) do
        {Map.get(state, key), state}
    end
    
    def start do
        ServerProcess.start(KeyValueServer)
    end
    
    def put(pid, key, value) do
        ServerProcess.call(pid, {:put, key, value})
    end
    
    def get(pid, key) do
        ServerProcess.call(pid, {:get, key})
    end
end
```

As funções `start/0`, `put/3` e `get/2` são chamadas de interface, criadas com o intuito de serem
utilizadas pelo cliente e escondem detalhes de implementação (que pautam-se na utilização do módulo
`ServerProcess`).

### Supporting asynchronous requests
No Erlang, quando se invoca uma função síncrona, utiliza-se o termo _call_. Já quando se trata de
código assíncrono, utiliza-se _cast_. Modificando o `ServerProcess` para ter suporte à requisições
dos tipos call e cast e fazendo as devidas alterações no `KeyValueServer`:

```elixir
defmodule ServerProcess do
    
    ...
    
    defp loop(callback_module, current_state) do
        receive do
            {:call, request, caller} ->
                {response, new_state} = callback_module.handle_call(
                    request,
                    current_state
                )
                
                send(caller, {:response, response})
                
                loop(callback_module, new_state)
            
            {:cast, request} ->
                new_state = callback_module.handle_cast(
                    request,
                    current_state,
                )
                
                loop(callback_module, new_state)
        end
    end
    
    def call(server_pid, request) do
        send(server_pid, {:call, request, self()})
        
        receive do
            {:response, response} ->
                response
        end
    end
    
    def cast(server_pid, request) do
        send(server_pid, {:cast, request})
    end
end

defmodule KeyValueServer do
    ...
    
    def put(pid, key, value) do
        ServerProcess.cast(pid, {:put, key, value})
    end

    ...
    
    def handle_cast({:put, key, value}, state) do
        Map.put(state, key, value)
    end
    
    ...
end
```

Note que não faz muito sentido a requisição de `:get` ser um cast.

## Using GenServer
