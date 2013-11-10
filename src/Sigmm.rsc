module Sigmm

import analysis::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

import metric::Volume;
import metric::CyclomaticComplexity;
import metric::Duplication;
import metric::UnitSize;
import metric::UnitTestingSize;
import util::Rating;

void analyzeMaintainability(loc project) {
	M3 model = createM3FromEclipseProject(project);
	
	// TODO separate rating per category (e.g. analyzeability)
	str volumeRating = volumeRating(model);
	str cyclomaticComplexityRating = cyclomaticComplexityRating(model);
	str duplicationRating = duplicationRating(model);
	str unitSizeRating = unitSizeRating(model);
	str unitTestingSizeRating = unitTestingSizeRating(model);
	
	printResult(volumeRating, cyclomaticComplexityRating, duplicationRating, unitSizeRating, unitTestingSizeRating);
}

void printResult(str volumeRating, str cyclomaticComplexityRating, str duplicationRating, str unitSizeRating, str unitTestingSizeRating) {
	println();
	println("======================================");
	println(" Metric Rating:");
	println("======================================");
	println("Volume rating: \t\t\t" + volumeRating);
	println("Cyclomatic Complexity rating:   " + cyclomaticComplexityRating);
	println("Duplication rating: \t\t" + duplicationRating);
	println("Unit Size rating: \t\t" + unitSizeRating);
	println("Unit Testing Size rating: \t" + unitTestingSizeRating);
	println("======================================");
	println();
	
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
