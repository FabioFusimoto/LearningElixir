# Concurrency primitives
Paralelismo / concorrência em Elixir se dá aproveitando os recursos da BEAM (que, por sua vez,
depende de Erlang para ter escalabilide e tolerância à falhas).

## Concurrency in BEAM
Três princípios para construir serviços de altíssima disponibilidade:
+ Tolerância à falhas: minimizar, isolar e ter a capacidade de recuperar-se de erros de runtime
+ Escalabilidade: aumentar a carga implica em aumentar a qtd de hardware (e não o código executado)
+ Distribuição: executar o sistemas em múltiplas máquinas

A BEAM gerencia concorrência a partir de processos. Um processo da BEAM é bem mais leve que aquele
do Sistema Operacional. É o building block de outros artifícios de paralelismo. Alguns exemplos que
tornam necessários o paralelismo: lidar com múltiplas requisições simultâneas, manter um estado
compartilhado e rodar tarefas de processamento no background.

Processos são isolados uns dos outros, o que garante a tolerância à falhas: como não há memória
compartilhada, se um processo falhar, isso não impactará diretamente os demais. Além disso, 
processos podem trocar mensagens entre si (persistindo uma informação por quanto tempo ela for
necessária).

## Working with processes
Concorrência e paralelismo não são análogos. Duas coisas são concorrentes se seus contextos de
execução são independentes, mas isso não quer dizer que eles serão executados em paralelo (isso
depende do hardware em que se executa). No BEAM, executar código concorrente significa gerenciar
diferentes processos.

Funções relacionadas com processos retornam ou requerem um `pid` (representado usualmente por
`#PID<XX.XX.XX>`), que é o identificador do processo. Não há garantia de ordem de execução dos
processos.

Processos não compartilham memória (logo não tem estruturas de dados comuns entre eles): a troca de
dados é feita através de mensagens. O armazenamento destas mensagens funciona num esquema FIFO e a
remoção das mesmas se dá apenas quando são consumidas (entretanto, não há limite para a quantidade
de mensagens, cabem quantas a memória suportar). Para saber o `pid` do processo sendo executado,
pode-se utilizar a função `self/0`.

Para saber o destinatário das mensagens, é necessário informar o `pid`. A troca de mensagens é
orquestrada pelas funções (não sei se são funções, macros ou o que) `send` e `receive`. Quando o
`receive` ocorre e não há nenhuma pattern correspondente, a mensagem é colocada novamente na caixa
e consome-se a próxima (travando caso nenhuma mensagem possa ser consumida). Há uma proteção contra
bloqueio de thread na forma de um timeout (utlizando-se a sintaxe `after`):

```elixir
receive do
    message -> IO.inspect(message)
after
    5000 -> IO.puts("No message received")
end
```

Nota-se que, uma vez que a mensagem é enviada, aquele que o enviou não espera nenhum tipo de
resposta (estratégia "fire and forget"). O esquema de proceses puro não oferece uma solução que
ofereça uma "resposta" para o remetente. É necessário implementar um esquema de recebimento dos
dois lados para atingir esse propósito.

## Stateful server processes
Uma pattern comum na programação de servidores é ter processos que são executados durante um longo
período (ou mesmo durante toda a vida da aplicação) e que costumam manter um estado, o que lembra
os objetos de POO. A estes processos, dá-se o nome informal de _server processes_. Usualmente, tais
processos são implementados através de funções recursivas com múltiplos pattern matchings e que
chamam a si mesmas em seu término (_tail call recursion_).

```elixir
defmodule DatabaseServer do
    def start do
        spawn(&loop/0)
    end
    
    defp loop do
        receive do
            ...
        end
        
        loop()
    end
end
```

A função `start/0` é chamada de _interface function_, pois ela foi criada para ser invocada pelos
clientes (que querem fazer uso do módulo). A função `loop/0`, por sua vez, executa o código pelo
qual o módulo é responsável e é informalmente classificada como uma _implementation function_.

É importante perceber que _server processes_ são sequenciais. Se 5 ações forem requisitadas ao
server, elas serão executadas em sequência, não em paralelo. Este tipo de processo é considerado
como um "ponto de sincronização". Para se lidar com processamento paralelo, pode-se, por exemplo,
spawnar múltiplos servidores e distribuir a carga de trabalho entre eles (_round-robin_).

### Keeping a process state
Uma estrategia para manter um estado é propagá-lo para a próxima execução do `loop` (ou algo
equivalente, caso não se esteja executando uma recursão). Quando se usa tal método, o servidor, do
ponto de vista do cliente, é um processo _stateful_, apesar de, internamente, sem implementado
através de estruturas imutáveis.

```elixir
defmodule DatabaseServer do
    def start do
        spawn(fn ->
            initial_state = ...
            loop(initial_state)
        end)
    end
    
    defp loop(state) do
        new_state =
            receive do
                ...
            end
        
        loop(new_state)
    end
end
```

Uma tática interessante é manter um server para cada instância individual de estrutura de dados de
interesse (garantia de independência, concorrência e escalabilidade).

Nota-se que as interações entre processos são possíveis apenas quandos seus pids são conhecidos.
Para solucionar isso, pode-se dar nomes ao processos (que são identificáveis pelos demais que
estejam rodando dentro da mesma instância da BEAM). Para tal utiliza-se `Process.Register/2`:

```elixir
Process.register(self(), :process_name)

send(:process_name, :msg)

receive do
    msg -> IO.puts("Received -> #{msg}")
end
```

Os nomes dos processos podem ser apenas átomos. Um processo só pode ter um nome e um mesmo nome
não pode ser compartilhado entre os dois processos.

## Runtime considerations
_Server processes_ operam melhor quando têm apenas que lidar com gerenciamento de mensagens,
delegando a função adequada o mais rápido possível (de forma concorrente, quando fizer sentido 
sê-lo). Algumas anomalias comuns nos processos do Elixir:

+ Mailboxes que crescem "infinitamente": pode ser fruto de um processo que não consome as
mensagens num ritmo mais lento do que elas chegam; ou então não ter patterns que atendem à mensagem
recebida (que faz a mensagem ficar permanentemente estacionada e ocupando memória). Em casos
extremos, mailboxes muito grandes podem fazer sistemas inteiros quebrarem (quando não há mais 
memória disponível).
+ Troca de mensagens muito grandes: os processo não compartilham nenhum segmento da memória. Logo,
uma mensagem que passa de um processo para o outro cria uma cópia dos dados em memória. Este
processo costuma ser rápido, mas não devemos abusar: o ideal é manter a estrutura das mensagens o
mais simples possível (mais eficiente). Uma consequência é que o garbage collection se dá a nível
de processo (o que os torna mais rápidos e previsíveis).
