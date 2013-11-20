module Sigmm

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import String;
import util::FileSystem;
import util::Math;

import extract::Volume;
import analysis::Volume;
import analysis::CyclomaticComplexity;
import analysis::Duplication;
import analysis::UnitSize;
import util::OverallRating;

void analyseMaintainability(loc project) {
	M3 model = createM3FromEclipseProject(project);

	// filter out any files with junit 
	list[loc] filesWithoutJUnit = [file | file <- files(model), !contains(file.path, "/test/"), !contains(file.path, "/junit/")];
	
	// get AST for all methods (excluding junit)
	list[Declaration] methodAsts = [ *[ d | /Declaration d := createAstFromFile(file, true), d is method] | file <- filesWithoutJUnit];
	
	println();
	println("======================================");
	println(" Metric Rating:");
	println("======================================");
	
	// Volume analysis
	int totalProductionLoc = countTotalProductionLoc(model, filesWithoutJUnit);
	str volumeRating = volumeRating(totalProductionLoc);
	println("Volume: <volumeRating>");
	println("* Size: <totalProductionLoc> LOC");
	
	// Unit Size analysis returns a tuple with [rating, mediumRiskPercentage, highRiskPercentage, veryHighRiskPercentage]
	tuple[str, real, real, real] unitSizeMetric = unitSizeRating(methodAsts, totalProductionLoc);
	str unitSizeRating = unitSizeMetric[0];
	int unitSizeModerateRiskPercentage = toInt(unitSizeMetric[1]);
	int unitSizeHighRiskPercentage = toInt(unitSizeMetric[2]);
	int unitSizeVeryHighRiskPercentage = toInt(unitSizeMetric[3]);
	println();
	println("Unit Size: <unitSizeRating>");
	printRiskPercentage(unitSizeModerateRiskPercentage, unitSizeHighRiskPercentage, unitSizeVeryHighRiskPercentage);
	
	// Cyclomatic Complexity analysis returns a tuple with [rating, mediumRiskPercentage, highRiskPercentage, veryHighRiskPercentage]
	tuple[str, real, real, real] cyclomaticComplexityMetric = cyclomaticComplexityRating(methodAsts, totalProductionLoc);
	str cyclomaticComplexityRating = cyclomaticComplexityMetric[0];
	int cyclomaticComplexityModerateRiskPercentage = toInt(cyclomaticComplexityMetric[1]);
	int cyclomaticComplexityHighRiskPercentage = toInt(cyclomaticComplexityMetric[2]);
	int cyclomaticComplexityVeryHighRiskPercentage = toInt(cyclomaticComplexityMetric[3]);
	println();
	println("Cyclomatic Complexity: <cyclomaticComplexityRating>");
	printRiskPercentage(cyclomaticComplexityModerateRiskPercentage, cyclomaticComplexityHighRiskPercentage, cyclomaticComplexityVeryHighRiskPercentage);
	
	tuple[str, int] duplicationMetric = duplicationRating(methodAsts, totalProductionLoc);
	str duplicationRating = duplicationMetric[0];
	int totalDuplicationLoc = duplicationMetric[1];
	real duplicationPercentage = toReal(totalDuplicationLoc)/totalProductionLoc * 100;
	println();
	println("Duplication: <duplicationRating>");	
	println("* Total duplication: <totalDuplicationLoc> LOC (<toInt(duplicationPercentage)>%)");	
	
	println("======================================");
	println();
	
	printTotalResult(volumeRating, cyclomaticComplexityRating, duplicationRating, unitSizeRating);
}

private void printRiskPercentage(int moderateRiskPercentage, int highRiskPercentage, int veryHighRiskPercentage) {
	println("* Moderate Risk: <moderateRiskPercentage>%");
	println("* High Risk: <highRiskPercentage>%");
	println("* Very High Risk: <veryHighRiskPercentage>%");
}

private void printTotalResult(str volumeRating, str cyclomaticComplexityRating, str duplicationRating, str unitSizeRating) {
	str analyseabilityRating = getTotalRating([volumeRating, duplicationRating, unitSizeRating]);
	str changeabilityRating = getTotalRating([cyclomaticComplexityRating, duplicationRating]);
	str testabilityRating = getTotalRating([cyclomaticComplexityRating, unitSizeRating]);
	
	println("======================================");
	println(" SIG Maintainability Rating:");
	println("======================================");
	println("Analyseability: <analyseabilityRating>");
	println("Changeability: <changeabilityRating>");
	println("Testability: <testabilityRating>");
	println("======================================");
	println();
}
