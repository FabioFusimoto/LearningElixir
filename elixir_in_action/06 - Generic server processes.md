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
_GenServers_ suportam as operações que fizemos na unha acima e ainda contam com muitas outras
funcionalidades:
+ Configuração de timeouts em _casts_
+ Propagação de crashes para clientes esperando respostas
+ Suporte para sistemas distribuídos

### OTP Behaviours
Em Erlang, um _behaviour_ nada mais é que um código genérico que satisfaz um determinado padrão.
A lógica genérica é satisfeita por um determinado módulo (_callback module_): tal módulo deve 
satisfazer o contrato estabelecido pelo _behaviour_, ou seja, implementar um certo conjunto de 
funções (o `ServerProcess` é um exemplo simples).

O módulo `GenServer` define outro _behaviour_ com 7 funções a serem implementadas (o override é
necessário para as particularidades da aplicação):
+ `child_spec/1`
+ `code_change/3`
+ `handle_call/3`
+ `handle_cast/2`
+ `handle_info/2`
+ `init/1`
+ `terminate/2`

Reescrevendo o `KeyValueServer` utilizando um `GenServer`:

```elixir
defmodule KeyValueServer do
    use GenServer
    
    def start do
        GenServer.start(KeyValueServer, nil)
    end
    
    def put(pid, key, value) do
        GenServer.cast(pid, {:put, key, value})
    end
    
    def get(pid, key) do
        GenServer.call(pid, {:get, key})
    end
    
    def init(_) do
        {:ok, %{}}
    end
    
    def handle_cast({:put, key, value}, state) do
        {:noreply, Map.put(state, key, value)}
    end
    
    def handle_call({:get, key}, _, state) do
        {:reply, Map.get(state, key), state}
    end
end
```

Alguns pontos de atenção: 
+ A função `start/0` funciona sincronamente, isto é, o cliente ficará em
estado de espera até o término da exceução de `init/1`
+ `GenServer.call/2` possui um timeout padrão de 5 segundos. Isso pode ser configurado utilizando
outra aridade -> `GetServer.call(pid, request, timeout)`

O formato das mensagens internas do `GenServer` é bastante particular e quando uma de outro tipo
precisa ser enviada / recebida, utiliza-se o `handle_info/2` que não se utiliza desse mesmo 
tratamento.

```elixir
defmodule KeyValueServer do
    use GenServer
    
    def init(_) do
        :timer.send_interval(5000, :cleanup)
    end
    
    ...
    
    def handle_info(:cleanup, state) do
        IO.puts("Performing some cleanup...")
        {:noreply, state}
    end
end
```

Para ajudar a não esquecer de implementar uma função definida por um _behaviour_, é possível dar uma
"dica" ao compilador através de atributo `@impl` do módulo que se está desenvolvendo. Isso indica ao
compilador que aquele módulo implementa um `GenServer`:

```elixir
defmodule EchoServer do
    use GenServer
    
    @impl GenServer
    
    ...
end
```

É possível registrar nomes de `GenServer`s da mesma forma que com processos através da seguinte
sintaxe: `GenServer.start(CallbackModule, init_params, name: :an_atom_as_name)`. E para acessar pelo
nome dado: `GenServer.call(:name, ...)` ou `GenServer.cast(:name, ...)`. Módulos são atoms também,
logo servem como nomes também. O nome do módulo também pode ser substituido por `__MODULE__`.

### Stopping the server
Há várias maneiras de se fazer isso:
+ No `init/1`, pode-se retornar `{:stop, reason}` para indicar uma parada com falha ou `:ignore` no
caso de uma parada esperada
+ Nas chamadas de `handle_*`, pode-se retornar `{:stop, reason, new_state}`. Caso seja necessário
responde ao cliente antse de parar, usa-se `{:stop, reason, response, new_state}`
+ Pode-se também chamar `GenServer.stop/3`

O `new_state` fomenta a execução da função `terminate/2`, que ocorre assim que um processo para
