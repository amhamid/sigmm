module metric::UnitSize

import analysis::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import Number;

import metric::Volume;
import metric::CyclomaticComplexity;

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

// calculate method size excluding comments
list[int] unitSizePerUnit(M3 model) =
	[unitSize(declr[1], doc[1]) | declr <- model@declarations, doc <- model@documentation, isMethod(declr[0]) && declr[1].begin.line == doc[1].begin.line];

// calculate method size excluding comments
int unitSize(M3 model, loc methodSrc) =
	(0 | it + unitSize(methodSrc, doc[1]) | doc <- model@documentation, methodSrc.begin.line == doc[1].begin.line);

private int unitSize(loc methodSrc, loc methodDoc) =
	(methodSrc.end.line-methodSrc.begin.line) - (methodDoc.end.line-methodDoc.begin.line);
