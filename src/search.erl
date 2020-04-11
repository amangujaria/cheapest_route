-module(search).

-export([create_graph/0, cheapest/3, cheapest_ksteps/4]).

-type graph() :: digraph:graph().
-type gnode() :: string().

-spec create_graph() -> graph().
create_graph() ->
    DG = digraph:new(),
    A = digraph:add_vertex(DG, "A"),
    B = digraph:add_vertex(DG, "B"),
    C = digraph:add_vertex(DG, "C"),
    D = digraph:add_vertex(DG, "D"),
    digraph:add_edge(DG, A, B, {160, "red"}),
    digraph:add_edge(DG, A, C, {90, "red"}),
    digraph:add_edge(DG, A, D, {400, "red"}),
    digraph:add_edge(DG, A, B, {170, "blue"}),
    digraph:add_edge(DG, B, C, {50, "blue"}),
    digraph:add_edge(DG, B, D, {80, "blue"}),
    digraph:add_edge(DG, A, C, {140, "green"}),
    digraph:add_edge(DG, B, C, {30, "green"}),
    digraph:add_edge(DG, C, D, {160, "green"}),
    DG.

-spec cheapest(gnode(), gnode(), graph()) -> {integer(), list({string(), {gnode(), gnode()}})} | not_reachable.
cheapest(From, To, Graph) ->
    Dict = search(From, To, {0, []}, Graph, dict:new()),
    case dict:find(To, Dict) of
        error -> not_reachable;
        {ok, Val} -> Val
    end.

store(Key, {Cost, Paths}, Dict) ->
    case dict:find(Key, Dict) of
        error -> dict:store(Key, {Cost, Paths}, Dict);
        {ok, {SavedCost, _SavedPaths}} when SavedCost > Cost ->
            dict:store(Key, {Cost, Paths}, Dict);
        _ -> Dict
    end.

search(To, To, {_Cost, _Paths}, _Graph, Dict) -> Dict;
search(From, To, {BaseCost, Paths}, Graph, Dict) ->
    Edges = digraph:out_edges(Graph, From),
    Updated = lists:foldl(fun(Edge, Acc) ->
        {_, From, Next, {Cost, Color}} = digraph:edge(Graph, Edge),
        store(Next, {BaseCost + Cost, [{Color, {From, Next}} | Paths]}, Acc)
    end, Dict, Edges),
    lists:foldl(fun(Edge, Acc) ->
        {_, From, Next, {Cost, Color}} = digraph:edge(Graph, Edge),
        search(Next, To, {BaseCost + Cost, [{Color, {From, Next}} | Paths]}, Graph, Acc) 
    end, Updated, Edges).

-spec cheapest_ksteps(gnode(), gnode(), integer(), graph()) -> {integer(), list({string(), list({gnode(), gnode()})})} | cannot_move.
cheapest_ksteps(From, To, Num, Graph) ->
    try dict:fetch(To, cheapest_ksteps(From, To, Num, {0, []}, Graph, dict:new()))
    catch
        _:_ -> cannot_move
    end.

cheapest_ksteps(To, To, 0, {Cost, Path}, _, Dict) -> store(To, {Cost, Path}, Dict);
cheapest_ksteps(_From, _To, 0, _, _, Dict) -> Dict;
cheapest_ksteps(From, To, Num, {BaseCost, Paths}, Graph, Dict) ->
    Edges = digraph:out_edges(Graph, From),
    lists:foldl(fun(Edge, Acc) ->
        {_, From, Next, {Cost, Color}} = digraph:edge(Graph, Edge),
        cheapest_ksteps(Next, To, Num - 1, {BaseCost + Cost, [{Color, {From, Next}} | Paths]}, Graph, Acc)
    end, Dict, Edges).
