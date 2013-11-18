module analysis::UnitTestingSize

import lang::java::jdt::m3::AST;
import IO;
import util::Math;

import extract::UnitTestingSize;

str unitTestingSizeRating(list[Declaration] methodAsts, int totalProductionLoc) {
	int totalLocCovered = totalUnitTestingSize(methodAsts);
	real totalCoveragePercentage = toReal(totalLocCovered)/totalProductionLoc * 100;
	
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

