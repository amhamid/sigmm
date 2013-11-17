module analysis::UnitSize

import lang::java::jdt::m3::Core;
import IO;
import util::Math;

import extract::Volume;
import extract::UnitSize;
import analysis::CyclomaticComplexity;

// calculate unit size rating
str unitSizeRating(M3 model) {
	int totalLoc = countTotalLoc(model);
	list[int] unitSizeUnits = unitSizePerUnit(model);
	
	// filtering the risk into moderate, high and very high risk
	list[int] moderateRisk = [x | x <- unitSizeUnits, x > 20, x <= 50];
	list[int] highRisk = [x | x <- unitSizeUnits, x > 50, x <= 100];
	list[int] veryHighRisk = [x | x <- unitSizeUnits, x > 100];
	
	// calculating total line of code per risk
	int moderateRiskTotalLoc = (0 | it + x | x <- moderateRisk); 
	int highRiskTotalLoc = (0 | it + x | x <- highRisk);
	int veryHighRiskTotalLoc = (0 | it + x | x <- veryHighRisk);

	// calculating percentage of the risks
	real moderateRiskPercentage = toReal(moderateRiskTotalLoc)/totalLoc * 100;
	real highRiskPercentage = toReal(highRiskTotalLoc)/totalLoc * 100;
	real veryHighRiskPercentage = toReal(veryHighRiskTotalLoc)/totalLoc * 100;
	
	return getRating(moderateRiskPercentage, highRiskPercentage, veryHighRiskPercentage);
}
