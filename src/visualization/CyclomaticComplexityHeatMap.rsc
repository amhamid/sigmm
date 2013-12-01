module visualization::CyclomaticComplexityHeatMap

import vis::Figure;
import vis::Render;
import List;
import IO;

// TODO add legends

void generateCyclomaticComplexityHeatMap(lrel[loc, int, int] cyclomaticComplexities) {
	list[Figure] greenBoxes = [];
	list[Figure] yellowBoxes = [];
	list[Figure] orangeBoxes = [];
	list[Figure] redBoxes = [];
	
	int width = 30;
	int height = 30;
	
	for(cyclomaticComplexity <- cyclomaticComplexities) {
		loc methodLoc = cyclomaticComplexity[0];
		int complexity = cyclomaticComplexity[1];
		
		list[str] lines = readFileLines(methodLoc); 
		str line = ("<head(lines)>" | it + "<line>\n" | line <- tail(lines));
			
		Figure shape;
		if(complexity <= 10) {
			greenBoxes += box(fillColor("green"), resizable(false), size(width,height));	
		} else if(complexity > 10 && complexity <= 20) {
			yellowBoxes += box(fillColor("yellow"), popup(line), resizable(false), size(width,height));	
		} else if(complexity > 20 && complexity <= 50) {
			orangeBoxes += box(fillColor("orange"), popup(line), resizable(false), size(width,height));	
		} else {
			redBoxes += box(fillColor("red"), popup(line), resizable(false), size(width,height));	
		}
	}
	
	render("Cyclomatic Complexity Heat Map", pack(redBoxes + orangeBoxes + yellowBoxes + greenBoxes));
}

private FProperty popup(str message) {
	return mouseOver(box(text(message), resizable(false), right(), bottom()));
}
