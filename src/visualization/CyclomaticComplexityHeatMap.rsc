module visualization::CyclomaticComplexityHeatMap

import vis::Figure;
import vis::Render;
import List;
import IO;

import util::Visualization;

// TODO add legends
// TODO if possible draw the CC graph in the popup (instead of showing the method content)

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
