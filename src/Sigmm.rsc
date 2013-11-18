module Sigmm

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

import extract::Volume;
import analysis::Volume;
import analysis::CyclomaticComplexity;
import analysis::Duplication;
import analysis::UnitSize;
import analysis::UnitTestingSize;
import util::OverallRating;

void analyseMaintainability(loc project) {
	M3 model = createM3FromEclipseProject(project);
	list[Declaration] methodAsts = [getMethodASTEclipse(method) | method <- methods(model)];
	
	println();
	println("======================================");
	println(" Metric Rating:");
	println("======================================");

	int totalProductionLoc = countTotalProductionLoc(model);	
	str volumeRating = volumeRating(totalProductionLoc);
	println("Volume rating: \t\t\t" + volumeRating);
	
	str unitSizeRating = unitSizeRating(methodAsts, totalProductionLoc);
	println("Unit Size rating: \t\t" + unitSizeRating);
	
	str unitTestingSizeRating = unitTestingSizeRating(methodAsts, totalProductionLoc);
	println("Unit Testing Size rating: \t" + unitTestingSizeRating);
	
	str cyclomaticComplexityRating = cyclomaticComplexityRating(methodAsts, totalProductionLoc);
	println("Cyclomatic Complexity rating:   " + cyclomaticComplexityRating);
	
	str duplicationRating = duplicationRating(methodAsts, totalProductionLoc);
	println("Duplication rating: \t\t" + duplicationRating);	
	
	println("======================================");
	println();
	
	printTotalResult(volumeRating, cyclomaticComplexityRating, duplicationRating, unitSizeRating, unitTestingSizeRating);
}

void printTotalResult(str volumeRating, str cyclomaticComplexityRating, str duplicationRating, str unitSizeRating, str unitTestingSizeRating) {
	str analyseabilityRating = getTotalRating([volumeRating, duplicationRating, unitSizeRating, unitTestingSizeRating]);
	str changeabilityRating = getTotalRating([cyclomaticComplexityRating, duplicationRating]);
	str stabilityRating = getTotalRating([unitTestingSizeRating]);
	str testabilityRating = getTotalRating([cyclomaticComplexityRating, unitSizeRating, unitTestingSizeRating]);
	
	println("======================================");
	println(" SIG Maintainability Rating:");
	println("======================================");
	println("Analyseability: \t\t" + analyseabilityRating);
	println("Changeability: \t\t\t" + changeabilityRating);
	println("Stability: \t\t\t" + stabilityRating);
	println("Testability: \t\t\t" + testabilityRating);
	println("======================================");
	println();
}
