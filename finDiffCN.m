function oPrice = finDiffCN(X,S0,r,sig,Svec,tvec,oType)
% Function to calculate the price of a vanilla European
% Put or Call option using the Crank-Nicolson finite difference method
%
% oPrice = finDiffCN(X,r,sig,Svec,tvec,oType)
%
% Inputs: X - strike
%       : S0 - stock price
%       : r - risk free interest rate
%       : sig - volatility
%       : Svec - Vector of stock prices (i.e. grid points)
%       : tvec - Vector of times (i.e. grid points)
%       : oType - must be 'PUT' or 'CALL'.
%
% Output: oPrice - the option price
%
% Notes: This code focuses on details of the implementation of the
%        Crank-Nicolson finite difference scheme.
%        It does not contain any programatic essentials such as error
%        checking.
%        It does not allow for optional/default input arguments.
%        It is not optimized for memory efficiency, speed or
%        use of sparse matrces.

% Author: Phil Goddard (phil@goddardconsulting.ca)
% Date  : Q4, 2007

% Get the number of grid points
N = length(Svec)-1;
M = length(tvec)-1;
% Get the grid sizes (assuming equi-spaced points)
dt = tvec(2)-tvec(1);

% Calculate the coefficients
% To do this we need a vector of j points
j = 0:N;
sig2 = sig*sig;
aj = (dt/4)*(sig2*(j.^2) - r*j);
bj = -(dt/2)*(sig2*(j.^2) + r);
cj = (dt/4)*(sig2*(j.^2) + r*j);

% Pre-allocate the output
v(1:N+1,1:M+1) = nan;

% Specify the boundary conditions
switch oType
    case 'CALL'
        % Specify the expiry time boundary condition
        v(:,end) = max(Svec-X,0);
        % Put in the minimum and maximum price boundary conditions
        % assuming that the largest value in the Svec is
        % chosen so that the following is true for all time
        v(1,:) = 0;
        v(end,:) = (Svec(end)-X)*exp(-r*tvec(end:-1:1));
    case 'PUT'
        % Specify the expiry time boundary condition
        v(:,end) = max(X-Svec,0);
        % Put in the minimum and maximum price boundary conditions
        % assuming that the largest value in the Svec is
        % chosen so that the following is true for all time
        v(1,:) = (X-Svec(1))*exp(-r*tvec(end:-1:1));
        v(end,:) = 0;
end

% Form the tridiagonal matrix
C = -diag(aj(3:N),-1) + diag(1-bj(2:N)) - diag(cj(2:N-1),1);
[L,U] = lu(C);
D = diag(aj(3:N),-1) + diag(1+bj(2:N)) + diag(cj(2:N-1),1);

% Solve at each node
offset = zeros(size(D,2),1);
for idx = M:-1:1
    if length(offset)==1
        offset = aj(2)*(v(1,idx)+v(1,idx+1)) + ...
            cj(end)*(v(end,idx)+v(end,idx+1));
    else
        offset(1) = aj(2)*(v(1,idx)+v(1,idx+1));
        offset(end) = cj(end)*(v(end,idx)+v(end,idx+1));
    end
    v(2:N,idx) = U\(L\(D*v(2:N,idx+1) + offset));
end

% Calculate the option price
oPrice = interp1(Svec,v(:,1),S0);