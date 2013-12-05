module visualization::CyclomaticComplexityHeatMap

import lang::java::jdt::m3::AST;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import List;
import IO;
import String;

import util::Visualization;
import extract::CyclomaticComplexity;

// TODO:
// 1. add overview (package level with chart inside it)
// 2. add relation with duplication (by arrow) 
// 3. add relation with volume/unit size (by box size)
// 4. add legends

void getPackageOverview(map[str, list[loc]] projectStructure) {
	list[str] packages = [package | package <- projectStructure];
	
	list[Figure] packageBoxes = [];
	for(package <- packages) {
		str packageName = substring(package, findLast(package, "/")+1);
		Figure packageBox = box(text(packageName, top()), size(100, 100));
		packageBoxes += overlay([packageBox, createChart(projectStructure[package])]);	
	}

	render(pack(packageBoxes, std(gap(50))));
}

private FProperty click(str title, lrel[loc, list[Declaration]] declarations) {
	return onMouseDown(
		bool (int butnr, map[KeyModifier,bool] modifiers) {
			render(title, heatMap(declarations));
			return true;
		}
	);
}

private Figure heatMap(lrel[loc, list[Declaration]] declarations) {
	list[Figure] fileBoxes = [];	
	for(declaration <- declarations) {
		loc file = declaration[0];
		list[Declaration] methodAsts = declaration[1];
		lrel[loc, int, int] complexityUnits = cyclomaticComplexityPerUnit(methodAsts);
		str fileName = substring(file.path, findLast(file.path, "/")+1);
		Figure fileBox = box(text(fileName, top()), size(20, 20), resizable(false));
		fileBoxes += overlay([fileBox, createChart(complexityUnits)]);
	}
	
	return pack(fileBoxes, std(gap(50)));	
}

private Figure createChart(lrel[loc, int, int] complexityUnits) {
	list[Figure] boxes = [];
	for(cyclomaticComplexity <- complexityUnits) {
		loc methodLoc = cyclomaticComplexity[0];
		int complexity = cyclomaticComplexity[1];
		boxes += createBox(methodLoc, complexity);
	}
	
	return pack(boxes);
}

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

	Figure yellowBox = box(size(width, size(moderateRisk)*5), click("CC Moderate Risk", declarations), fillColor("yellow"));
	Figure orangeBox = box(size(width, size(highRisk)*5), click("CC High Risk", declarations), fillColor("orange"));
	Figure redBox = box(size(width, size(veryHighRisk)*5), click("CC Very High Risk", declarations), fillColor("red"));

	return hcat([yellowBox,orangeBox,redBox], std(center()), std(bottom()), std(resizable(false)), std(gap(5)));
}

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
