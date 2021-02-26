close all, clear all, clc

n=10;   

% %-----------------------------------------------% 
%%%% Cardinal Spline 2D Interpolation %%%%%%%%%%
% % We have 2D data (control points)
Px=[0 0.0001 0.25 0.75 0.99999 1];	
Py=[0.5 0.5001 0.9 0.1 0.49999 0.5];	
% % Note first and last points are repeated so that spline passes
% % through all the control points

% when Tension=0 the class of Cardinal spline is known as Catmull-Rom spline
Tension=0; 
figure, hold on

XY = [];

for k=1:length(Px)-3
    
    [XiYi]=crdatnplusoneval([Px(k),Py(k)],[Px(k+1),Py(k+1)],[Px(k+2),Py(k+2)],[Px(k+3),Py(k+3)],Tension,n);
    
    % % XiYi is 2D interpolated data
    
    % Between each pair of control points plotting n+1 values of first two rows of XiYi 
    plot(XiYi(1,:),XiYi(2,:),'b','linewidth',2) % interpolated data
    plot(Px,Py,'ro','linewidth',2)          % control points
    
    if (k == 1)
       XY = XiYi;
    else
       XY = cat(2, XY, XiYi(:,2:end));
    end
end
title('\bf 2D Cardinal Spline')
xlabel('\bf X-axis')
ylabel('\bf Y-axis')
legend('\bf Interpolated Data','\bf Control Points','Location','NorthEast')
grid on

figure, hold on
xi = (0:.01:1)';
XX=XY(1,:)';
YY=XY(2,:)';

yi = interp1q(XX,YY,xi);

%plot(XX,YY,'o',xi,yi);

F = griddedInterpolant(XX',YY');
fun = @(t) F(t);

x = (0:.01:1)';

plot(x, fun(x), 'r');

v=[];

for kk=0:100
    v = cat(1, v, 1 / fun(kk * 0.01));
end

%plot(x, v, 'b');

xxx = (0:.01:1)';
FF = griddedInterpolant(xxx,v);
funfun = @(t) FF(t);

%plot(xxx, funfun(xxx), 'b');

T = integral(funfun, xxx(1), xxx(end));

tt = [];
for kk=0:100
    xxx = (0:.01:kk/100)';
    tt = cat(1, tt, integral(funfun, xxx(1), xxx(end)) / T);
end

plot(tt, x, 'g');



