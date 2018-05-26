:- module(support, [already_played/3,del/3, remove/3, winningCheck/2, alphabeta/7]).




tris(X):- member(X, [ [1,2,3], [4,5,6], [7,8,9],

		      [1,4,7], [2,5,8], [3,6,9],

		      [1,5,9], [3,5,7] ]).


winning_combinations([  [1,2,3], [4,5,6], [7,8,9],
		  	[1,4,7], [2,5,8], [3,6,9],
	        	[1,5,9], [3,5,7] ]).



winningCheck(ST, Player):-
	tris(Comb),
	playedInListPos(ST,Player,Comb).


otherPlayer(x,o):-!.
otherPlayer(o,x):-!.


playedInListPos(_,_,[]).

playedInListPos(ST, X, [H|T]):-
	member(played(H,X), ST),
	playedInListPos(ST, X, T).

already_played([],_,[]):-!.

already_played([played(NH,X)|T],X,[NH|NT]):-!,
	already_played(T,X,NT).

already_played([_|T],X,List):-
	already_played(T,X,List).

/* ALPHABETA */
alphabeta(Node,Move,_Alpha,_Beta,_Turn,Depth,[Move,H]):-

		(	Depth=0;

			winningCheck(Node,o);

			winningCheck(Node,x);

			(already_played(Node,k,PosLibere),

			PosLibere = [])

		)
		-> (!,

			winning_combinations(Comb),

			recursive_heuristic(Node,Comb,H)
		
		).


alphabeta(Node, _Move, Alpha, Beta, Turn, Depth, Heur):-!, 
	already_played(Node,k,Moves),
	(Turn=o -> ActualV = [[invalidMove],-inf] ; ActualV = [[invalidMove],+inf]),
	iterator(Node,Moves,Alpha,Beta,Turn,Depth,Heur,ActualV).

/* ITERATOR */

iterator(_Node,[],_Alpha,_Beta,_Turn,_Depth,H,H):-!.

iterator(_Parent, _ListMoves, Alpha, Beta, _Turn, _Depth, H, H):-
	minnn(Beta,Alpha, Min), Beta=Min, !.

iterator(Parent, [Head|Tail],Alpha, Beta, o, Depth,Heur, ActualV):- 
	!,
	new_state(Parent,Head, o,Node),
	NewDepth is Depth - 1,
	alphabeta(Node,Head, Alpha, Beta, x, NewDepth, [_ExMove,Temp]),
	maxcc(ActualV,[Head,Temp],NewV),
	maxnc(Alpha, NewV, NewAlpha),
	iterator(Parent,Tail, NewAlpha, Beta, o, Depth, Heur, NewV).

iterator(Parent, [Head|Tail],Alpha, Beta, x, Depth,Heur, ActualV):- 
	!,
	new_state(Parent,Head, x,Node),
	NewDepth is Depth - 1,
	alphabeta(Node, Head, Alpha, Beta, o, NewDepth, [_ExMove,Temp]),
	mincc(ActualV,[Head,Temp],NewV),
	minnc(Beta, NewV, NewBeta),
	iterator(Parent,Tail, Alpha, NewBeta, x, Depth, Heur, NewV).



/*********NEW STATE*********/

new_state(St,Pos,Turn,NewSt):-
	
	del(played(Pos,k),St, St1),

	append([played(Pos,Turn)],St1,NewSt).

/************** HEURISTIC *******************/

recursive_heuristic(St,[Comb],H):-!,

	heuristic(St,Comb,H).


recursive_heuristic(St,[Comb1|Comb2],H3):-

	heuristic(St,Comb1,H1),

	recursive_heuristic(St,Comb2,H2),

	H3 is H2 + H1.

heuristic(St,[E0,E1,E2],H):-

	(member(played(E0,o),St) -> V1=1;V1=0),

	(member(played(E0,x),St) -> EV1=1;EV1=0),

	(member(played(E1,o),St) -> V2 is V1+1 ; V2=V1),

	(member(played(E1,x),St) -> EV2 is EV1+1 ; EV2=EV1),

	(member(played(E2,o),St) -> My is V2+1 ; My=V2),

	(member(played(E2,x),St) -> Enemy is EV2+1 ; Enemy=EV2),
	
	Temp1 is 100 ^ My,

	Temp2 is -(100 ^ Enemy),

	(((My=0,Enemy=0);(My>0,Enemy>0)) -> (H=0);true),

	(((My=0;Enemy=0), var(H)) -> H is Temp1 + Temp2;true).



/************* LIST MANAGEMENT *****************/


remove([], S0, S0):-!.

remove([X|Tail], S0, S1):-

	remove(Tail, S0, S2),

	del(X, S2, S1).



del(_X,[],[]):-!.

del(X,[X|Tail],Tail):-!.


del(X,[Y|Tail],[Y|Tail1]):-

	del(X,Tail,Tail1).

/***** MIN AND MAX VALUE *****/
mincc(EL,[_, +inf], EL):-!.
mincc([_, +inf], EL, EL):-!.
mincc([X,-inf], _, [X,-inf]):-!.
mincc(_,[X,-inf], [X,-inf]):-!.
mincc([El,X], [_,Y], [El,X]):- X=<Y, !.
mincc(_,E,E).


minnc(_, [_,-inf], -inf):-!.
minnc(-inf, _, -inf):-!.
minnc(+inf,[_,X], X):-!.
minnc(X,[_,+inf], X):-!.
minnc(X, [_,Y], X):- X=<Y, !.
minnc(_,[_,E],E).

minnn(_,-inf,-inf):-!.
minnn(-inf,_,-inf):-!.
minnn(+inf,X,X):-!.
minnn(X,+inf,X):-!.
minnn(A,B,A):- A =< B, !.
minnn(_,B,B):-!.

maxcc([X,+inf],_,[X,+inf]):-!.
maxcc(_,[X,+inf],[X,+inf]):-!.
maxcc(EL,[_,-inf],EL):-!.
maxcc([_,-inf],EL, EL):-!. 
maxcc([El,X], [_,Y], [El,X]):- X>=Y, !.
maxcc(_,E,E).



maxnc(_, [_,+inf], +inf):-!.
maxnc(+inf, _, +inf):-!.
maxnc(-inf,[_,X], X):-!.
maxnc(X,[_,-inf], X):-!.
maxnc(A,[_,B], A):- A>=B, !.
maxnc(_,[_,X],X):-!.

maxnn(_,+inf,+inf):-!.
maxnn(+inf,_,+inf):-!.
maxnn(-inf,X,X):-!.
maxnn(X,-inf,X):-!.
maxnn(A,B,A):- A >= B, !.
maxnn(_,B,B):-!.

