module extract::Duplication

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import IO;
import List;
import Set;
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
	list[str] astLines = sanitizeLine(readFileLines(ast@src), ["\t"]);
	list[str] duplicateLines = [];

	for(otherAst <- theRestOfAsts) {
		list[str] tmp = [];
		list[str] otherAstLines = sanitizeLine(readFileLines(otherAst@src), ["\t", "{", "}"]);
		
		// iterate over non-empty astLines	
		for(astLine <- astLines, (size(otherAstLines) > 5) && !isEmpty(astLine)) {
			if(astLine in otherAstLines) {
				tmp += astLine;	
			} else {
				// count as duplicate if size is > 5 
				if(size(tmp) > 5 && [*_, tmp, *_] := otherAstLines) {
					duplicateLines += tmp;	
					tmp = [];			
				} else {
					tmp = [];
				}
			}		
		}
	}
	
	return size(duplicateLines); 
}

// sanitize lines 
private list[str] sanitizeLine(list[str] lines, list[str] chars) {
	list[str] result = [];
	str tmp;
	for(line <- lines) {
		tmp = line;
		for(char <- chars) {
			tmp = replaceAll(tmp, char, "");
		}
		result += tmp;	
	}
	
	return result;
}
