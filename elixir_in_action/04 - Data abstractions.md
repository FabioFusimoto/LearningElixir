# Capítulo 4 - Data abstractions

Como de costume para as linguagens funcionais, dados e funções estão segregados. "Dados" não são
capazes de chamar métodos. Ao invés disso, funções que manipulam um certo tipo de dado estão
agrupadas num módulo específico. Ex: `String`, `List` ou `Enum`.

## Abstracting with modules
Módulos não são tipos definidos pelo usuário. Por baixo dos panos, são apenas abstrações que
utilizam os primitivos já existentes da linguagem (o `MapSet` é um exemplo).

Geralmente, opta-se por construir abstrações aninhadas (módulos baseadas em outros módulos) e, neste
âmbito, não é muito diferente do que se faz em OO (o que muda é que as abstrações são stateless e,
portanto, imutáveis).

## Abstracting with structs
Quando se precisa que "forçar" uma determinada estrutura, utiliza-se as `structs`. Cada módulo pode
definir uma struct associada. Isso é feito utilizando-se `defstruct`. Uma vez definida, tal struct
pode ser instanciada através de uma sintaxe especial.

```elixir
defmodule Fraction do
    defstruct a: nil, b: nil
    ...
end

one_half = %Fraction{a: 1, b: 2}
```

Uma `struct` é implementada através de um mapa, então é possível acessa os elementos com a sintaxe
`one_half.a`, por exemplo. Pattern match também é aplicável `%Fraction{a: num, b: den} = one_half`.
É possível garantir que determinado valor é de uma struct esperada fazendo-se um Pattern match
especial (que não funcionaria para mapas normais) -> `%Fraction{} = one_half` não resulta num erro.

Algumas coisas que se faz com mapas não funcionam para structs. Funções do módulo `Enum` são um
exemplo (se o módulo em que está definida a `struct` não implementa diretamente o protocolo que
se quer chamar, as chamadas falham). Entretanto, como `structs` são implementadas através de mapas,
as funções do módulo `Map` operam sem erros.

Vale a pena notar que todos os dados transmitidos através de uma struct (ou qualquer outra estrutura
de dados em Elixir) são públicos e podem ser acessados individualmente, se necessário. Apesar da
estrutura ser sempre transparente, ao utilizar as abstrações, o desenvolvedor não deve utilizar os
detalhes de estruturação para o desenvolvimento (uma boa prática). Deve-se confiar nas funções
definidas no módulo que as contém.

## Working with hierarchical data
Quando se realiza um update numa estrutura de dados nested, a versão nova e a antiga da variável
"modificada" compartilham a maior quantidade de memória possível, isto é, toda a parte que
permanece inalterada (assumindo que se esteja trabalhando com mapas).

A abstração que torna fácil de enxergar os dados é a de uma árvore, sendo que cada função do
módulo é responsável por alterar uma camada dessa árvore; para que uma sequência de
transformações possa ser descrita através de um pipe `|>`.

Há uma maneira mais fácil de se atualizar elementos que estão em locais da estrutura. Para mapas,
pode-se utilizar a macro `Kernel.put_in/2`, que anda recursivamente pela estrutura, alterando o
nó filho desejado e mantendo os demais:

``` elixir
todo_list = %{
    1 => %{date: ~D[2018-12-18], title: "Dentist"},
    2 => %{date: ~D[2018-12-19], title: "Shopping"},
    3 => %{date: ~D[2018-12-20], title: "Movies"},
}
```

Pode-se executar `put_in(todo_list[3].title, "Theater")` para se obter um mapa "atualizado":

``` elixir
%{
    1 => %{date: ~D[2018-12-18], title: "Dentist"},
    2 => %{date: ~D[2018-12-19], title: "Shopping"},
    3 => %{date: ~D[2018-12-20], title: "Theater"},
}
```

Da mesma forma, pode-se utilizar as macros `get_in/2` e `update_in/2` para ler e atualizar um valor
dentro de uma estrutura nested. Há também uma implementação `put_in/3` onde o primeiro argumento é
a estrutura a se atualizar, o segundo é o caminho a ser percorrido e o terceiro é o valor a ser
inserido. `put_in(todo_list[3].title, "Theater")` e `put_in(todo_list, [3, :title], "Theater")` são
equivalentes.

## Polymorphism with protocols
Polimorfismo é uma decisão em runtime de sobre qual código executar, baseado na natureza do input
de dados. Em elixir, para atender ao polimorfismo, utiliza-se `protocols` (similar ao que se faz
com interfaces em POO). Para implementar uma função declara num protocolo, utiliza-se o `defimpl`.

```elixir
defimpl String.Chars, for: Integer do
    def to_string(term) do
        Integer.to_string(term)
    end
end
```

A definição do tipo para qual o protocolo está sendo implementado (`Integer`, no exemplo) pode ser
qualquer primitivo da linguagem: Tuple, Atom, Integer, Float, etc. Pode-se utilizar o "tipo" Any
como fallback, caso nenhum dos outros tipos tenha um match. Além disso, o tipo pode ser qualquer
alias arbitrário (o nome de um módulo definido na aplicação, por exemplo). A implementação dos
protocolos pode ser feita mesmo fora de um módulo: isso significa que se pode definir funções para
tipos cujo código-fonte nem mesmo está acessível.

O elixir possui uma série de protocols built-in: `String.Chars`, `List.Chars`, `Enumerable`, 
`Collectable`.
