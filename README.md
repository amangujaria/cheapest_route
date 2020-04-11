# cheapest_route
a utility to find the cheapest route between two locations (both with and without the number of hops restriction)

Usage
-----
- Create a graph of the travel network using digraph. Sample: `Graph = search:create_graph()`. Every edge in the graph should have a Cost-Label tuple value.
- Find cheapest route between two locations on the network using `search:cheapest(From, To, Graph)`
- Find cheapest route between two locations on the network in a given number of hops using `search:cheapest_ksteps(From, To, NumSteps, Graph)`
