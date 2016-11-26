# Lua LÖVE BASIC

Small Lua and Love2D module to add more simple functions make it easy for kids

 * input()  Wrap to io.read but it detect if the string is number it will convert the result to number
 * write(...) Wrap to io.write nothing else
 * writeln(...)
 * int alias of math.floor(x)
 * pause(number)
 * canvas.lock()
 * canvas.unlock()
 * canvas.clear()
 * canvas.update()
 * canvas.setcolor(r, g, b)
 * canvas.setcolor(number)
 * canvas.rectangle(x, y, w, h)
 * canvas.circle(x, y, r)
 * canvas.text(text, x, y)

# TODO

functions is easy, but drawing is my problem, i want to add circle, rectanlge, line, pixel etc, that need GUI window, but i am thinking about Love game engine, to add more animations too, like speriates

for example from my mind

    sperite = sperites.new
    sperite.load('sperite.png')
    sperite.move(x, y)
    sperite.jump

also like to make shapes as sperite

    circle = circle.new
    circle.move(x, x)
    circle.show
    ...
    circle.hide

I still work on it, do not use it.

# How to use it

Put it folder, run love point to this folder with command param of ur lua file

	c:\lua\love\love . projects\circles.lua
    c:\lua\love\lovec . projects\circles.lua