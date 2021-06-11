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
