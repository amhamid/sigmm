module metric::UnitSize

import analysis::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

str unitSizeRating(M3 model) {
	// TODO 
	return "o";
}

// calculate method size excluding comments
list[int] unitSize(M3 model) =
	[unitSize(declr[1], doc[1]) | declr <- model@declarations, doc <- model@documentation, isMethod(declr[0]) && declr[1].begin.line == doc[1].begin.line];

// calculate method size excluding comments
int unitSize(M3 model, loc methodSrc) =
	(0 | it + unitSize(methodSrc, doc[1]) | doc <- model@documentation, methodSrc.begin.line == doc[1].begin.line);

private int unitSize(loc methodSrc, loc methodDoc) =
	(methodSrc.end.line-methodSrc.begin.line) - (methodDoc.end.line-methodDoc.begin.line);
