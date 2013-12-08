module visualization::CyclomaticComplexityHeatMap

import lang::java::jdt::m3::AST;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import List;
import IO;
import String;

import util::Visualization;
import util::ResultMock;
import extract::CyclomaticComplexity;
import visualization::DuplicationTree;
import visualization::VolumeUnitBar;

// TODO:
// 1. add relation with duplication to add insight about priority 
// 2. add legends

// helper method for generating HSQLDB package overview (demo purpose only)
void getHsqldbPackageOverview() {
	map[str,list[loc]] projectStructure = getHsqldbStructure();
	lrel[loc, list[str], lrel[loc, list[str]]] duplicationMethods = getHsqldbDuplication();
	getPackageOverview(projectStructure, duplicationMethods);	
}

// helper method for generating SmallSQL package overview (demo purpose only)
void getSmallSqlPackageOverview() {
	map[str,list[loc]] projectStructure = getSmallSqlStructure();
	lrel[loc, list[str], lrel[loc, list[str]]] duplicationMethods = getSmallSqlDuplication();
	getPackageOverview(projectStructure, duplicationMethods);	
}

// [args]: map of package name with its list of files
private void getPackageOverview(map[str, list[loc]] projectStructure, lrel[loc, list[str], lrel[loc, list[str]]] duplicateMethods) {
	list[str] packages = [package | package <- projectStructure];
	
	list[Figure] packageBoxes = [];
	for(package <- packages) {
		str packageName = substring(package, findLast(package, "/")+1);
		list[loc] files = projectStructure[package];
		
		lrel[loc, lrel[loc,int]] fileMethods = [];
		list[Declaration] allMethodAsts = [];
		lrel[loc, int, int] allComplexities = [];
		 
		for(file <- files) {
			list[Declaration] methodAsts = [ d | /Declaration d := createAstFromFile(file, true), d is method];
			allMethodAsts += methodAsts;
			lrel[loc, int, int] complexities = [cc | cc <- cyclomaticComplexityPerUnit(methodAsts), cc[1] > 10];
			allComplexities += complexities;
			if(!isEmpty(complexities)) {
				fileMethods += [<file, [<cc[0], cc[1]> | cc <- complexities]>];
			}	
		}
		
		Figure packageBox = box(text("Package: <packageName>", top(), right()), size(50, 50));
		Figure infoIcon = box(top(), left(), click("Package: <packageName>", fileMethods), size(15, 15), resizable(false));
		lrel[loc, list[str], lrel[loc, list[str]]] duplicate = subset(allComplexities, duplicateMethods);
		if(isEmpty(duplicate)) {
			packageBoxes += overlay([packageBox, infoIcon, createChart(files)]);
		} else {
			Figure duplicateIcon = box(bottom(), right(), fillColor("blue"), click(duplicate), size(15, 15), resizable(false));	
			packageBoxes += overlay([packageBox, infoIcon, duplicateIcon, createChart(files)]);
		}
	}

	render("CC Package Level", pack(packageBoxes, std(gap(50))));
}

// [args]: title of the window and list of files
private FProperty click(str title, list[loc] files) {
	return onMouseDown(
		bool (int butnr, map[KeyModifier,bool] modifiers) {
			lrel[loc, list[Declaration]] declarations = [];
			for(file <- files) {
				declarations += <file, [ d | /Declaration d := createAstFromFile(file, true), d is method]>;		
			}
			render(title, heatMap(declarations));
			return true;
		}
	);
}

private FProperty click(str title, lrel[loc, lrel[loc,int]] volume) {
	return onMouseDown(
		bool (int butnr, map[KeyModifier,bool] modifiers) {
			render(title, generateVolumeAndCcBar(volume));
			return true;
		}
	);
}

// [args]: title of the window and list of tuple of file location and its method ASTs
private FProperty click(str title, lrel[loc, list[Declaration]] declarations) {
	return onMouseDown(
		bool (int butnr, map[KeyModifier,bool] modifiers) {
			render(title, heatMap(declarations));
			return true;
		}
	);
}

// [args]: title of the window and complexity (list of tuple of method location, its complexity and its unit size) 
private FProperty click(str title, lrel[loc, int, int] complexityUnits, str color) {
	return onMouseDown(
		bool (int butnr, map[KeyModifier,bool] modifiers) {
			render(title, heatMap(complexityUnits, color));
			return true;
		}
	);
}

// create heat map (list of tuple of file location and its method ASTs)
private Figure heatMap(lrel[loc, list[Declaration]] declarations) {
	list[Figure] fileBoxes = [];	
	for(declaration <- declarations) {
		loc file = declaration[0];
		list[Declaration] methodAsts = declaration[1];
		lrel[loc, int, int] complexityUnits = cyclomaticComplexityPerUnit(methodAsts);
		lrel[loc,int,int] moderateRisk = [<l,x,y> | <l,x,y> <- complexityUnits, x > 10, x <= 20];
		lrel[loc,int,int] highRisk = [<l,x,y> | <l,x,y> <- complexityUnits, x > 20, x <= 50];
		lrel[loc,int,int] veryHighRisk = [<l,x,y> | <l,x,y> <- complexityUnits, x > 50];
		str filename = substring(file.path, findLast(file.path, "/")+1);
		Figure fileBox = box(text(filename, top(), right()), size(20, 20));
		fileBoxes += overlay([fileBox, createChart(complexityUnits)]);
	}
	
	return pack(fileBoxes, std(gap(50)));	
}

// create heat map from a given complexity (list of tuple of method location, its complexity and its unit size)
private Figure heatMap(lrel[loc, int, int] complexityUnits, str color) {
	list[Figure] methodBoxes = [];
	for(complexityUnit <- complexityUnits) {
		loc methodLoc = complexityUnit[0];
		int complexity = complexityUnit[1];
		int unitSize = complexityUnit[2];
		methodBoxes += box(text("<getMethodName(methodLoc.path)>", top()), openMethodOnClick(methodLoc), size(unitSize, complexity), fillColor(color), resizable(false));
	}
	
	return pack(methodBoxes, std(gap(50)));	
}

// create a bar chart with list of tuple of method location, its complexity and its unit size
private Figure createChart(lrel[loc, int, int] complexityUnits) {
	list[Figure] boxes = [];
	for(cyclomaticComplexity <- complexityUnits) {
		loc methodLoc = cyclomaticComplexity[0];
		int complexity = cyclomaticComplexity[1];
		boxes += createBox(methodLoc, complexity);
	}
	
	return pack(boxes);
}

// create a bar chart with list of files
private Figure createChart(list[loc] files) {
	int width = 30;
	lrel[loc, list[Declaration]] declarations = [];
	for(file <- files) {
		declarations += <file, [ d | /Declaration d := createAstFromFile(file, true), d is method]>;		
	}
	
	list[Declaration] methodAsts = ([] | it + ast[1] | ast <- declarations); 
	lrel[loc, int, int] complexityUnits = cyclomaticComplexityPerUnit(methodAsts);
	lrel[loc,int,int] moderateRisk = [<l,x,y> | <l,x,y> <- complexityUnits, x > 10, x <= 20];
	lrel[loc,int,int] highRisk = [<l,x,y> | <l,x,y> <- complexityUnits, x > 20, x <= 50];
	lrel[loc,int,int] veryHighRisk = [<l,x,y> | <l,x,y> <- complexityUnits, x > 50];

	Figure yellowBox = box(size(width, size(moderateRisk)*5), click("CC Moderate Risk", moderateRisk, "yellow"), fillColor("yellow"));
	Figure orangeBox = box(size(width, size(highRisk)*5), click("CC High Risk", highRisk, "orange"), fillColor("orange"));
	Figure redBox = box(size(width, size(veryHighRisk)*5), click("CC Very High Risk", veryHighRisk, "red"), fillColor("red"));

	return hcat([yellowBox,orangeBox,redBox], std(center()), std(bottom()), std(resizable(false)), std(gap(5)));
}

// create box (green, yellow, orange or red) that is depend on complexity
private Figure createBox(loc methodLoc, int complexity) {
	int width = 30;
	int height = 30;
			
	Figure shape;
	if(complexity <= 10) {
		shape = box(text("<complexity>"), fillColor("green"), openMethodOnClick(methodLoc), resizable(false), size(width,height));
	}else if(complexity > 10 && complexity <= 20) {
		shape = box(text("<complexity>"), fillColor("yellow"), openMethodOnClick(methodLoc), resizable(false), size(width,height));	
	} else if(complexity > 20 && complexity <= 50) {
		shape = box(text("<complexity>"), fillColor("orange"), openMethodOnClick(methodLoc), resizable(false), size(width,height));	
	} else {
		shape = box(text("<complexity>"), fillColor("red"), openMethodOnClick(methodLoc), resizable(false), size(width,height));	
	}
	
	return shape;
}

// just take the method name without the argument(s) from the path
private str getMethodName(str methodFullPath) {
	return substring(methodFullPath, findLast(methodFullPath, "/") + 1, findFirst(methodFullPath, "("));
}
