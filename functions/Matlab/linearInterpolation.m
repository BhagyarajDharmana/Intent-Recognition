%%====================================================================%%
%%% function for Linear Interpolation
%%% Input should be in the form of ([x0;t0],[x1;t1],samplingTime)
%%% x0,x1 xpos at t0 and t1 respectively
%%% y0,y1 ypos at t0 and t1 respectively
%%% t is time where user wants interpolated  xpos and ypos.
%%=====================================================================%%
function X = linearInterpolation(X0,X1,timestamps)
t0=X0(2);
t1=X1(2);
M=[t0 1;t1 1];
coef=M\[X0(1) X1(1)]';
idx_t0=find(timestamps==t0);
idx_t1=find(timestamps==t1);
tVec=timestamps(idx_t0+1:idx_t1-1);
n=length(tVec);
X=zeros(n,1);
for i=1:n
    X(i)=coef(1)*tVec(i)+coef(2);
end
end
