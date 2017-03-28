# Lua LÖVE BASIC

Small Lua and Love2D module to add more simple functions make it easy for kids and beginners.

 * input()  Wrap to io.read but it detect if the string is number it will convert the result to number
 * write(...) Wrap to io.write nothing else
 * writeln(...)
 * int alias of math.floor(x)

Functions
 
 * pause(1) --one second
 * canvas.lock()
 * canvas.unlock()
 * canvas.freeze(0.1)
 * canvas.defreeze()
 * canvas.clear()
 * canvas.color(colors.Red)
 * canvas.backcolor(colors.Red)
 * canvas.rectangle(x, y, w, h)
 * canvas.circle(x, y, r)
 * canvas.text(text, x, y)

Object Example 

    circle = circle.new
    circle.move(x, x)
    circle:show()
    circle:hide()
 
# TODO

functions is easy, but drawing is my problem, i want to add circle, rectanlge, line, pixel etc, that need GUI window, but i am thinking about Love game engine, to add more animations too, like speriates

For example from my mind

    sperite = object.sperite("sperite.png")
    sperite:put(x, y)

I still work on it, do not use it.

# How to use it

create new file "main.lua" in your projects folder with this lines

    require("basic.main")

copy "basic" folder into your project folder

create your project file e.g "points.lua", run love point to this folder with command argument of your lua file (points.lua)

c:\lua\love\love . points.lua

for fast testing try to run one of demo files

    c:\lua\love\love . demos\music.lua
or
    c:\lua\love\lovec . demos\points.lua

if you inside demos folder use

c:\lua\love\lovec .. points.lua
    
License
=======

The project is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
    