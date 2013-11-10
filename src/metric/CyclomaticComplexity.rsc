module metric::CyclomaticComplexity

import analysis::m3::Core;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import Number;

import metric::UnitSize;
import metric::Volume;

// calculate cyclomatic complexity rating
str cyclomaticComplexityRating(M3 model) {
	result = "";

	int totalLoc = countTotalLoc(model);
	list[tuple[int,int]] complexityUnits = cyclomaticComplexityPerUnit(model);
	
	// filtering the risk into moderate, high and very high risk
	list[tuple[int,int]] moderateRisk = [<x, y> | <x,y> <- complexityUnits, x > 10, x <= 20];
	list[tuple[int,int]] highRisk = [<x, y> | <x,y> <- complexityUnits, x > 20, x <= 50];
	list[tuple[int,int]] veryHighRisk = [<x, y> | <x,y> <- complexityUnits, x > 50];
	
	// calculating total line of code per risk
	int moderateRiskTotalLoc = (0 | it + y | <x,y> <- moderateRisk); 
	int highRiskTotalLoc = (0 | it + y | <x,y> <- highRisk);
	int veryHighRiskTotalLoc = (0 | it + y | <x,y> <- veryHighRisk);

	// calculating percentage of the risks
	real moderateRiskPercentage = toReal(moderateRiskTotalLoc)/totalLoc * 100;
	real highRiskPercentage = toReal(highRiskTotalLoc)/totalLoc * 100;
	real veryHighRiskPercentage = toReal(veryHighRiskTotalLoc)/totalLoc * 100;
	
	return getRating(moderateRiskPercentage, highRiskPercentage, veryHighRiskPercentage);
}

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
	
	return [<x, y> | <x,y> <- complexityUnits];;
}

str getRating(real moderateRiskPercentage, real highRiskPercentage, real veryHighRiskPercentage) {
	str result = "";
		
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
