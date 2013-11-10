module metric::Volume

import analysis::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

str volumeRating(M3 model) = 
	getRating(volume(model));

// calculate production code volume (excluding comments and empty lines)
int volume(M3 model) =
	countTotalLoc(model) - countTotalCommentedLoc(model) - countTotalEmptyLoc(model);

// calculate total line of code
int countTotalLoc(M3 model) 
	= (0 | it + src.end.line | compilationUnit <- files(model), {src} := model@declarations[compilationUnit]);  	

// calculate total line of commented code (including javadocs)
int countTotalCommentedLoc(M3 model) 
	= (0 | it + (doc.end.line - doc.begin.line + 1) | compilationUnit <- files(model), doc <- model@documentation[compilationUnit]); 

// calculate total of empty lines
int countTotalEmptyLoc(M3 model) 
	= (0 | it + 1 | compilationUnit <- files(model), doc <- model@declarations[compilationUnit], /^\s*$/ <- readFileLines(doc));

private str getRating(int volume) {
	int kloc = volume / 1000;
	str result = "";
	
	if(kloc >= 0 && kloc < 66) {
		result = "++";
	} else if(kloc >= 66 && kloc < 246) {
		result = "+";
	} else if(kloc >= 246 && kloc < 665) {
		result = "o";
	} else if(kloc >= 665 && kloc < 1310) {
		result = "-";
	} else {
		result = "--";
	}
	
	return result;
}
