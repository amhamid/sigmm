module visualization::VolumeUnitBar

import analysis::Volume;
import analysis::UnitSize;
import extract::Volume;
import IO;
import List;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import String;
import util::FileSystem;
import util::Math;
import util::Sanitizer;
import vis::Figure;
import vis::KeySym;
import vis::Render;

void generateVolumeBar() {
	list[tuple[loc, int, map[loc, int]]] spfau = getSizePerFileAndUnit();	
	volumeBar = generateFileVolumeBar(spfau);
	render(volumeBar);
}

Figure generateFileVolumeBar(list[tuple[loc, int, map[loc, int]]] spfau) {
	int fileAndSizeIndex = 1;
	int unitAndSizeIndex = 2;	
	list[Figure] boxes = [];		
	for(s <- spfau) {		
		//iprintln(s);		
		boxes += box(generateUnitVolumeBar(s[unitAndSizeIndex]), size(50,s[fileAndSizeIndex]), fillColor("green"), resizable(false));
	}
	return hcat(boxes, gap(0), std(left()), std(top()), resizable(false));
}

Figure generateUnitVolumeBar(map[loc, int] unitAndSize) {
	return vcat([box(size(50, unitAndSize[unit]), fillColor("yellow"), resizable(false)) | unit <- unitAndSize], resizable(false));
}

list[tuple[loc, int, map[loc, int]]] getSizePerFileAndUnit() {
	tuple[M3 model, list[loc] files] maf = getModelAndFiles();
	return countFileAndMethodLoc(maf.files);
}

tuple[M3, list[loc]] getModelAndFiles() {
	loc _project = |project://simpletest|;
	M3 model = createM3FromEclipseProject(_project);
	list[loc] productionSourceFiles = [file | file <- files(model), isProductionSourceFile(file.path)];
	return <model, productionSourceFiles>;
}




