package;

import flambe.System;
import game.*;

/**
	@author $author
**/
class Main {
	public static function main() {
		System.init(document.body);
		System.root.add(new Intro());
	}
}
