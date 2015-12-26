:- pce_global(@wnd, new(dialog('Xs and Os'))).

?- dynamic(player/1).
?- dynamic(cell/2).

switchPlayer(x) :- retract(player(x)), assertz(player(o)), !.
switchPlayer(o) :- retract(player(o)), assertz(player(x)), !.

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

go :-
  init, initGUI.
  
drawX(X, Y, W, H, GW, GH) :-
  send(@wnd, display, new(D, line(W, H)), point(X + GW, Y + GH)),
  send(D, colour(red)), 
  send(@wnd, display, new(U, line(-W, H)), point(X + W + GW, Y + GH)),
  send(U, colour(red)).
  
drawO(X, Y, W, H, GW, GH) :-
  send(@wnd, display, new(O, ellipse(W, H)), point(X + GW, Y + GH)),
  send(O, colour(blue)).
  
line(1, 2, 3).
line(1, 4, 7).
line(1, 5, 9).
line(2, 5, 8).
line(3, 6, 9).
line(4, 5, 6).
line(7, 5, 3).
line(7, 8, 9).
  
win(P) :-
  line(A, B, C), cell(A, P), cell(B, P), cell(C, P), write_ln(P), !. 

showWinMessage(P) :-
  new(D, dialog('Fin!')),
  send(D, append, text('Winner: ')),
  send(D, append, text(P), right),
  send(D, append, button(ok, and(message(D, destroy), and(message(@wnd, destroy)), message(@prolog, restart))), below),
  send(D, open).
  
restart :-
  retractall(cell(_, _)),
  free(@b1), free(@b2), free(@b3), 
  free(@b4), free(@b5), free(@b6), 
  free(@b7), free(@b8), free(@b9), 
  free(@layout).
  
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
  ( win(P) -> showWinMessage(P) ; switchPlayer(_) ), !.
 