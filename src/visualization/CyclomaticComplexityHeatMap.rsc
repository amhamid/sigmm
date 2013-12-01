module visualization::CyclomaticComplexityHeatMap

import vis::Figure;
import vis::Render;
import List;
import IO;

// TODO add legends

void generateCyclomaticComplexityHeatMap(lrel[loc, int, int] cyclomaticComplexities) {
	list[Figure] boxes = [];
	
	for(cyclomaticComplexity <- cyclomaticComplexities) {
		loc methodLoc = cyclomaticComplexity[0];
		int complexity = cyclomaticComplexity[1];
		list[str] lines = readFileLines(methodLoc); 
		str line = ("<head(lines)>" | it + "<line>\n" | line <- tail(lines));
		
		boxes += createBox(complexity, line);
	}
	
	render("Cyclomatic Complexity Heat Map", pack(boxes));
}

private FProperty popup(str message) {
	return mouseOver(box(text(message), resizable(false), right(), bottom()));
}

private Figure createBox(int complexity, str line) {
	int width = 30;
	int height = 30;
			
	Figure shape;
	if(complexity <= 10) {
		shape = box(fillColor("green"), resizable(false), size(width,height));	
	} else if(complexity > 10 && complexity <= 20) {
		shape = box(fillColor("yellow"), popup(line), resizable(false), size(width,height));	
	} else if(complexity > 20 && complexity <= 50) {
		shape = box(fillColor("orange"), popup(line), resizable(false), size(width,height));	
	} else {
		shape = box(fillColor("red"), popup(line), resizable(false), size(width,height));	
	}
	
	return shape;
}
