# Capítulo 2 - Building blocks

## Estruturas

### Variables
Não há tipos para as variáveis. Atribuir um valor à mesma é nomeado `binding`.
Convenção: nome iniciado por letra minúscula. Geralmente utiliza-se snake_case. Composta por 
caracteres alfanuméricos e pode terminar em '?' (indica que armazena um booleano) ou '!' também.

### Modules
Uma coleção de funções. Toda função é definida dentro de um `module` (como se fosse o namespace de
outras linguagens). A chamada à função de um module é como se fosse de qualquer outra linguagem.

```elixir
IO.puts("Hello World!")
```

Para definir um `module`, utiliza-se a macro `defmodule`
```elixir
defmodule Geometry do
    def rectangle_area(a, b) do
        a * b
    end
end
```

Convenção: os módulos devem começar com uma letra maiúscula e geralmente são escritos em
CamelCase. Pode haver '.' no nome do próprio módulo e os mesmos podem ser aninhados.

### Functions
Funções devem estar sempre dentro de `modules` e segue o mesmo nome das variáveis (snake_case).
O '?' no final indica que a função retorna um booleano e o '!' indica que a mesma pode gerar
um erro em tempo de execução. A utilização de parênteses para a chamada das funções é opcional.

### Function arity
Múltiplas aridades podem ser expressas dentro do mesmo módulo. São tratadas como funções diferentes.
Convenção para representação: `Module.function/n` (para a enésima aridade da função).

### Function visibility
A macro `def` assume que a função é pública e pode ser acessada de fora do módulo. Para funções
privadas, utilizar o `defp`

### Imports and aliases
É impossível importar módulos dentro de módulos e utilizar suas funções sem precisar do prefixo do
módulo, por exemplo:

```elixir
defmodule MyModule
    import IO
    
    def my_function do
        puts "Hello World!"
    end
end
```

Não é necessário fazer `IO.puts` no exemplo acima. Para aliases, a sintaxe é a seguinte:

```elixir
defmodule MyModule do
    alias IO, as: MyIO
end
```

### Module attributes
Servem para registrar constantes que podem ser acessadas em runtime. São utilizadas também como
metadados dos módulos e funções (para gerar documentação automática por exemplo). O atributo
`@moduledocs` é um destes exemplos.

```elixir
defmodule Circle do
    @moduledoc "Implements basic circle functions"
    @pi 3.14159
    
    @doc "Computes the area of the circle"
    def area(r) do
        r*r*pi
    end
end
```

### Comments
Indicados com o caractere '#' (similar aos do Python, comenta o resto da linha)

### Atoms
Constantes literais nomeadas. Inicia-se com um caractere ':' e segue com a convenção das
variáveis. É possível declarar `atoms` com espaços, por exemplo `:"atom with spaces"`.
Outra forma de definir atoms é omitindo o ':' e nomeando o atom em CamelCase.

```elixir
AnAtom
AnAtom == :"Elixir.AnAtom" 
```

`Atoms` são utilizados para booleanos também. Para ajudar, no elixir temos que `:true` é igual
a `true` e também `:false` é o mesmo que `false`. Isso vale também para o `:nil` (`nil`).

### Logical operators / Short-circuit operators
Para valores booleanos, é possível usar `and`, `or` e `not` . Para demais valores, utiliza-se os
*short-circuit operators* (`&&`, `||` ou `!`)

### Tuples
Utilizado para agrupar um número fixo de elementos (dá a entender que não redimensiona dinamica-
mente ?).

```elixir
person = {"Bob", 25}
```

Para tomar um elemento da tupla, usa-se `Kernel.elem` -> `age = elem(person, 1)`
Para "modificar" um elemento, usa-se `Kernel.put_elem` -> `new_person = put_elem(person, 1, 26)`

### Lists
Usado para gerenciar coleções de tamanho arbitrário/variável. As operações com listas costumam ter
complexidade O(n), pois são implementadas como listas ligadas.

Sintaxe:
```elixir
prime_numbers = [2, 3, 5, 7]
```

Operações com listas (é mais eficiente acessar/inserir itens no começo do que no final):
- Tamanho: `length(prime_numbers)` => 4
- Elemento: `Enum.at(prime_numbers, 3)` => 7
- Está ou não presente: `5 in prime_numbers` => true
- "Substituir" valor: `List.replace_at(prime_numbers, 0, 11)` => [11, 3, 5, 7]
- Inserir numa posição específica: `List.insert_at(prime_numbers, 3, 13)` => [2, 3, 5, 13, 7] (índice negativo para inserir no final)
- Concatenação: `[1, 2, 3] ++ [4, 5]` ou `[1 | [2, 3, 4]]` => [1 2 3 4 5]

### Maps
Armazenar par chave / valor. Sintaxe:

```elixir
squares = %{1 => 1, 2 => 4, 3 => 9}
other_squares = Map.new([{1, 1}, {2, 4}, {3 , 9}])

squares[2] == 4
Map.get(squares, 4) == nil
Map.get(squares, 4, :not_found) == :not_found

Map.put(squares, 4, 16) == %{1 => 1, 2 => 4, 3 => 9, 4 => 16}
```

As funções do módulo `Enum` também funcionam em mapas.
Comumente utiliza-se os `atoms` como chave de mapas, que possibilitam uma sintaxe mais sucinta.

```elixir
bob = %{name: "Bob", age: 25}
bob[:name] == "Bob"
bob.age == "Bob"
bob[:non_existing_key] == nil
```

Para atualizar valores em mapas cujas chaves são `atoms`, pode-se utilizar a sintaxe (tipo JS):
```elixir
%{bob | age: 26, name: "Bobbie"}
```
Mas não se pode utilizar essa construção para adicionar novas chaves

### Strings
Representadas entre as aspas duplas usuais " ". Para ter uma expressão avaliada dentro de uma
string, utiliza-se `#{}`. 
`Embedded expression - Pi = #{3 + 0.14}` => "Embedded expression - Pi = 3.14"

Strings podem ocupar múltiplas linhas. Também podem ser expressas por um `sigil`

`~s(This is also a string)` => "This is also a string" => Útil para colocar aspas em strings
`~S(Ignore \n \r)` => "Ignore \n \r" => Ignora os escape characters

A concatenação é feita através do operador `<>`
Outra forma é definir uma string através de uma lista de inteiros (caracteres). E tem os `sigils`
`~c` e `~C` equivalentes as das aspas duplas.
```elixir
'ABC' == [65, 66, 67]
```

### First-class functions (Lambda / Anonymous)
É possível ter funções associadas à variáveis. A sintaxe para funções anônimas é a seguinte:
```elixir
square = fn x ->
    x*x
end

square.(5) == 25
```
É possível omitir os parênteses dos argumentos da função se houver apenas um argumento (recomenda-
do). A chamada de funções anônimas se dá com um `.` e a lista de argumentos.

Funções podem ser explicitamente passadas como argumentos de funções, utilizando uma sintaxe es-
pecífica. Para imprimir cada valor da lista `[1, 2, 3]`, podemos fazer (notar o caractere & e a
aridade explícita):

```elixir
Enum.each(
    [1, 2, 3],
    &IO.puts/1
)
```

Outra forma de definir funções anônimas é em função do `&`:

```elixir
lambda = &(&1 * &2 + &3)

lambda.(2, 3, 4) == 10
```

Funções lambda podem acessar variáveis for do escopo de sua própria definição (desde que essas te-
nham sido previamente definidas, por razões óbvias). Se as variáveis que a lambda referenciam forem
rebindadas, a função lambda não sofrerá alterações (consistência :check:).

### Range
Uma sintaxe conveniente para gerar mapas de números contínuos => `1..3` gera um `Enum` de 3 posi-
ções que aceita outras operações associadas (como `in` ou `Enum.each`, por exemplo).

### Keyword lists
Caso particular de lista onde cada elemento é uma tupla de dois elementos (o primeiro é um `atom` e
o segundo pode ter qualquer valor). Permite uma sintaxe especial:

```elixir
[{:monday, 1}, {:tuesday, 2}, {:wednesday, 3}] == [monday: 1, tuesday: 2, wednesday: 3]
```

Permite a utilização do módulo `Keyword` => `Keyword.get(days, :monday) == 1`

### MapSet
É o hash-set do Clojure. A ordem de inserção não é preservada (como nas listas).

- Criação: `days = MapSet.new([:monday, :tuesday, :wednesday])`
- Verificar se determinado elemento existe: `MapSet.member?(days, :monday)`
- "Inserir" um elemento: `days = MapSet.put(days, :thursday)`

Também aceita operações do módulo `Enum`

### Times and Dates
Alguns módulos para esse propósito: `Date`, `Time`, `NaiveDateTime` (sem fuso) e `DateTime` (com 
fuso). Pode se utilizar `sigils` para declarar variáveis destes tipos.

```elixir
today = ~D[2021-06-05]
today.year == 2021
today.month == 6

time = ~T[08:50:15.00057]
time.hour == 8
time.second == 15

naive_datetime = ~N[2021-06-05 08:50:15.00057]
```

## Operadores
As operações aritméticas são expressas como esperado. Um detalhe é que todas as divisões e multipli-
cações retornam floats. Assim como JavaScript, há operadores de comparação fracos (`==` / `!=`) e
fortes (`===` / `!==`), também nomeados como estritos.

```elixir
1  == 1.0
1 !== 1.0
```

Operadores são funções do módulo `Kernel`. Temos que `a + b` é o mesmo que `Kernel.+ (a, b)`.

## Macros
Expressões avaliadas em compile time. Permitem a construção de mini DSLs (inspirados em LISP).

## Dinamically calling functions
A função `apply` pode ser utilizada para chamar funções dinamicamente em runtime. A ordem dos argu-
mentos é o padrão MFA (module, function, arguments). Como, em runtime, nomes de módulos são `atoms`,
a sintax é `apply(IO, :puts, ["Dynamic function call."])` que se compila da mesma forma que a chama-
da normal da função (`IO.puts("Dynamic function call.")`).
