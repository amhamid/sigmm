module extract::CyclomaticComplexity

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import extract::UnitSize;

// calculate complexity per method and return a list of tuple with information <complexity, number of loc>
list[tuple[int, int]] cyclomaticComplexityPerUnit(list[Declaration] methodAsts) {
	list[tuple[int, int]] complexityUnits = []; 
	 
	for(ast <- methodAsts) {
		int result = 1;
		
		visit(ast) {
	  		case foreach(_,_,_) : result += 1;
	  		case \for(_,_,_,_) : result += 1;
	  		case \for(_,_,_) : result += 1;
			case \if(_,_) : result += 1;
			case \if(_,_,_) : result += 1;
			case \case(_) : result += 1;	
			case \while(_,_) : result += 1;
			case \catch(_,_) : result += 1;			
		}
		
		if(result > 1 && (/method(m,_,_,_) := ast@typ)) {
			methodLoc = unitSize(m);
			complexityUnits += <result, methodLoc>;
		}				
	}
	
	return complexityUnits;
}
