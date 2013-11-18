module extract::UnitTestingSize

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import extract::UnitSize;

// calculate total unit testing size (assert statement)
int totalUnitTestingSize(list[Declaration] methodAsts) {
	int totalUnitTesting = 0; 
	 
	for(ast <- methodAsts) {
		int numberOfAssert = 0;
		
		visit(ast) {
			case \assert(_) : numberOfAssert += 1;
			case \assert(_,_) : numberOfAssert += 1;
		}
		
		if(numberOfAssert > 0 && (/method(m,_,_,_) := ast@typ)) {
			methodLoc = unitSize(m);
			totalUnitTesting += methodLoc;
		}
	}
	
	return totalUnitTesting;
}
