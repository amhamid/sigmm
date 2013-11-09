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

str analyzeMaintainability() {
	loc project = |project://SimpleJavaProject/|;
	M3 model = createM3FromEclipseProject(project);
	set[Declaration] ast = createAstsFromEclipseProject(project, true);
	
	// TODO separate rating per category (e.g. analyzeability)
	return volumeRating(model) + unitTestingSize(model);
}
