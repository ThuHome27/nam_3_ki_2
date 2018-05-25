length( [ ], 0).
length( [ _ | T], Kq) :- length(T,Kq1), Kq is Kq1 + 1.

greeting(van, hello) :- hello is 'chao'.
vua(hoa, nguoidoi).
