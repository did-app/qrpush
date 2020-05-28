-module (qr_push_native).
-export ([int_to_32bits/1, int_from_32bits/1]).

int_to_32bits(I) ->
  <<I:32>>.

int_from_32bits(<<I:32>>) ->
  I.
