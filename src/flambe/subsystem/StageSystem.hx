package flambe.subsystem;

import flambe.display.Orientation;
import flambe.platform.EventGroup;
import flambe.platform.html.HtmlUtil;
import flambe.util.Disposable;
import flambe.util.Signal2;
import flambe.util.Value;
import js.Browser;
import js.html.DivElement;
import js.html.Element;
import js.html.HtmlElement;

/**
 * @author ...
 */
class StageSystem implements Disposable {
	public var orientation = new Value<Orientation>(null);
	public var width(get, null):Int;
	public var height(get, null):Int;
	public var container(get,never):Element;

	private var _containerWidth:Int;
	private var _containerHeight:Int;
	private var _containerDiv:Element;
	
	private var _events:EventGroup = new EventGroup();

	public var resizeSignal(default, null):Signal2<Int, Int> = new Signal2<Int, Int>();

	public function new(containerElement:Element) {
		_containerDiv = containerElement;

		updateContainerSize();

		if (window.orientation != null) {
			_events.addListener(window, "orientationchange", onOrientationChange);
			onOrientationChange(null);
		}
	}

	private function onOrientationChange(_) {
		orientation._ = HtmlUtil.orientation(window.orientation);
		if (HtmlUtil.SHOULD_HIDE_MOBILE_BROWSER) hideMobileBrower();
	}

	// Voodoo hacks required to move the address bar out of the way on Android and iOS
	private function hideMobileBrower() {
		// The maximum size of the part of the browser that can be scrolled away
		var mobileAddressBar = 100;

		var htmlStyle = document.documentElement.style;

		// Force the page to be tall enough to scroll
		htmlStyle.height = (window.innerHeight + mobileAddressBar) + "px";
		htmlStyle.width = window.innerWidth + "px";
		htmlStyle.overflow = "visible"; // Need to have overflow to scroll...

		HtmlUtil.callLater(function() {
			// Scroll the address bar away
			HtmlUtil.hideMobileBrowser();

			HtmlUtil.callLater(function() {
				// Fit the page to the new screen size
				htmlStyle.height = window.innerHeight + "px";
			}, 100);
		});
	}

	/** @return true when size actually changed **/
	public function updateContainerSize():Bool {
		var currentWidth:Int;
		var currentHeight:Int;

		if (Utils.isMobile.any) {
			currentWidth = window.innerWidth;
			currentHeight = window.innerHeight;
		} else {
			currentWidth = System.renderer.view.parentElement.offsetWidth;
			currentHeight = System.renderer.view.parentElement.offsetHeight;
		}

		// clamp extreme screen ratios
		/*var extremeRatio = { horizontal: 0.45, vertical: 0.75 };
			if (currentHeight / currentWidth < extremeRatio.horizontal) {
				currentWidth = Std.int(currentHeight / extremeRatio.horizontal );
			} else if (currentHeight / currentWidth > extremeRatio.vertical) {
				currentHeight = Std.int(currentWidth * extremeRatio.vertical);
		}*/

		if (_containerWidth != currentWidth || _containerHeight != currentHeight) {
			_containerWidth = currentWidth;
			_containerHeight = currentHeight;

			if (Utils.isMobile.any) {
				window.scrollTo(0, -1);
			}

			resizeCanvas();
			return true;
		} else {
			return false;
		}
	}

	private function resizeCanvas():Bool {
		// Take device scaling into account...
		var scaleFactor = 1;
		var canvas = System.renderer.view;
		var scaledWidth = Std.int(_containerWidth / scaleFactor);
		var scaledHeight = Std.int(_containerHeight / scaleFactor);

		if (canvas.width == scaledWidth && canvas.height == scaledHeight) {
			return false;
		}

		untyped System.renderer.resize(scaledWidth, scaledHeight);
		rescaleHTMLElement(cast System.renderer.view, scaledWidth, scaledHeight);
		if (Utils.isMobile.any) rescaleHTMLElement(cast _containerDiv, scaledWidth, scaledHeight);
		resizeSignal.emit(scaledWidth, scaledHeight);

		return true;
	}
	
	public function requestFullScreen() {
		var isFullscreen = HtmlUtil.loadExtension("fullscreenElement", document);
		if (isFullscreen.value == null) {
			var fullscreen = HtmlUtil.loadExtension("requestFullScreen", _containerDiv);
			if (fullscreen.field != null) {
				try {
					Reflect.callMethod(_containerDiv, fullscreen.value, []);
				} catch (e) {
					trace("Cannot go fullscreen", e.native);
				}
			}
		}
	}

	private function rescaleHTMLElement(element:HtmlElement, width:Int, height:Int):Void {
		element.style.width = '${width}px';
		element.style.height = '${height}px';
	}

	inline function get_width():Int {
		return Std.int(System.renderer.width / System.renderer.resolution);
	}

	inline function get_height():Int {
		return Std.int(System.renderer.height / System.renderer.resolution);
	}

	private inline function get_container():Element {
		return _containerDiv;
	}

	public function dispose() {
		_events = DisposerUtil.dispose(_events);
	}
}
