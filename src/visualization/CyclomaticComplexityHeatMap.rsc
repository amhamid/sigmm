module visualization::CyclomaticComplexityHeatMap

import lang::java::jdt::m3::AST;
import vis::Figure;
import vis::Render;
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
		Figure packageBox = box(text(packageName, top()), size(300, 300));
		Figure chart = box(shrink(0.4), bottom());
		
		packageBoxes += overlay([packageBox, createChart(projectStructure[package])]);	
	}

	render(pack(packageBoxes, std(gap(50))));
}

Figure createChart(list[loc] files) {
	int width = 30;
	list[Declaration] methodAsts = [];
	for(file <- files) {
		methodAsts += [ d | /Declaration d := createAstFromFile(file, true), d is method];		
	}
	
	lrel[loc, int, int] complexityUnits = cyclomaticComplexityPerUnit(methodAsts);
	lrel[loc,int,int] moderateRisk = [<l,x,y> | <l,x,y> <- complexityUnits, x > 10, x <= 20];
	lrel[loc,int,int] highRisk = [<l,x,y> | <l,x,y> <- complexityUnits, x > 20, x <= 50];
	lrel[loc,int,int] veryHighRisk = [<l,x,y> | <l,x,y> <- complexityUnits, x > 50];

	Figure yellowBox = box(size(width, size(moderateRisk)*5), fillColor("yellow"));
	Figure orangeBox = box(size(width, size(highRisk)*5), fillColor("orange"));
	Figure redBox = box(size(width, size(veryHighRisk)*5), fillColor("red"));

	return hcat([yellowBox,orangeBox,redBox], std(center()), std(bottom()), std(resizable(false)), std(gap(5)));
}

void generateCyclomaticComplexityHeatMap(lrel[loc, int, int] cyclomaticComplexities) {
	list[Figure] boxes = [];
	
	for(cyclomaticComplexity <- cyclomaticComplexities) {
		loc methodLoc = cyclomaticComplexity[0];
		int complexity = cyclomaticComplexity[1];
		boxes += createBox(methodLoc, complexity);
	}
	
	render("Cyclomatic Complexity Heat Map", pack(boxes));
}

private Figure createBox(loc methodLoc, int complexity) {
	int width = 30;
	int height = 30;
			
	str separator = "\n\n\t.....\n\n";
	
	str line = "";
	// only read lines when complexity > 10 (medium risk and higher)
	if(complexity > 10) {
		list[str] lines = readFileLines(methodLoc);
		line = ("<methodLoc.path> <separator> <head(lines)>" | it + "<l>\n" | l <- tail(lines));
	}		
			
	Figure shape;
	if(complexity <= 10) {
		shape = box(fillColor("green"), resizable(false), size(width,height));	
	} else if(complexity > 10 && complexity <= 20) {
		shape = box(text("<complexity>"), fillColor("yellow"), popup(line), openMethodOnClick(methodLoc), resizable(false), size(width,height));	
	} else if(complexity > 20 && complexity <= 50) {
		shape = box(text("<complexity>"), fillColor("orange"), popup(line), openMethodOnClick(methodLoc), resizable(false), size(width,height));	
	} else {
		shape = box(text("<complexity>"), fillColor("red"), popup(line), openMethodOnClick(methodLoc), resizable(false), size(width,height));	
	}
	
	return shape;
}
