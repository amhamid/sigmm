module metric::UnitTestingSize

import analysis::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

int unitTestingSize(set[Declaration] ast) {
	result = 0;
	visit(ast) {
		case m:method(_,_,_,_,s) : visit(s) {
			case \assert(_) : result += 1;
			case \assert(_,_) : result += 1;			
		}
	}
	
	return result;
}
		