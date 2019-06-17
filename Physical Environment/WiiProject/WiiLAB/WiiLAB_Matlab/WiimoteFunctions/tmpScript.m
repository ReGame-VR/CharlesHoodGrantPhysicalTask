
clear X
i=1;
while true
    subplot(1,4,1)
    x = wiimote.wm.GetBalanceBoardCoGState();
    plot(x(1),x(2),'o')
    xlim([-20 20])
    ylim([-20 20])
    grid on
    
    subplot(1,4,2:4)
    y = wiimote.wm.GetBalanceBoardSensorState();
    X(i,:) = y;
    plot(X);

    drawnow
    i=i+1;
end