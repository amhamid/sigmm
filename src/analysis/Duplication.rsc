module analysis::Duplication

import lang::java::jdt::m3::AST;
import IO;
import util::Math;

import extract::Duplication;

// calculate total of duplication line of code
// returns a tuple[rating, totalDuplicationLine]
tuple[str, int] duplicationRating(list[Declaration] methodAsts, int totalProductionLoc) {
	int totalCodeDuplication = countTotalDuplication(methodAsts);
	str rating = getRating(toReal(totalCodeDuplication)/totalProductionLoc * 100);
	return <rating, totalCodeDuplication>;
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
