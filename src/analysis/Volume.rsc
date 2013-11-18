module analysis::Volume

import IO;

// calculate volume rating (excluding comments and empty lines)
str volumeRating(int volume) {
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
