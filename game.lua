x, y = 0, 0
c = 0
function canvas.draw()
	love.graphics.circle("line", x + 200, y, 50)
    love.graphics.rectangle("line", x + 200 + 0.5, y, 100, 100)
    c = c + 1
    print(c)
end

for i = 0, 50 do
--	print(i)
	canvas.clear()
--    sleep(0.1)
    pause(0.5)
	canvas.setcolor(255, 0, 0)
--	canvas.rectangle(x, y, 100, 100)
--    canvas.circle(x, y, 50)
    x = x + 5
    y = y + 5
end

