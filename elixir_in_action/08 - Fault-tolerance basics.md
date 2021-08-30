# Fault-tolerance basics

A filosofia para lidar com erros do Erlang é: o foco não precisa ser em diminuir a quantidade de
erros ao mínimo possível, uma vez que **tudo** pode dar errado. Pode-se desprender energia de forma
mais inteligente preparando o sistema para falhar de maneira isolada, isto é, afetando a menor
quantidade de funcionalidades possível e permitindo que algumas funcionem parcialmente (se for
através de uma automação, é ainda melhor).

## Runtime errors

É sempre bom lembrar que, no pior dos casos (em situações "normais"), um erro só é capaz de afetar
partes dos sistema dependentes do processo no qual ele foi gerado (dada a independência entre os
processos).

### Error types

Há três classes de erros de execução: 
+ _error_ -> Retornado comumente quando a execução de determinado código é impossível. Ou através da
macro `raise/1` (`raise("Something went wrong")`)
+ _exit_ -> Utilizado para deliberadamente terminar um processo (`exit("I'm done with this!")`)
+ _throw_ -> Utilizado para dar returns em momentos "inesperados". Em geral não é uma boa prática
utilizar-se de throw's

Funções que podem gerar _errors_, por convenção, são denotadas com um ! no final.

### Handling errors

A sintaxe para se fazer um try-catch em Elixir é a seguinte:

```elixir

try do
    ...
catch error_type, error_value do
    ...
end
```

Onde `error_type` é `:error`, `:exit` ou `:throw` e `error-value` é o parâmetro passado na chamada 
que gera a exceção. Pode-se utilizar o mecanismo de pattern matching para lidar com diferentes tipos
de exceção:

```elixir
catch
    type_pattern_1, error_value_1 ->
        ...
    type_pattern_2, error_value_2 ->
        ...
end
```

O try-catch também aceita um bloco `after` que sempre executa, caso o try ou catch sejam 
bem-sucedidos. Entretanto, o retorno vem sempre do `try` ou do `catch`

```elixir
try
    ...
catch type, value
    ...
after
    ...
end
```

Em Elixir, como dito anteriormente, é comum só deixar processos crasharem e reiniciar os mesmos com
um estado novo. Muitos dos erros se devem a estados corruptos ou indesejados e resetá-los costuma
fazer com que as funcionalidades voltem a operar corretamente. É importante, portanto, logar o erro
para se corrigir sua causa raiz e permitir que o sistema se recupere de uma falha inesperada.

## Errors in concurrent systems

É razoável de se pensar que, por mais que se tome bastante cuidado com o isolamento entre processos,
a nível de domínio, algumas funcionalidades dependem de outras. 

### Linking processes

Nesse contexto é necessário criar ligações entre processos: quando um cair, o processo "adjacente" 
deve ser informado e tomar alguma ação para lidar com a falha. Pode-se implementar este 
comportamento através de `spawn_link/1`

```elixir
spawn(fn ->
    spawn_link(fn -> 
        Process.sleep(1000)
        IO.puts("Process 2 finished")
    )
    
    raise("Something went wrong")
)
```

Neste caso, o `raise` é executado antes do processo linkado conseguir realizar a operação de IO.
Processos linkados (links são sempre bidirecionais) falham juntos, e o comportamento padrão é
cascatear a falha, derrubando todos os processos linkados em diversos níveis.

Fazer todos os links falharem em cascata pode não ser um comportamento muito útil. Mas _links_ podem
ser encarados como um canal de comunicação entre processos. Uma forma de informar um processo
linkado de um erro é através de um mecanismo chamado _trap exit_:

```elixir
spawn(fn ->
    Process.flag(:trap_exit, true)
    
    spawn_link(fn -> raise("Something went wrong!") end)
    
    receive do
        msg -> IO.inspect(msg)
    end
)
```

Um processo com a flag de `:trap_exit` recebe mensagens quando processos linkados crasham. Ao final
da execução do snippet acima, a exception obtida será printada.

### Monitors

_Links_ são bidirecionais. O análogo unidirecional do _link_ é o _monitor_. Para que o processo
atual monitore um processo de PID conhecido, pode-se utilizar a sintaxe:

```elixir
monitor_ref = Process.monitor(target_pid)
```

Novamente o esquema de mensagens garante que o processo monitor receba uma mensagem caso um processo
filho caia. Para parar o monitoramento, executa-se:

```elixir
Process.demonitor(monitor_ref)
```

Note que aqui o processo monitor não cai caso o filho seja derrubado.

## Supervisors
