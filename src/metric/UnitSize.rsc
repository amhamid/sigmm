module metric::UnitSize

import analysis::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

list[int] unitSize(M3 model) {
	return [(m[1].end.line-m[1].begin.line) - (n[1].end.line-n[1].begin.line) | m <- model@declarations, n <- model@documentation, isMethod(m[0]) && m[1].begin.line == n[1].begin.line];
}
