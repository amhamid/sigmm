module visualization::ToxityChart

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import vis::Figure;
import vis::Render;
import IO;
import String;
import List;

import util::Sanitizer;
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

// example
Figure x1 = createABar(20,30);
Figure x2 = createABar(20,100);
Figure chart() = generateChart([x1, x2]);

// render(chart())

void renderToxityChart(loc project) {
	// create M3 model from the project
	M3 model = createM3FromEclipseProject(project);

	// filter out any files that are not production code (such as junit, samples, generated code, etc.)
	list[loc] productionSourceFiles = [file | file <- files(model), isProductionSourceFile(file.path)];
	
	// map of path -> list of file and list of method asts
	map[str,tuple[list[loc], list[Declaration]]] packages = ();
	
	// group files and method asts into each package path 
	for(loc file <- productionSourceFiles) {
		list[Declaration] methodAsts = [ d | /Declaration d := createAstFromFile(file, true), d is method];		 
		str path = substring(file.path, 0, findLast(file.path, "/"));
		packages = addToPackage(path, packages, file, methodAsts);		
	}
	
	list[Figure] bars = [];
	
	// calculate metrics and generate vertical bar
	for(str package <- packages) {
		
		list[loc] files = (packages[package])[0];
		list[Declaration] methodAsts = (packages[package])[1];
		
		int volume = calculateVolume(files);
		int duplication = countTotalDuplication(methodAsts);
		
		bars += createABar(volume, duplication);
	}	
	
	Figure toxityChart = generateChart(bars);
	render(toxityChart);

}

// add to package so that we have a map with key is path and the value is a tuple with first element list of files and second element is list of method asts
map[str,tuple[list[loc], list[Declaration]]] addToPackage(str path, map[str,tuple[list[loc], list[Declaration]]] packages, loc file, list[Declaration] newMethodAsts) {
	if(path in packages) {
		list[loc] files = (packages[path])[0] + file;
		list[Declaration] methodAsts = (packages[path])[1] + newMethodAsts;
		packages += (path: <files, methodAsts>);
	} else {
		packages += (path: <[file], newMethodAsts>);
	}
	
	return packages;
}

int calculateVolume(list[loc] files) {
	list[str] lines = [];
	for(loc file <- files) {
		lines += [line | line <- sanitizeLines(readFileLines(file), []), !isEmpty(line), !isComment(line)];
	}

	return size(lines);
}
