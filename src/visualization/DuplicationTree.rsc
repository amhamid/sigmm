module visualization::DuplicationTree

import vis::Figure;
import vis::Render;
import vis::KeySym;
import String;
import List;

void generateDuplicationTree(lrel[loc, list[str], lrel[loc, list[str]]] duplicationMethods) {
	list[Figure] trees = [];
	
	for(duplicationMethod <- duplicationMethods) {
		loc originalLoc = duplicationMethod[0];
		str originalPath = originalLoc.path;
		list[str] originalLines = duplicationMethod[1];
		str originalLine = ("<head(originalLines)>" | it + "<line>\n" | line <- tail(originalLines));
		lrel[loc, list[str]] clones = duplicationMethod[2];
		
		list[Figure] children = [];
		for(clone <- clones) {
			loc cloneLoc = clone[0];
			str clonePath = cloneLoc.path;
			list[str] cloneLines = clone[1];
			str cloneLine = ("<head(cloneLines)>" | it + "<line>\n" | line <- tail(cloneLines));
			str methodName = getMethodName(clonePath);
			children += box(text(methodName), popup(cloneLine), fillColor("red"), resizable(false));
		}
		
		str methodName = getMethodName(originalPath);
		trees += tree(box(text(methodName), popup(originalLine), fillColor("green"), resizable(false)), children, std(gap(20)));
	}
	
	render("Code Duplication Tree", pack(trees, std(gap(50))));
}

private FProperty popup(str message) {
	return mouseOver(box(text(message), resizable(false), right()));
}

// just take the method name without the argument(s) from the path
private str getMethodName(str methodFullPath) {
	return substring(methodFullPath, findLast(methodFullPath, "/") + 1, findFirst(methodFullPath, "("));
}


// TODO fix clicking to method loc !!
private FProperty click() {
	return onMouseDown(
		bool (int butnr, map[KeyModifier,bool] modifiers) {
			return true;
		}
	);
}
