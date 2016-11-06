
draw.circle(100, 100, 50)
draw.setcolor(230,240,120)

x, y = 0, 0

for i = 0, 100 do
	draw.clear()
    pause(1)
	draw.rectangle(x, y, x + 100, y + 100)
    x = x + 2
end

