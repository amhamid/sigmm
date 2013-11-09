module metric::Volume

import analysis::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

str volumeRating(M3 model) {
		int volume = (0 | it + (countTotalLoc(model, file) - countTotalCommentedLoc(model, file) - countTotalEmptyLoc(model, file)) | file <- files(model));
		return getRating(volume);
	}		 

private int countTotalLoc(M3 model, loc file) 
	= src.end.line when {src} := model@declarations[file];	

private int countTotalCommentedLoc(M3 model, loc file) 
	= (0 | it + (doc.end.line - doc.begin.line + 1) | doc <- model@documentation[file]); 

private int countTotalEmptyLoc(M3 model, loc file) 
	= (0 | it + 1 | loc doc <- model@declarations[file], /^\s*$/ <- readFileLines(doc));

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
