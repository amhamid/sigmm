module Sigmm

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import String;
import util::FileSystem;

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

	int totalProductionLoc = countTotalProductionLoc(model, filesWithoutJUnit);	
	str volumeRating = volumeRating(totalProductionLoc);
	println("Volume: \t\t\t" + volumeRating);
	
	str unitSizeRating = unitSizeRating(methodAsts, totalProductionLoc);
	println("Unit Size: \t\t\t" + unitSizeRating);
	
	str cyclomaticComplexityRating = cyclomaticComplexityRating(methodAsts, totalProductionLoc);
	println("Cyclomatic Complexity: \t\t" + cyclomaticComplexityRating);
	
	str duplicationRating = duplicationRating(methodAsts, totalProductionLoc);
	println("Duplication: \t\t\t" + duplicationRating);	
	
	println("======================================");
	println();
	
	printTotalResult(volumeRating, cyclomaticComplexityRating, duplicationRating, unitSizeRating);
}

void printTotalResult(str volumeRating, str cyclomaticComplexityRating, str duplicationRating, str unitSizeRating) {
	str analyseabilityRating = getTotalRating([volumeRating, duplicationRating, unitSizeRating]);
	str changeabilityRating = getTotalRating([cyclomaticComplexityRating, duplicationRating]);
	str testabilityRating = getTotalRating([cyclomaticComplexityRating, unitSizeRating]);
	
	println("======================================");
	println(" SIG Maintainability Rating:");
	println("======================================");
	println("Analyseability: \t\t" + analyseabilityRating);
	println("Changeability: \t\t\t" + changeabilityRating);
	println("Testability: \t\t\t" + testabilityRating);
	println("======================================");
	println();
}
