module extract::Duplication

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import extract::UnitSize;

// remove it
import IO;
import List;
import Set;
import String;

// TODO define how to find duplication

int countTotalDuplication(M3 model) = (0 | it + x | x <- duplicationPerUnit(model));

list[int] duplicationPerUnit(M3 model) {
	list[Declaration] asts = [getMethodASTEclipse(method) | method <- methods(model)];
	list[int] duplications = [];

	for(ast <- asts) {
		list[Declaration] theRestOfAsts = [x | x <- asts, x !:= ast];
		duplications += countDuplication(ast, theRestOfAsts);
	}

	return duplications;
}

private int countDuplication(Declaration ast, list[Declaration] theRestOfAsts) {
	int result = 0;
	list[str] lines = sanitizeList(readFileLines(ast@src));
	for(otherAst <- theRestOfAsts) {
		list[str] otherAstLines = sanitizeList(readFileLines(otherAst@src));
		
		// find duplicate lines
		set[str] duplicateLines = {x | x <- lines, y <- otherAstLines, (x==y) && !isEmpty(x) && !isEmpty(y)};
		int duplicateSize = size(duplicateLines);
		
		// only add to the result when duplicate > 5
		if(duplicateSize > 5) {
			list[tuple[int,str]] index = [];
			for(duplicateLine <- duplicateLines) {
				index += <indexOf(lines, duplicateLine), duplicateLine>;
			}
			iprintln(index);
			result += duplicateSize;
		}
	}
	
	return result; 
}

private list[str] sanitizeList(list[str] lines) {
	list[str] result = [];
	for(line <- lines) {
		result += replaceAll(line, "\t", "");	
	}
	
	return result;
}
