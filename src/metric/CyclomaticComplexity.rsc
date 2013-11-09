module metric::CyclomaticComplexity

import analysis::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

int cyclomaticComplexity(set[Declaration] ast) {
	result = 1;
	
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
	
	return result;
}
