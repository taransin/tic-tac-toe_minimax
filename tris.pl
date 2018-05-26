:- use_module(support).
:- dynamic won/1.

player(x).
player(o).

/*player interface*/
vai :-
	retractall(won(_)),
	starting_state(S0),
	printScreen(S0),
	step(S0).

/*starting state*/
starting_state([played(1,k), played(2,k), played(3,k),
		played(4,k), played(5,k), played(6,k),
		played(7,k), played(8,k), played(9,k), aiTurn]) :-
	Rand is random(2),
	Rand==0,!.

starting_state([played(1,k), played(2,k), played(3,k),
		played(4,k), played(5,k), played(6,k),
		played(7,k), played(8,k), played(9,k), playerTurn]).

/*final state*/
trovato(ST) :- player(X), winningCheck(ST, X), !,assert(won(X)).
trovato(ST) :- already_played(ST,k,L),L=[],assert(won(no_one)).

/*game moves*/
play(ST, [playerTurn, played(Move,o)],[aiTurn, played(Move,k)]) :-
	member(aiTurn, ST),
	alphabeta(ST,_,-inf,+inf,o,5,[Move,_H]).


play(ST, [aiTurn, played(P,x)],[playerTurn, played(P,k)]) :-
	member(playerTurn, ST),
	ask(P),
	member(played(P, k), ST).


ask(X) :-
	prompt1('scegliere la posizione in cui giocare: '),
	readln(Z),
	nth0(0,Z,X,_R).

step(S0):-
	trovato(S0),!,
	printScreen(S0).

step(S0):-
	play(S0, Fluent2Add, Fluent2Remove),
	remove(Fluent2Remove, S0, Temp1),
	append(Fluent2Add, Temp1, NewState),
	printScreen(NewState),
	step(NewState).


/* STAMPA SU SCHERMO */


printScreen(X):-
	clearScreen,
	printPlayer(X,7),
	write(' | '),
	printPlayer(X,8),
    write(' | '),
	printPlayer(X,9),
	writeln('               7 | 8 | 9'),
	writeln('---------               ---------'),
	printPlayer(X,4),
	write(' | '),
	printPlayer(X,5),
    write(' | '),
	printPlayer(X,6),
	writeln('               4 | 5 | 6'),
	writeln('---------               ---------'),
	printPlayer(X,1),
	write(' | '),
	printPlayer(X,2),
    write(' | '),
	printPlayer(X,3),
	writeln('               1 | 2 | 3'),
	((won(no_one),!, writeln("Non ha vinto nessuno"));
	(won(Player),!, format('ha vinto: ~w ~n',[Player]));true).

printPlayer(St, Pos):-
	member(played(Pos, Pl), St),
	(
		(Pl=x,!, ansi_format([bold, fg(green)], 'x', []));
		(Pl=o,!, ansi_format([bold, fg(red)], 'o', []));
		(write(' '))
	).


clearScreen :-
	format('~n~n~n~n~n~n~n~n~n~n~n~n~n~n~n~n~n~n~n~n',[]).

