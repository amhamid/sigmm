module extract::Volume

import lang::java::jdt::m3::Core;
import IO;

// calculate production code volume (excluding unit tests, comments and empty lines)
int countTotalProductionLoc(M3 model, list[loc] files) =
	countTotalLoc(model, files) - countTotalCommentedLoc(model, files) - countTotalEmptyLoc(model, files);

// calculate total line of code
int countTotalLoc(M3 model, list[loc] files) 
	= (0 | it + src.end.line | compilationUnit <- files, {src} := model@declarations[compilationUnit]);  	

// calculate total line of commented code (including javadocs)
int countTotalCommentedLoc(M3 model, list[loc] files) 
	= (0 | it + (doc.end.line - doc.begin.line + 1) | compilationUnit <- files, doc <- model@documentation[compilationUnit]); 

// calculate total of empty lines
int countTotalEmptyLoc(M3 model, list[loc] files) 
	= (0 | it + 1 | compilationUnit <- files, doc <- model@declarations[compilationUnit], /^\s*$/ <- readFileLines(doc));
