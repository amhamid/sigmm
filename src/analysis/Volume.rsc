module analysis::Volume

import lang::java::jdt::m3::Core;
import IO;

import extract::Volume;

// calculate volume rating (excluding comments and empty lines)
str volumeRating(M3 model) = 
	getRating(countTotalProductionLoc(model));

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
