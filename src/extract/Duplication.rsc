module extract::Duplication

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import IO;
import List;
import String;

int countTotalDuplication(M3 model) {
	list[Declaration] asts = [getMethodASTEclipse(method) | method <- methods(model)];
	
	int totalDuplication = 0;
	list[Declaration] alreadyProcessedAst = [];
	
	for(ast <- asts) {
		// the rest of the ASTs (not including the actual method and the one that is already processed)
		list[Declaration] theRestOfAsts = [x | x <- asts, x !:= ast && x notin alreadyProcessedAst];
		totalDuplication += countDuplicationPerMethod(ast, theRestOfAsts);
		alreadyProcessedAst += ast;
	}

	return totalDuplication;
}

private int countDuplicationPerMethod(Declaration ast, list[Declaration] theRestOfAsts) {
	list[str] astLines = sanitizeLines(readFileLines(ast@src));
	list[list[str]] duplicateLinesPerMethod = [];

	for(otherAst <- theRestOfAsts) {
		list[str] tmp = [];
		list[str] otherAstLines = sanitizeLines(readFileLines(otherAst@src));
		
		// iterate over non-empty astLines	
		for(astLine <- astLines, !isEmpty(astLine)) {
			if(astLine in otherAstLines) {
				tmp += astLine;	
			} else {
				// count as duplicate if size is > 5 
				if(size(tmp) > 5) {
					duplicateLinesPerMethod += [tmp];	
					tmp = [];			
				} else {
					tmp = [];
				}
			}		
		}

		// it will be useful only when two methods are completely identical (otherwise [] will be added)
		duplicateLinesPerMethod += [tmp];
	}
	
	return (0 | it + size(xs) | xs <- duplicateLinesPerMethod); 
}

// sanitize lines from '\t', '{' and '}' chars 
private list[str] sanitizeLines(list[str] lines) {
	list[str] result = [];
	str tmp;
	for(line <- lines) {
		tmp = replaceAll(line, "\t", "");
		tmp = replaceAll(tmp, "{", "");
		tmp = replaceAll(tmp, "}", "");
		result += tmp;	
	}
	
	return result;
}
