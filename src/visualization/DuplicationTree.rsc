module visualization::DuplicationTree

import vis::Figure;
import vis::Render;
import vis::KeySym;
import String;
import List;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import util::Visualization;

// root duplicate method loc with its lines and its clones with method loc and lines
void generateDuplicationTree(lrel[loc, list[str], lrel[loc, list[str]]] duplicationMethods) {
	list[Figure] trees = [];
	str separator = "\n\n\t.....\n\n";
	
	for(duplicationMethod <- duplicationMethods) {
		loc originalLoc = duplicationMethod[0];
		str originalPath = originalLoc.path;
		list[str] originalLines = duplicationMethod[1];
		str originalLine = ("<originalPath> <separator> <head(originalLines)>" | it + "<line>\n" | line <- tail(originalLines));
		lrel[loc, list[str]] clones = duplicationMethod[2];
		
		list[Figure] children = [];
		for(clone <- clones) {
			loc cloneLoc = clone[0];
			str clonePath = cloneLoc.path;
			list[str] cloneLines = clone[1];
			str cloneLine = ("<clonePath> <separator> <head(cloneLines)>" | it + "<line>\n" | line <- tail(cloneLines));
			str methodName = getMethodName(clonePath);
			children += box(text("<methodName> (<size(cloneLines)>)"), popup(cloneLine), openMethodOnClick(cloneLoc), fillColor("red"), resizable(false));
		}
		
		str methodName = getMethodName(originalPath);
		trees += tree(box(text("<methodName> (<size(originalLines)>)"), popup(originalLine), openMethodOnClick(originalLoc), fillColor("green"), resizable(false)), children, std(gap(20)));
	}
	
	render("Code Duplication Tree", pack(trees, std(gap(50))));
}

// [args]: title of the window and list of files
FProperty click(lrel[loc, list[str], lrel[loc, list[str]]] duplicationMethods) {
	return onMouseDown(
		bool (int butnr, map[KeyModifier,bool] modifiers) {
			generateDuplicationTree(duplicationMethods);
			return true;
		}
	);
}

// returns the duplication from a given list of files (from the total duplication in a project)
lrel[loc, list[str], lrel[loc, list[str]]] subset(lrel[loc, int, int] complexities, lrel[loc, list[str], lrel[loc, list[str]]] duplicateMethods) {
	list[loc] methodLocs = [complexity[0] | complexity <- complexities];
	
	lrel[loc, list[str], lrel[loc, list[str]]] result = [];	
	for(duplicateMethod <- duplicateMethods) {
		loc originalMethod = duplicateMethod[0];
		if(originalMethod in methodLocs) {
			result += duplicateMethod;		
		} else {
			lrel[loc, list[str]] clones = duplicateMethod[2];
			for(clone <- clones) {
				loc cloneMethod = clone[0];
				if(cloneMethod in methodLocs) {
					result += duplicateMethod;
					break;				
				}			
			}
		}	
	}
	
	return result;
}

// just take the method name without the argument(s) from the path
private str getMethodName(str methodFullPath) {
	return substring(methodFullPath, findLast(methodFullPath, "/") + 1, findFirst(methodFullPath, "("));
}
