module visualization::ToxityChart

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import vis::Figure;
import vis::Render;
import IO;
import String;
import List;

import util::ProjectStructure;
import util::Sanitizer;
import extract::Volume;
import extract::Duplication;


// TODO add tool tip with package name
// TODO refactor + clean up


// create a vertical bar
Figure createABar(int volumeKloc, int duplication) {
	int width = 15;
	list[Figure] boxes = [];

	boxes += box(size(width, duplication), fillColor("blue"));	
	boxes += box(size(width, volumeKloc), fillColor("red"));
	
	return vcat(boxes, std(left()), std(bottom()), std(resizable(false)));
}

// combine all vertical bars into a horizontal line so that it makes a chart
Figure generateChart(list[Figure] bars) {
	return box(hcat(bars, gap(2), std(left()), std(bottom()), std(resizable(false))));
}

void renderToxityChart(loc project) {
	map[str,tuple[list[loc], list[Declaration]]] packages = readProjectStructure(project);
	
	list[Figure] bars = [];
	
	// calculate metrics and generate vertical bar
	for(str package <- packages) {		
		list[loc] files = (packages[package])[0];
		list[Declaration] methodAsts = (packages[package])[1];
		
		int volume = countTotalProductionLoc(files);
		int duplication = countTotalDuplication(methodAsts);
		
		bars += createABar(volume, duplication);
	}	
	
	Figure toxityChart = generateChart(bars);
	render(toxityChart);
}
