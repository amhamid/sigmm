module extract::Duplication

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import String;

import util::Sanitizer;

int countTotalDuplication(list[Declaration] methodAsts) {
	
	int totalDuplication = 0;
	list[Declaration] alreadyProcessedAst = [];
	
	for(ast <- methodAsts) {
		// the rest of the ASTs (not including the actual method and the one that is already processed)
		list[Declaration] theRestOfAsts = [x | x <- methodAsts, x !:= ast && x notin alreadyProcessedAst];
		totalDuplication += countDuplicationPerMethod(ast, theRestOfAsts);
		alreadyProcessedAst += ast;
	}

	return totalDuplication;
}

private int countDuplicationPerMethod(Declaration methodAst, list[Declaration] theRestOfMethodAsts) {
	list[str] duplicateLines = [];
	
	if(/method(m,_,_,_) := methodAst@typ) {
		list[str] astLines = [line | line <- sanitizeLines(readFileLines(m), ["\t", "{", "}"]), !isEmpty(line), !isComment(line)];
		astLines += "EOM"; // end of method (to identify the end of a method)
		
		for(otherMethodAst <- theRestOfMethodAsts) {
			list[str] tmp = [];
			if(/method(otherMethod,_,_,_) := otherMethodAst@typ) {
				list[str] otherAstLines = [line | line <- sanitizeLines(readFileLines(otherMethod), ["\t", "{", "}"]), !isEmpty(line), !isComment(line)];
		
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
		}
	}
	
	return size(duplicateLines); 
}
