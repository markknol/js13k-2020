# 🎮 404 game - js13k

[Mark Knol](https://twitter.com/mknol)'s entry for the [js13k gamejam 2020](https://js13kgames.com/).

It's a soothing game about perspective. It's important to turn your sound on, headphones adviced. 
Tap and hold to move the trail, make a loop to catch things, if you want.
Should work on desktop and mobile devices. <sub>It's mostly tested on Chrome, because that's the mother of browsers these days right?</sub>

# Post mortem

#### Concept

This is the first time I joined the js13k gamejam. The idea is to create a game in 13kb (zipped). Making games is fun! Not only for the player, but for a developer too. 

> To illustration how small 13kb is: If you have a iPhone X and you take a selfie, that's 2.93MB, so this game fits 225 times in that. Or, if you have a phone with 64gb of storage, you can have 5.000.000 copies of this game on your phone. 🤯

#### Getting started

To prove to myself it is perfectly possible to use Haxe for this, I started to create a small engine in Haxe. I called the project hx13k initially. 
As main part of my daily job I am game developer and make HTML5 adver games, so I liked the idea of this jam.
First I started by making a basic engine. Or actually, I stripped down this setup I normally use, which is combination of [pixi.js](https://github.com/pixijs/pixi.js) and a customized [Flambe](https://github.com/aduros/flambe) library. 
I am big fan of using Entity/Component and the way the Flambe library did it is how I like to work, it's very pragmatic and usable for creating games. I hoped this wasn't too much of overhead.
Pixi.js was removed as renderer, since it's too big. It's too bad because pixi.js is such a great/fast 2d rendering framework.

I kept stripping the engine until I had the bare minimum (mainloop, entity, components, some utilities).
Then I added my own simple custom canvas [renderer](src/flambe/Renderer.hx). It supports nested hierarchies, which is actually relative easy to achieve with canvas operations.

#### Interaction

I noticed that I needed interaction too (for everything you can tap on), so made simple system to allow object to be tapped.
Now, I don't know how normal people do this in 2d canvas, but I haven't found a native way to do it. So the way I approached it was kinda hacky, but.. it worked out. 
I created another (hidden) canvas pure for interaction. The mainloop iterates each tick on all entities. 
When it finds an DisplayComponent in the hierarchie it will call `display.draw(ctx)` (ctx = 2d context of visual canvas) in the odd frames, but calls a `display.drawInteraction(ctx)` (ctx = 2d context of interaction canvas) in the even frames.
Maybe it could run in the same frame and render the game at 60fps, but I thought to save the planet a bit.

#### Procedural lines
I had a problem at the beginning of this project, I actually didn't know what game to create. 
At this point I could draw anything I wanted on screen, but yeah, go gotta have an idea eh? 
In my test setup I used some line drawings because that was easy to test things. I did decided I wanted to keep that and also use that as main thing in the game. 

I made procedural [art](https://www.curioos.com/markknol) and things in several forms and recently I like creating things on [Turtletoy](https://turtletoy.net/user/markknol). 
Turtletoy allows to create procedural art with JavaScript and outputs lines only using minimal API. There is crazy good/creative stuff there. 
One particular interesting idea I've seen there is a so called "[Tortoise](https://turtletoy.net/turtle/102cbd7c4d)", I adapted the idea behind this for this game. 
It basically takes an array of transformers, a transformer takes gets a point in and can return a modified point. Stacking this on top of eachother and doing this before actually drawing allows creating complex looking effects.
The game is mostly build of lines, so I created a setup where you can define start modifiers and update modifiers, which take a path in and return a modified path. 
Start modifiers are applied once (so are some sort of pre-processors) and are permanent, update modifiers are temporary applied each frame, just before it draws.

#### Make everything small

Since I wanted to use all the Haxe goodness, I created simple build macro that logs sizes and puts it in a zip file, when I create a release build. 
The build tool calls terser to minify the build and I manually move replaced some tokens.

I added the [no-spoon] library (also macro) to tone down `Std.string`; this is a to-string function that is consistent over all Haxe targets, but adds quite some boilerplate code.

Haxe is pretty great for this actually! I can write normal Haxe code, all fields become small names because of my [Haxe obfuscator]() lib. 
I noticed that standard Haxe enums take some space in the output because they can also hold enum values. In most cases it was easy to change that too `enum abstracts`, which is basically comes down to a enum in TypeScript (`<ad>`But with more features! E.g. you can add functions and own from/to cast functions. Even operator overloading is supported! And no one notices when looking at the output thanks to `inline`!`</ad>`).

In debug builds I can add nice stuff for development (using conditional compilation) and the release build those things are gone and it is very optimized/small.

#### Conclusion

You can use most goodness of Haxe to create a nice and small game. It was fun to join this jam! ⭐⭐⭐⭐⭐


# Locally test/compile game 

 * `yarn install` (or `npm`) to install the dependencies. This will locally install [Haxe](https://haxe.org) and its dependencies.
 * `yarn build:debug` to create debug build.
 * `yarn build:release` to create release build (minified, zipped). <sub>This only works on Windows because it uses `ect-0.8.3.exe`.</sub>
