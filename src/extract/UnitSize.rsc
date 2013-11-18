module extract::UnitSize

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import String;
import List;

import util::Sanitizer;

// calculate total unit size
int totalUnitSize(list[Declaration] methodAsts) =
	(0 | it + unitSize | unitSize <- unitSizePerUnit(methodAsts));

// calculate unit size per unit
list[int] unitSizePerUnit(list[Declaration] methodAsts) {
	list[int] totalMethodLines = [];
	
	for(ast <- methodAsts) {
		if(/method(m,_,_,_) := ast@typ) {
			totalMethodLines += unitSize(m);
		}
	}
	
	return totalMethodLines;
}

// calculate a unit size
int unitSize(loc methodLoc)	{
	list[str] rawLines = sanitizeLines(readFileLines(methodLoc), ["\t"]);
	list[str] methodLines = [line | line <- rawLines, !isEmpty(line), !isComment(line)];
	return size(methodLines);
}
