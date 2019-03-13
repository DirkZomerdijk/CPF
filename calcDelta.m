X = 99;
S0 = 100;
r = 0.06;
sig = 0.2;

dt = 1/10000;
Smax = 300
Smin = 0
ds = (Smax-Smin)/N

Svec = 0:1:Smax;
tvec = 0:dt:1;

d = zeros(N,M);
for n = 1 : M
    for j = 2 : N-1
        S = Svec(j);
        d(j,n) = ((v(j+1,n) - v(j-1,n))/(ds*2));
    end
end

interp1(Svec(2:end),d(:,1),S0)