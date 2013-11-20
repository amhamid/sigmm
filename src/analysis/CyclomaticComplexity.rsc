module analysis::CyclomaticComplexity

import lang::java::jdt::m3::AST;
import IO;
import util::Math;

import extract::CyclomaticComplexity;

// calculate cyclomatic complexity rating 
// return a tuple with [rating, mediumRiskPercentage, highRiskPercentage, veryHighRiskPercentage]
tuple[str, real, real, real] cyclomaticComplexityRating(list[Declaration] methodAsts, int totalProductionLoc) {
	result = "";
	list[tuple[int,int]] complexityUnits = cyclomaticComplexityPerUnit(methodAsts);
	
	// filtering the risk into moderate, high and very high risk
	list[tuple[int,int]] moderateRisk = [<x, y> | <x,y> <- complexityUnits, x > 10, x <= 20];
	list[tuple[int,int]] highRisk = [<x, y> | <x,y> <- complexityUnits, x > 20, x <= 50];
	list[tuple[int,int]] veryHighRisk = [<x, y> | <x,y> <- complexityUnits, x > 50];
	
	// calculating total line of code per risk
	int moderateRiskTotalLoc = (0 | it + y | <x,y> <- moderateRisk); 
	int highRiskTotalLoc = (0 | it + y | <x,y> <- highRisk);
	int veryHighRiskTotalLoc = (0 | it + y | <x,y> <- veryHighRisk);

	// calculating percentage of the risks
	real moderateRiskPercentage = toReal(moderateRiskTotalLoc)/totalProductionLoc * 100;
	real highRiskPercentage = toReal(highRiskTotalLoc)/totalProductionLoc * 100;
	real veryHighRiskPercentage = toReal(veryHighRiskTotalLoc)/totalProductionLoc * 100;
	str rating = getRating(moderateRiskPercentage, highRiskPercentage, veryHighRiskPercentage);
	
	return <rating, moderateRiskPercentage, highRiskPercentage, veryHighRiskPercentage>;
}

private str getRating(real moderateRiskPercentage, real highRiskPercentage, real veryHighRiskPercentage) {
	str result = "";
		
	if(moderateRiskPercentage <= 25 && highRiskPercentage == 0 && veryHighRiskPercentage == 0) {
		result = "++";
	} else if(moderateRiskPercentage <= 30 && highRiskPercentage <= 5 && veryHighRiskPercentage == 0) {
		result = "+";
	} else if(moderateRiskPercentage <= 40 && highRiskPercentage <= 10 && veryHighRiskPercentage == 0) {
		result = "o";
	} else if(moderateRiskPercentage <= 50 && highRiskPercentage <= 15 && veryHighRiskPercentage <= 5) {
		result = "-";
	} else {
		result = "--";
	}
	
	return result;
}
