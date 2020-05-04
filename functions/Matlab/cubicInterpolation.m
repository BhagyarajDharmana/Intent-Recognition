%%================================================================%%
%%%function for cubic interpolation
%%%input should be in the form of ([x0;y0;vx0;vy0;t0],[x1;y1;vx1;vy1;t1])
%%% x0,x1 xpos at t0 and t1 respectively
%%% vx0,vx1,vy0,vy1 are longitudinal and lateral velocities at t0 and t1
%%% y0,y1 ypos at t0 and t1 respectively
%%% ax,ay are longitudinal and lateral accelerations
%%% t is time where user wants interpolated  xpos and ypos.
%%================================================================%%
function OUT = cubicInterpolation(X0,X1,timestamps)
t0=X0(5);
t1=X1(5);
idx_t0=find(timestamps==t0);
idx_t1=find(timestamps==t1);
M=[t0^3, t0^2, t0, 1; 3*t0^2, 2*t0,1,0 ; t1^3, t1^2, t1, 1; 3*t1^2, 2*t1,1,0 ];
coefX=M\[X0(1),X0(3) , X1(1),X1(3)]';
coefY=M\[X0(2),X0(4) , X1(2),X1(4)]';
tVec=timestamps(idx_t0+1:idx_t1-1);
n=length(tVec);
OUT=zeros(n,6);
for i=1:n
    OUT(i,1)= coefX(1)*tVec(i)^3+coefX(2)*tVec(i)^2+coefX(3)*tVec(i)+coefX(4); %x
    OUT(i,2)= coefY(1)*tVec(i)^3+coefY(2)*tVec(i)^2+coefY(3)*tVec(i)+coefY(4); %y
    OUT(i,3)=3*coefX(1)*tVec(i)^2+2*coefX(2)*tVec(i)+coefX(3);                 %vx
    OUT(i,4)=3*coefY(1)*tVec(i)^2+2*coefY(2)*tVec(i)+coefY(3);                 %vy
    OUT(i,5)=6*coefX(1)*tVec(i)+2*coefX(2);                                    %ax
    OUT(i,6)=6*coefY(1)*tVec(i)+2*coefY(2);                                    %ay
end
end
