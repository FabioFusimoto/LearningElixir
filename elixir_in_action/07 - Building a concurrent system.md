# Building a concurrent system

Não há regras quadradas, mas certas convenções para separar módulos em arquivos:
+ Módulos "correlacionados" compartilhando prefixos: `Todo.Server` e `Todo.List`
+ Em geral utiliza-se um módulo por arquivo apenas (exceções feitas a módulos pequenos que só fazem
sentido existir como dependência de outros)
+ Os arquivos refletem os nomes dos módulos: `Todo.Server` -> *todo_server.ex* ou residir num
subdiretório que agrupe os módulos *lib/todo/server.ex*

O approach mais comum para escalabilidade é executar um server para cada instância do recurso que o
mesmo implementa (ao invés de ter uma entidade que seja a abstração de uma lista de instâncias, ou
algo parecido).

O fato dos processos executarem sequencialmente tem o benefício de que o estado dos mesmos é
previsível / consistente. É impossível gerar race conditions dentro de um processo.

## Addressing the process bottleneck

Há uma série de razões para se colocar código em processos (ao invés de módulos puros):
+ É possível manter um estado (que pode persistir indefinidamente)
+ Quando se gerencia um recurso que deve ser reutilizado (conexão com BD, por exemplo)
+ Uma seção crítica do código precisa ser sincronizada

Mas está tudo bem usar um módulo puro caso os requisitos acima mencionados não façam parte da
aplicação.

Existe a possibilidade também de lidar com requisições de forma concorrente, isto é, fazer com que
os handlers, ao invés de fazerem todo o handling sequencialmente, spawnem um processo que lide com
o workload pesado (respondendo para o caller o mais rápido possível).

Outro approach é utilizar uma estratégia de pooling. Isto é, o processo servidor gerir um conjunto
de pequenos workers escaláveis e revezar a carga de trabalho entre eles (isso mantém o grau de
concorrência sob controle, isto é, impede de criar novos processos desgovernadamente).

Considerações gerais sobre processos / GenServers:
+ GenServers atuam de fato como pequenos serviços independentes
+ A cooperação entre servers se dá através de _calls_ ou _casts_
+ _calls_ tendem a reduzir a performance global da aplicação (blocking), mas garantem estabilidade
e consistência
+ _casts_ podem ser mais performáticas (non-blocking), mas não há como garantir, por métodos 
"normais" que o resultado esperado foi o obtido
