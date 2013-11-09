module metric::UnitSize

import analysis::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

list[int] unitSize(M3 model) {
	return [(declr[1].end.line-declr[1].begin.line) - (doc[1].end.line-doc[1].begin.line) | declr <- model@declarations, doc <- model@documentation, isMethod(declr[0]) && declr[1].begin.line == doc[1].begin.line];
}

int unitSize(M3 model, loc methodSrc) {
	return (0 | it + (methodSrc.end.line-methodSrc.begin.line) - (doc[1].end.line-doc[1].begin.line) | doc <- model@documentation, methodSrc.begin.line == doc[1].begin.line);
}