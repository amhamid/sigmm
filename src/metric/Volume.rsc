module metric::Volume

import analysis::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

int volume(M3 model) 
	= (0 | it + (countTotalLoc(model, file) - countTotalCommentedLoc(model, file) - countTotalEmptyLoc(model, file)) | file <- files(model));		 

private int countTotalLoc(M3 model, loc file) 
	= src.end.line when {src} := model@declarations[file];	

private int countTotalCommentedLoc(M3 model, loc file) 
	= (0 | it + (doc.end.line - doc.begin.line + 1) | doc <- model@documentation[file]); 

private int countTotalEmptyLoc(M3 model, loc file) 
	= (0 | it + 1 | loc doc <- model@declarations[file], /^\s*$/ <- readFileLines(doc));


// TODO add classification
