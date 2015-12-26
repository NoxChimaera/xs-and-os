:- pce_global(@wnd, new(dialog('Xs and Os'))).

/* current player
 * param 1 {x, o}
 */
?- dynamic(player/1).

/* state of board cell
 * param 1 cell index [1..9]
 * param 2 {x, o}
 */
?- dynamic(cell/2).

/* pass control to another player
 * param 1 {x, o} current player
 */
passControl(x) :- retract(player(x)), assertz(player(o)), !.
passControl(o) :- retract(player(o)), assertz(player(x)), !.

init :- retractall(player(X)), assertz(player(x)), !.
initGUI:- 
  % create buttons
  send(@wnd, append, new(@layout, dialog_group(buttons, group))),
  send(@layout, append, new(@b1, button('Click', message(@prolog, move, @b1, 1)))),
  send(@layout, append, new(@b2, button('Click', message(@prolog, move, @b2, 2))), right),
  send(@layout, append, new(@b3, button('Click', message(@prolog, move, @b3, 3))), right),
  send(@layout, append, new(@b4, button('Click', message(@prolog, move, @b4, 4))), below),
  send(@layout, append, new(@b5, button('Click', message(@prolog, move, @b5, 5))), right),
  send(@layout, append, new(@b6, button('Click', message(@prolog, move, @b6, 6))), right),
  send(@layout, append, new(@b7, button('Click', message(@prolog, move, @b7, 7))), below),
  send(@layout, append, new(@b8, button('Click', message(@prolog, move, @b8, 8))), right),
  send(@layout, append, new(@b9, button('Click', message(@prolog, move, @b9, 9))), right),
  send(@layout, layout_dialog),
  send(@wnd, open).

/* draw cross
 * param X horizontal coordinate
 * param Y vertical coordinate
 * param W width
 * param H hight
 * param GW dialog gap width (horizontal offset)
 * param GH dialog gap height (vertical offset)
 */
drawX(X, Y, W, H, GW, GH) :-
  send(@wnd, display, new(D, line(W, H)), point(X + GW, Y + GH)),
  send(D, colour(red)), 
  send(@wnd, display, new(U, line(-W, H)), point(X + W + GW, Y + GH)),
  send(U, colour(red)).
  
/* draw nought
 * param X horizontal coordinate
 * param Y vertical coordinate
 * param W width
 * param H hight
 * param GW dialog gap width (horizontal offset)
 * param GH dialog gap height (vertical offset)
 */
drawO(X, Y, W, H, GW, GH) :-
  send(@wnd, display, new(O, ellipse(W, H)), point(X + GW, Y + GH)),
  send(O, colour(blue)).

% win lines
line(1, 2, 3).
line(1, 4, 7).
line(1, 5, 9).
line(2, 5, 8).
line(3, 6, 9).
line(4, 5, 6).
line(7, 5, 3).
line(7, 8, 9).
  
/* check if player is a winner
 * param P player
 */
win(P) :-
  line(A, B, C), cell(A, P), cell(B, P), cell(C, P), write_ln(P), !. 

/* show win message and reset the game
 * param P winner
 */
showWinMessage(P) :-
  new(D, dialog('Fin!')),
  send(D, append, text('Winner: ')),
  send(D, append, text(P), right),
  send(D, append, button(ok, and(message(D, destroy), and(message(@wnd, destroy)), message(@prolog, reset))), below),
  send(D, open).
  
% reset the game
reset :-
  retractall(cell(_, _)),
  free(@b1), free(@b2), free(@b3), 
  free(@b4), free(@b5), free(@b6), 
  free(@b7), free(@b8), free(@b9), 
  free(@layout).

/* handle player's move
 * param C clicked cell
 * param I cell index
 */  
move(C, I) :- 
  get(C, x, X), get(C, y, Y), 
  get(C, size, size(W, H)), get(@wnd, gap, size(GW, GH)),
  free(C), 
  (
    player(x) ->
      drawX(X, Y, W, H, GW, GH),
      assertz(cell(I, x))
    ;
      drawO(X, Y, W, H, GW, GH),
      assertz(cell(I, o))
  ), 
  player(P), 
  ( win(P) -> showWinMessage(P) ; passControl(_) ), !.
 
% start
go :-
  init, initGUI.