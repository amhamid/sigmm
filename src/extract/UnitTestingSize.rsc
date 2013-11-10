module extract::UnitTestingSize

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import extract::UnitSize;

// calculate total unit testing size (assert statement)
list[tuple[int, int]] unitTestingSizePerUnit(M3 model) {
	list[Declaration] asts = [getMethodASTEclipse(method) | method <- methods(model)];
	list[tuple[int, int]] unitTestings = []; 
	 
	for(ast <- asts) {
		int result = 0;
		
		visit(ast) {
			case m:method(_,_,_,_,s) : visit(s) {
				case \assert(_) : result += 1;
				case \assert(_,_) : result += 1;			
			}
		}
		
		methodLoc = unitSize(model, ast@src);
		unitTestings += <result, methodLoc>;		
	}
	
	return unitTestings;
}
