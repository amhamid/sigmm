module analysis::Duplication

import lang::java::jdt::m3::Core;
import IO;
import Number;

import extract::Duplication;
import extract::Volume;

str duplicationRating(M3 model) {
	int totalLoc = countTotalLoc(model);
	int totalCodeDuplication = countTotalDuplication(model);
	return getRating(toReal(totalCodeDuplication)/totalLoc * 100);
}

private str getRating(real totalCodeDuplication) {
	str result = "";
		
	if(totalCodeDuplication >= 0 && totalCodeDuplication <= 3) {
		result = "++";
	} else if(totalCodeDuplication > 3 && totalCodeDuplication <= 5) {
		result = "+";
	} else if(totalCodeDuplication > 5 && totalCodeDuplication <= 10) {
		result = "o";
	} else if(totalCodeDuplication > 10 && totalCodeDuplication <= 20) {
		result = "-";
	} else {
		result = "--";
	}
	
	return result;
}
