module analysis::Duplication

import lang::java::jdt::m3::Core;
import IO;

import extract::Duplication;
import extract::Volume;

str duplicationRating(M3 model) {
	int totalLoc = countTotalLoc(model);
	int totalCodeDuplication = countTotalDuplication(model);
	return getRating(toReal(totalCodeDuplication)/totalLoc * 100);
}

private str getRating(real totalCodeDuplication) {
	str result = "";
		
	if(totalCoveragePercentage >= 0 && totalCoveragePercentage <= 3) {
		result = "++";
	} else if(totalCoveragePercentage > 3 && totalCoveragePercentage <= 5) {
		result = "+";
	} else if(totalCoveragePercentage > 5 && totalCoveragePercentage <= 10) {
		result = "o";
	} else if(totalCoveragePercentage > 10 && totalCoveragePercentage <= 20) {
		result = "-";
	} else {
		result = "--";
	}
	
	return result;
}
