module metric::CyclomaticComplexity

import analysis::m3::Core;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

import metric::UnitSize;
import metric::Volume;

str cyclomaticComplexityRating(M3 model) {
	result = "";

	list[tuple[int,int]] complexityUnits = cyclomaticComplexity(model);
	list[tuple[int,int]] moderateRisk = [<x, y> | <x,y> <- complexityUnits, x > 10, x <= 20];
	list[tuple[int,int]] highRisk = [<x, y> | <x,y> <- complexityUnits, x > 20, x <= 50];
	list[tuple[int,int]] veryHighRisk = [<x, y> | <x,y> <- complexityUnits, x > 50];
	
	int moderateRiskLoc = (0 | it + y | <x,y> <- moderateRisk); 
	int highRiskLoc = (0 | it + y | <x,y> <- highRisk);
	int veryHighRiskLoc = (0 | it + y | <x,y> <- veryHighRisk);
	
	int vol = volume(model);

	// methodRiskLoc = <moderateRiskLoc, highRiskLoc, veryHighRiskLoc>	
	int moderateRiskPercentage = moderateRiskLoc/vol * 100;
	int highRiskPercentage = highRiskLoc/vol * 100;
	int veryHighRiskPercentage = veryHighRiskLoc/vol * 100;
	
	return getRating(<moderateRiskPercentage, highRiskPercentage, veryHighRiskPercentage>);
}

// list complexity, nr of line
list[tuple[int, int]] cyclomaticComplexity(M3 model) {
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
	
	return [<x, y> | <x,y> <- complexityUnits, x > 10];;
}

private str getRating(tuple[int,int,int] methodRiskPercentage) {
	str result = "";
		
	// methodRiskPercentage = <moderateRiskPercentage, highRiskPercentage, veryHighRiskPercentage>	
	int moderateRiskPercentage = methodRiskPercentage[0];
	int highRiskPercentage = methodRiskPercentage[1];
	int veryHighRiskPercentage = methodRiskPercentage[2];
		
	if(moderateRiskPercentage <= 25 && highRiskPercentage == 0 && veryHighRiskPercentage == 0) {
		result = "++";
	} else if(moderateRiskPercentage <= 30 && highRiskPercentage <= 5 && veryHighRiskPercentage == 0) {
		result = "+";
	} else if(moderateRiskPercentage <= 40 && highRiskPercentage <= 10 && veryHighRiskPercentage == 0) {
		result = "o";
	} else if(moderateRiskPercentage <= 50 && highRiskPercentage <= 15 && veryHighRiskPercentage <= 5) {
		result = "-";
	} else {
		result = "--";
	}
	
	return result;
}
