/* gia tri viet thuong, bien viet bat dau bang chu hoa */
sunny.
learn(thu, prolog).
user(1, thu, 21, haiphong).
user(2, tien, 25, Homtown). /* neu viet ten bien tuc la
 				nhan gia tri bat ki */

fun(X) :- red(X), car(X).
fun(X) :- blue(X), bike(X).
car(vw).
car(ford).
bike(harley).
red(vw).
blue(ford).
blue(harley).

sum(S, X, Y) :- S is X + Y.
dif(D, X, Y) :- D is X - Y.

/* list */
p([H|T], H, T).

/* check if something is a member of a list */
on(I, [I|T]).
on(I, [H|T]) :- on(I, T). 

/* noi ghep 2 list */
append([], List, List).
append([H|T], List2, [H|Result]) :- append(T, List2, Result).

/* length */
len([], 0).
len([H|T], Len) :- len(T, Len1), Len is Len1 + 1.

/* delete all value*/
del([], Value, []).
del([Value|T], Value, Re) :- del(T, Value, Re). 
del([H|T], Value, [H|Re]) :- del(T, Value, Re). 

/* replace all value by a new value*/
rep([], O, N, []).
rep([O|T], O, N, [N|Re]) :- rep(T, O, N, Re).
rep([H|T], O, N, [H|Re]) :- rep(T, O, N, Re).










	