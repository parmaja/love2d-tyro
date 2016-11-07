draw.circle(100, 100, 50)

x, y = 0, 0

for i = 0, 100 do
	print(i)
	draw.clear()
    pause(0.5)
	draw.rectangle(x, y, 100, 100)
    x = x + 5
    y = y + 5
end
