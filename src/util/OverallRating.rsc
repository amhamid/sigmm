module util::OverallRating

import List;

// calculate total rating, e.g. ("++", "--", "+") --> "o"
str getTotalRating(list[str] ratings) {
	int totalRating = (0 | it + ratingToInt(rating) | rating <- ratings);
	return intToRating(totalRating / size(ratings));
}

private str intToRating(int rating) {
	str result = "";
	if(rating == 5) {
		result = "++";
	} else if(rating == 4) {
		result = "+";
	} else if(rating == 3) {
		result = "o";
	} else if(rating == 2) {
		result = "-";
	} else if(rating == 1) {
		result = "--";
	}
	
	return result;
}

private int ratingToInt(str rating) {
	int result = 1;
	switch(rating) {
		case "++" : result = 5;  
		case "+" : result = 4;   
		case "o" : result = 3;   
		case "-" : result = 2;  
		case "--" : result = 1; 
	}
	
	return result;
}
