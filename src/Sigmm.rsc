module Sigmm

import lang::java::jdt::m3::Core;
import IO;

import analysis::Volume;
import analysis::CyclomaticComplexity;
import analysis::Duplication;
import analysis::UnitSize;
import analysis::UnitTestingSize;
import util::OverallRating;

void analyseMaintainability(loc project) {
	M3 model = createM3FromEclipseProject(project);
	
	println();
	println("======================================");
	println(" Metric Rating:");
	println("======================================");
	
	str volumeRating = volumeRating(model);
	println("Volume rating: \t\t\t" + volumeRating);
	
	str unitSizeRating = unitSizeRating(model);
	println("Unit Size rating: \t\t" + unitSizeRating);
	
	str unitTestingSizeRating = unitTestingSizeRating(model);
	println("Unit Testing Size rating: \t" + unitTestingSizeRating);
	
	str cyclomaticComplexityRating = cyclomaticComplexityRating(model);
	println("Cyclomatic Complexity rating:   " + cyclomaticComplexityRating);
	
	str duplicationRating = duplicationRating(model);
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
