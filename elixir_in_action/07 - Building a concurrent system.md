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
