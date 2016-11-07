
print "inside"
draw.circle(100, 100, 50)

x, y = 0, 0

for i = 0, 100 do
	print(i)
	draw.clear()
    pause(1)
	draw.rectangle(x, y, x + 100, y + 100)
    x = x + 5
    y = y + 5
    print("not dead")
	coroutine.yield()
end

