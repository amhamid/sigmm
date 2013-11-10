module extract::CyclomaticComplexity

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Number;

import extract::UnitSize;
import extract::Volume;

// calculate complexity per method and return a list of tuple with information <complexity, number of loc>
list[tuple[int, int]] cyclomaticComplexityPerUnit(M3 model) {
	list[Declaration] asts = [getMethodASTEclipse(method) | method <- methods(model)];
	list[tuple[int, int]] complexityUnits = []; 
	 
	for(ast <- asts) {
		int result = 1;
		
		visit(ast) {
			case m:method(_,_,_,_,s) : visit(s) {
			  	case do(_,_) : result += 1;
		  		case foreach(_,_,_) : result += 1;
		  		case \for(_,_,_,_) : result += 1;
		  		case \for(_,_,_) : result += 1;
				case \if(_,_) : result += 1;
				case \if(_,_,_) : result += 1;
				case \case(_) : result += 1;	
				case defaultCase() : result += 1;
				case \while(_,_) : result += 1;
				case \catch(_,_) : result += 1;			
			}
		}
		
		methodLoc = unitSize(model, ast@src);
		complexityUnits += <result, methodLoc>;		
	}
	
	return complexityUnits;
}
