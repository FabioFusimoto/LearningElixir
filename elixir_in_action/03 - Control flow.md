# Capítulo 3 - Control Flow

## Pattern matching
O binding de variáveis a valores é possível através de uma mecânica nomeada 'Pattern matching'. O o-
perador `=` é responsável pelo match. Nomenclaura => *pattern* = *term*. 

### Matching tuples
Isto é útil para fazer destructuring em estruturas de dados mais complexas. 
Ex: `{name, age} = {"Bob", 25'}`. Ao fazer o matching, o valor retornado é o da expressão avaliada.

Matching pode ser útil também quando se espera que determinado elemento de uma estrutura tenha um
valor conhecido (uma espécie de assert estrutural). Por exemplo:

`person = {:person, "Bob", 25}` => {:person, name, age}
`{:person, name, age} = person` => {:person, name, age}
`name` => "Bob"
`age` => 25

Caso o match não fosse obtido, haveria uma exception. Algo do tipo: `{MatchError} ...`

Para ignorar um elemento do match, pode-se utilizar uma *anonymous variable* => `_`. Ou qualquer
nome de variável iniciada por `_`, que fará com que o binding não aconteça.

Pode-se fazer o pattern matching com variáveis ao invés de literais. Para isso, utiliza-se o *pin
operator* (`^`).

```elixir
expected_name = "Bob"
{^expected_name, _} = {"Bob", 25}
```

Não causa nenhum tipo de exceção.

### Matching lists
O pattern matching de listas funciona da mesma forma que para as tuplas. Apenas deve-se utilizar 
`[]` ao invés de `{}`. Pode-se usar a sintaxe`[head | tail]` para desestruturar.

```elixir
[head | tail] = [1, 2, 3, 4]
head == 1
tail == [2, 3, 4]
```

### Matching maps
Pode-se fazer o match de apenas chaves de interesse.
```elixir
%{age: age_value} = %{name: "Bob", age: 25}
age_value == 25
```

### Matching strings
Pode-se fazer match de elementos específicos da string (no início, por exemplo).

```elixir
full_command = "mkdir learning_elixir"
"mkdir" <> directory = full_command
directory == "learning_elixir"
```

### Compound matching
É possível fazer o match de mais de uma variável por vez. As operações ocorrem de forma comutativa,
ou seja, a ordem não importa (contanto que a expressão a ser avaliada esteja do lado direito).

```elixir
date_time = {_, {_, hour, _}} = :calendar.local_time()
date_time == {{2021, 07, 06}, {19, 43, 15}}
hour == 19
```

### Matching with functions
Pode-se usufruir do pattern matching na declaração de argumentos de uma função.

### Multiclause functions
É possível construir múltiplas definições (*clauses*) para uma mesma aridade de uma mesma função,
contanto que haja um argumento cujo match consiga definir qual das implementações a ser usada. O
primeiro match encontrado é utilizado. É possível introduzir um caso default (cujo match sempre da-
rá certo, por definição de pattern matching) e fazer o tratamento adequado.

```elixir
defmodule Geometry do
    def area({:rectangle, a, b}) do
        a * b
    end
    
    def area({:circle, r}) do
        r * r * 3,14
    end
    
    def area(unknown_shape) do
        {:error, {:unknown_shape, unknown_shape}}
    end
end

Geometry.area({:rectangle, 50, 5}) == 250
Geometry.area({:circle, 4}) == 50.24
```

### Guards
Se o pattern matching não fornecer mecanismos o suficiente para determinar qual implementação da
função a se utilizar, pode-se escrever expressões *guards* para desambiguar.

```elixir
defmodule TestNum do
    def test(x) when x < 0 do
        :negative
    end
    
    def test(0), do :zero
    
    def test(x) when x > 0 do
        :positive
    end
end
```

Os *guards* aceitam poucas famílias de funções apenas: operadores de comparação, booleanos, arit-
méticos e funções de check de tipo (`Kernel.is_number/1`, por exemplo). Funções definidas pelo u-
suário não são aceitas.

### Multiclause lambdas
Funções anônimas também podem ter múltiplas clauses:

```elixir
test_num =
    fn
        x when is_number(x) and x < 0 ->
            :negative
            
        0 -> :zero
        
        x when is_number(x) and x > 0 ->
            :positive
    end
```

## Conditionals
Funções com múltiplas *clauses* podem ser muito úteis para definir funções recursivas. E a faci-
lidade em criar uma recursão pode ser explorada para construir loops de forma não usual (se toma-
das as linguagens imperativas como base).

```elixir
defmodule Math do
    def fact(0), do: 1
    def fact(n), do: n * fact(n - 1)
end

defmodule ListHelper do
    def sum([]), do: 0
    def sum([first | rest]), do: first + sum(rest)
end
```

### Classical branching constructs
Pode-se utilizar o `if ... else` ou `unless ... else` (que equivale ao `if (not ...) else ...`)

A macro `cond` avalia o primeiro corpo cuja expressão condicional seja verdadeira:

```elixir
cond do
    expression_1 ->
        ...
    
    expression_2 ->
        ...
    ...
end
```

O `case` tem uma sintaxe parecida, mas usa patterns ao invés de expressões. Tem a mesma funcionali-
dade do pattern matching com múltiplos clauses.

### The with special form
Útil para se quando múltiplos patter matchings aninhados forem necessários. Executa-se o bloco `do`
caso todos os matches derem positivo. Caso contrário, retorna o primeiro termo que não deu match.

```elixir
with {:ok, login} <- {:ok, "alice"}
     {:ok, email} <- {:ok, "mail@mail.com"} do
       %{login: login, email: email}
end
```

## Loops and iterations
As iterações normalmente são resolvidas por recursão. Não temos um bloco dedicado de `while` ou
`do ... while`. Erlang tem um tratamento otimizado para recursão através de *tail-call recursion*,
que significa chamar a função de recursão como a última. Expressões que envolvem uma chamada de
função não contam como uma *tail-call recursion*, uma vez que o último valor avaliado é o resul-
tado da expressão e não da função em si. `ListHelpers.sum/1` (da seção de *Conditionals*) é uma 
ilustração deste caso

TENTAR IMPLEMENTAR AS SEGUINTES FUNÇÕES UTILIZANDO RECURSÃO E PATTERN MATCHING
- A `list_len/1` function that calculates the length of a list
- A `range/2` function that takes two integers, from and to, and returns a list of all
numbers in the given range
- A `positive/1` function that takes a list and returns another list that contains only
the positive numbers from the input list

O autor recomenda implementá-las primeiramente como uma recursão normal e depois com uma *tail-
recursion*.

### Higher-order functions
Além da recursão clássica, muitas operações repetitivas podem ser resolvidas com *higher-order
functions*, que nada mais são do que funções que tomam funções como argumentos. `Enum.each/2` é
um exemplo deste tipo (internamente ela é implementada através de recursão, mas esta fica implí-
cita neste caso e torna o código mais legível). Algumas funções do módulo `Enum` relevantes:

- `each`: Executa a função para cada elemento passado
- `map`: O mesmo do Clojure
- `filter`: Mantém apenas os elementos cuja expressão avalia para `true` (não o truthy values)
- `reduce(enumerable, initial_acc, fn element, acc -> ... end)`: Para se escrever uma soma de ele-
mentos de uma lista, pode-se escrever `Enum.reduce([...], 0, &+/2)` (especificamente para o caso da
soma, há no módulo `Enum` que aplica a soma a um enumerable -> `Enum.sum/1`)

### Comprehensions
Uma sintaxe alternativa para executar uma expressão e retornar o resultado como uma lista. Mas, ao
invés de executar para cada elemento, faz-se um produto cartesiano dos elementos fornecidos (como 
faz o `doseq` em Clojure).

```elixir
for x <- [1, 2, 3], y <- [1, 2, 3], do: {x, y, x*y}

[
{1, 1, 1}, {1, 2, 2}, {1, 3, 3},
{2, 1, 2}, {2, 2, 4}, {2, 3, 6},
{3, 1, 3}, {3, 2, 6}, {3, 3, 9}
]
```

O resultado de um bloco de *comprehension* não precisa ser uma lista. Qualquer *collectable* serve
(listas, mapas e map sets são exemplos). Para especificar o formato do *collectable*, utiliza-se a
opção `into`:

```elixir
multiplication_table =
    for x <- 1..9, y <- 1..9,
        into: %{} do
            {{x, y}, x*y}
        end
```

A estrutura de map consegue interpretar a estrutura `{chave, valor}` retornada pelo bloco `do` den-
tro do `into` e monta um mapa de acordo. Por exemplo, `multiplication_table[{6, 7}]` retorna 42.
É possível especificar um filtro para quando a *comprehension* deve ser computada. O mesmo deve ser
descrito após as cláusulas de `for`. Exemplo: `for x <- 1..9, y <- 1..9, x <= y, into: ...`

### Streams
*Streams* são *enumerables* que facilitam a composição de operações em outros *enumerables*. A van-
tagem das *streams* sobre as funções do módulo `Enum` é que os resultados são lazy (isto é, não são
computados até que seja explicitamente necessário, por uma operação eager, como as do `Enum`).

```elixir
stream = 
    [2, 4, 6]
    |> Stream.map(fn x -> 2 * x end)
    
eager_list = Enum.to_list(stream)
```

Pelos elementos serem lazy, é possível computar apenas um deles por vez. Fazendo `Enum.take`, por
exemplo (não é necessário calcular todos os valores se apenas um é utilizado).
Streams são bastante úteis para se ler arquivos textuais, por exemplo: é possível se ter em memó-
ria apenas os elementos úteis, e não todas as linhas do arquivo (onde cada uma ocupa uma posição da
lista). A função `File.stream!/1` lê um arquivo e retorna o conteúdo de suas linhas numa *stream*.
