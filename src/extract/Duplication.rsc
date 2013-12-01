module extract::Duplication

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import String;

import util::Sanitizer;

int countTotalDuplication(list[Declaration] methodAsts) {
	int result = 0;
	lrel[loc, list[str], lrel[loc, list[str]]] duplicatedMethods = findDuplication(methodAsts);
	for(duplicatedMethod <- duplicatedMethods) {
		list[str] firstClone = duplicatedMethod[1];
		lrel[loc, list[str]] theRestOfClones = duplicatedMethod[2];
		result += size(firstClone) + (0 | it + size(clone[1]) | clone <- theRestOfClones);
	}
	return result;
}

lrel[loc, list[str], lrel[loc, list[str]]] findDuplication(list[Declaration] methodAsts) {
	lrel[loc, list[str]] allMethodLines = [];

	for(methodAst <- methodAsts) {
		if(/method(m,_,_,_) := methodAst@typ) {
			list[str] lines = [line | line <- sanitizeLines(readFileLines(m), ["\t", "{", "}"]), !isEmpty(line), !isComment(line)];
			if(size(lines) > 5) {
				allMethodLines += [<m, lines>];	
			}
		}
	}
	
	return getDuplicatedLines(allMethodLines);
}

// list of tuple of the original method and its list of clones
private lrel[loc, list[str], lrel[loc, list[str]]] getDuplicatedLines(lrel[loc, list[str]] allMethodLines) {
	lrel[loc, list[str], lrel[loc, list[str]]] result = [];
	lrel[loc, list[str]] totalDuplicateLines = [];
	
	if(size(allMethodLines) <= 1) {
		return [];
	} else {
		tuple[loc, list[str]] oneMethod = head(allMethodLines);
		lrel[loc, list[str]] theRestMethods = tail(allMethodLines);
		list[str] uniqueDuplicateLines = [];
		
		loc oneMethodLoc = oneMethod[0];
		list[str] oneMethodLines = oneMethod[1];
		oneMethodLines += "EOM"; // end of method (to identify the end of a method)
		
		lrel[loc, list[str]] theRestMethodLinesWithoutDuplicateFromFirstMethod = [];
		str separator = "\n\t.....\n";

		for(nextMethod <- theRestMethods) {
			loc nextMethodLoc = nextMethod[0];
			list[str] nextMethodLines = nextMethod[1];
			
			list[str] duplicateLinesInOneMethod = [];
			list[str] duplicateLinesInOneBlock = [];
			
			for(oneMethodLine <- oneMethodLines) {
				if(oneMethodLine in nextMethodLines && [*_, duplicateLinesInOneBlock, oneMethodLine, *_] := nextMethodLines) {
					duplicateLinesInOneBlock += oneMethodLine;
				} else if(size(duplicateLinesInOneBlock) > 5) {
					duplicateLinesInOneMethod += duplicateLinesInOneBlock + separator;
					if([*_, duplicateLinesInOneBlock, *_] !:= uniqueDuplicateLines) {
						uniqueDuplicateLines += duplicateLinesInOneBlock + separator;					
					}
					duplicateLinesInOneBlock = [];
				} else {
					duplicateLinesInOneBlock = [];
				}		
			}
			
			if(!isEmpty(duplicateLinesInOneMethod)) {
				totalDuplicateLines += [<nextMethodLoc, duplicateLinesInOneMethod>];
			}
			
			// remove the duplicate found from the 'otherMethodLines'
			theRestMethodLinesWithoutDuplicateFromFirstMethod += <nextMethodLoc, (nextMethodLines - duplicateLinesInOneMethod)>;
		}
		
		if(size(totalDuplicateLines) > 0) {
			// including the number of duplicate lines from the first method itself 
			//(e.g. 4 methods with 5 lines duplicate on all of them then the number of duplicate 
			//is 15 lines from 3 methods + 5 from the first methods = 20 total of duplicate lines)
			result += <oneMethodLoc, uniqueDuplicateLines, totalDuplicateLines>;
		}
		
		return result + getDuplicatedLines(theRestMethodLinesWithoutDuplicateFromFirstMethod);
	}
}
