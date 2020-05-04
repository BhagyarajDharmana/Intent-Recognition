%%================================================================%%
%%%function for fifth grad interpolation
%%%input should be in the form of ([x0;y0;vx0;vy0;ax0;ay0;t0],[x1;y1;vx1;vy1;ax1;ay1;t1])
%%================================================================%%
function OUT = fifthGradInterpolation(X0,X1,samplingTime)
t0=X0(7);
t1=X1(7);
M=[t0^5, t0^4, t0^3, t0^2, t0, 1; 5*t0^4, 4*t0^3, 3*t0^2, 2*t0,1,0 ;20*t0^3, 12*t0^2, 6*t0, 2, 0, 0; ...
   t1^5, t1^4, t1^3, t1^2, t1, 1; 5*t1^4, 4*t1^3, 3*t1^2, 2*t1,1,0 ;20*t1^3, 12*t1^2, 6*t1, 2, 0, 0];
coefX=M\[X0(1),X0(3),X0(5) , X1(1),X1(3), X1(5)]';
coefY=M\[X0(2),X0(4), X0(6) , X1(2),X1(4), X1(6)]';
n=round((t1-t0)/samplingTime);
tVec=(1:n-1)*samplingTime+t0;
OUT=zeros(n-1,6);
for i=1:n-1
    OUT(i,1)= coefX(1)*tVec(i)^5+coefX(2)*tVec(i)^4+coefX(3)*tVec(i)^3+coefX(4)*tVec(i)^2+coefX(5)*tVec(i)+coefX(6); %x
    OUT(i,2)= coefY(1)*tVec(i)^5+coefY(2)*tVec(i)^4+coefY(3)*tVec(i)^3+coefY(4)*tVec(i)^2+coefY(5)*tVec(i)+coefY(6); %y
    OUT(i,3)= 5*coefX(1)*tVec(i)^4+4*coefX(2)*tVec(i)^3+3*coefX(3)*tVec(i)^2+2*coefX(4)*tVec(i)+coefX(5);            %vx
    OUT(i,4)= 5*coefY(1)*tVec(i)^4+4*coefY(2)*tVec(i)^3+3*coefY(3)*tVec(i)^2+2*coefY(4)*tVec(i)+coefY(5);            %vy
    OUT(i,5)= 20*coefX(1)*tVec(i)^3+12*coefX(2)*tVec(i)^2+6*coefX(3)*tVec(i)+2*coefX(4);                             %ax
    OUT(i,6)= 20*coefY(1)*tVec(i)^3+12*coefY(2)*tVec(i)^2+6*coefY(3)*tVec(i)+2*coefY(4);                             %ay
end
end
