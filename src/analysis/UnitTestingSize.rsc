module analysis::UnitTestingSize

import lang::java::jdt::m3::Core;
import IO;
import util::Math;

import extract::UnitTestingSize;
import extract::Volume;

str unitTestingSizeRating(M3 model) {
	int totalLoc = countTotalLoc(model);
	list[tuple[int,int]] unitTestings = unitTestingSizePerUnit(model);
	
	// calculating covered LOC
	int totalLocCovered = (0 | it + y | <x,y> <- unitTestings); 
	
	// calculating percentage of coverage 
	real totalCoveragePercentage = toReal(totalLocCovered)/totalLoc * 100;
	
	return getRating(totalCoveragePercentage);
}

private str getRating(real totalCoveragePercentage) {
	str result = "";
		
	if(totalCoveragePercentage <= 20) {
		result = "--";
	} else if(totalCoveragePercentage > 20 && totalCoveragePercentage <= 60) {
		result = "-";
	} else if(totalCoveragePercentage > 60 && totalCoveragePercentage <= 80) {
		result = "o";
	} else if(totalCoveragePercentage > 80 && totalCoveragePercentage <= 95) {
		result = "+";
	} else {
		result = "++";
	}
	
	return result;
}

