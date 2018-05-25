A = 2;
f = 200;
Fs = 10 * f;
N = 512;
n = [0:N-1];
xn = A * sin(2 * pi * f * n / Fs) + 2 * A * sin(2 * pi * (f + 400) * n / Fs);

X = xn .* hamming(N)';
Xf = fft(X);
XdB = 20 * log(abs(Xf) / max(abs(Xf)));
xf = fft(xn);
xdB = 20 * log(abs(xf) / max(abs(xf)));
fHz=n*Fs/N;
xlim([0 Fs/2]);
plot(fHz, XdB, fHz, xdB);



