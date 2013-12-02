module util::Visualization

import util::Editors;
import lang::java::m3::Registry;
import vis::Figure;
import vis::Render;
import vis::KeySym;

FProperty popup(str message) {
	return mouseOver(box(text(message), resizable(false), right(), bottom()));
}

FProperty openMethodOnClick(loc methodLoc) {
	return onMouseDown(
		bool (int butnr, map[KeyModifier,bool] modifiers) {
			edit(resolveJava(methodLoc));
			return true;
		}
	);
}
