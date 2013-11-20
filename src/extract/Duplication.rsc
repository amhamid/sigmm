module extract::Duplication

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import String;

import util::Sanitizer;

int countTotalDuplication(list[Declaration] methodAsts) {
	list[list[str]] allMethodLines = [];

	for(methodAst <- methodAsts) {
		if(/method(m,_,_,_) := methodAst@typ) {
			list[str] lines = [line | line <- sanitizeLines(readFileLines(m), ["\t", "{", "}"]), !isEmpty(line), !isComment(line)];
			if(size(lines) > 5) {
				allMethodLines += [lines];	
			}
		}
	}
	
	return (0 | it + size(duplicateLines) | duplicateLines <- getDuplicatedLines(allMethodLines));
}

private list[list[str]] getDuplicatedLines(list[list[str]] allMethodLines) {
	list[list[str]] totalDuplicateLines = [];
	
	if(size(allMethodLines) <= 1) {
		return [];
	} else {
		list[str] oneMethodLines = head(allMethodLines);
		oneMethodLines += "EOM"; // end of method (to identify the end of a method)
		list[list[str]] theRestMethodLinesWithoutDuplicateFromFirstMethod = [];

		for(nextMethodLines <- tail(allMethodLines)) {
			list[str] duplicateLinesInOneMethod = [];
			list[str] duplicateLinesInOneBlock = [];
			
			for(oneMethodLine <- oneMethodLines) {
				if(oneMethodLine in nextMethodLines && [*_, duplicateLinesInOneBlock, oneMethodLine, *_] := nextMethodLines) {
					duplicateLinesInOneBlock += oneMethodLine;
				} else if(size(duplicateLinesInOneBlock) > 5) {
					totalDuplicateLines += [duplicateLinesInOneBlock];
					duplicateLinesInOneMethod += duplicateLinesInOneBlock;
					duplicateLinesInOneBlock = [];
				} else {
					duplicateLinesInOneBlock = [];
				}		
			}
			
			// remove the duplicate found from the 'otherMethodLines'
			theRestMethodLinesWithoutDuplicateFromFirstMethod += [ nextMethodLines - duplicateLinesInOneMethod ];
		}
		
		if(size(totalDuplicateLines) > 0) {
			// including the number of duplicate lines from the first method itself 
			//(e.g. 4 methods with 5 lines duplicate on all of them then the number of duplicate 
			//is 15 lines from 3 methods + 5 from the first methods = 20 total of duplicate lines)
			totalDuplicateLines = totalDuplicateLines + [totalDuplicateLines[0]];
		}
		
		return totalDuplicateLines + getDuplicatedLines(theRestMethodLinesWithoutDuplicateFromFirstMethod);
	}
}
