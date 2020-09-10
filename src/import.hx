// import.hx acts as if its contents are placed at the top of each module
using StringTools;
using flambe.util.BitSets;
using Lambda;
using flambe.Entity;
using temple.utils.ArrayUtils;
using temple.utils.FloatUtils;
import game.Color.*;
#if js
import Browsert.document;
import Browsert.window;
import flambe.Renderer.sceneSize;
import flambe.Renderer.sceneMiddlePosition;
import game.Factory.*;
import game.display.PathModifiers.*;
#end