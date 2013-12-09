module visualization::VolumeUnitBar

import analysis::CyclomaticComplexity;
import analysis::Volume;
import analysis::UnitSize;
import extract::UnitSize;
import extract::Volume;
import IO;
import List;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import String;
import util::FileSystem;
import util::Math;
import util::Sanitizer;
import util::Visualization;
import vis::Figure;
import vis::KeySym;
import vis::Render;

//generate all boxes
void generateVolumeBar() {
	list[tuple[loc, int, map[loc, int], int]] spfau = getSizePerFileAndUnit();	
	volumeBar = generateFileVolumeBar(spfau);
	render(volumeBar);
}

//generate unit size and cyclomatic complexity color rating per file
void generateFileVolumeCcBar() {
	list[tuple[loc, int, map[loc, int], int]] spfau = getSizePerFileAndUnit();
	lrel[loc, lrel[loc, int]] coll = [];
	
	for(s <- spfau) {
		coll += [<s[0], [<uas, s[2][uas]> | uas <- s[2]]>];
	}
	render(generateVolumeAndCcBar(coll));	
}

//generate box figures for files, total loc, unit, size per unit and total unit loc
Figure generateFileVolumeBar(list[tuple[loc, int, map[loc, int], int]] collection) {
	int fileAndSizeIndex = 1;
	int unitAndSizeIndex = 2;
	int totalUnitSize = 3;	
	list[Figure] boxes = [];
			
	for(c <- collection) {
		boxes += box(generateUnitVolumeBar(c[unitAndSizeIndex]), size(50,c[totalUnitSize]), fillColor("green"), resizable(false));
	}
	return pack(boxes, gap(10));
}

//generate volume and cyclomatic complexity color per unit in file
Figure generateVolumeAndCcBar(lrel[loc, lrel[loc, int]] fileUnits) {
	list[Figure] boxes = [];
	
	for(fileUnit <- fileUnits) {
		str filename = fileUnit[0].file;
		boxes += generateUnitVolumeCcBox(filename, fileUnit[1]);
	}	
	return pack(boxes, gap(50));
}

//generate size and cyclomatic color per unit
Figure generateUnitVolumeCcBox(str filename, lrel[loc, int] unitAndCc) {
	list[Figure] boxes = [box(size(50, unitSize(uac.unit)), openMethodOnClick(uac.unit), fillColor(cycloComplexityColorRating(uac.cylomaticComplexity)), resizable(false)) | tuple[loc unit, int cylomaticComplexity] uac <- unitAndCc];
	return vcat(boxes, popup(filename));
}

// generate box figures for unit size
Figure generateUnitVolumeBar(map[loc, int] unitAndSize) {
	return vcat([box(size(50, unitAndSize[unit]), fillColor(cycloComplexityColorRating(unitAndSize[unit])), resizable(false)) | unit <- unitAndSize], resizable(false));
}

list[tuple[loc, int, map[loc, int], int]] getSizePerFileAndUnit() {
	tuple[M3 model, list[loc] files] maf = getModelAndFiles();
	list[tuple[loc, int, map[loc, int], int]] spfau = countFileAndMethodLoc(maf.files);
	return spfau;
}

tuple[M3, list[loc]] getModelAndFiles() {
	loc _project = |project://smallsql0.21_src|;
	M3 model = createM3FromEclipseProject(_project);
	list[loc] productionSourceFiles = [file | file <- files(model), isProductionSourceFile(file.path)];
	return <model, productionSourceFiles>;
}

private FProperty popup(str message) {
	return mouseOver(box(text(message), resizable(false)));
}
