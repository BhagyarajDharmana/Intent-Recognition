%%==================================================================%%
%%%function for derivative of a vector
%%% input should be in the form of ([x1;x2;.....;xn],deltaT)
%%%deltaT is time interval
%%for finding derivative atleast there should be two values
%%==================================================================%%
function [dotx] = derivative(X,deltaT)
dotx = zeros(size(X,1)-2,1);
for i= 2:length(X)-1
    dotx(i-1)= (X(i+1)-X(i-1))/(2*deltaT);
end

%%if you want to interpolate first and last element 
% dotx(1)= dotx(2);
% dotx(end)= dotx(end-1);
end