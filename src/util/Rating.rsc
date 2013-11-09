module util::Rating

str getTotalRating(list[str] ratings) =
	intToRating((0 | it + ratingToInt(rating) | rating <- ratings));

private str intToRating(int rating) {
	str result = "";
	if(rating >= 2) {
		result = "++";
	} else if(rating == 1) {
		result = "+";
	} else if(rating == 0) {
		result = "o";
	} else if(rating == -1) {
		result = "-";
	} else {
		result = "--";
	}
	
	return result;
}

private int ratingToInt(str rating) {
	int result = 0;
	switch(rating) {
		case "++" : result = 2;  
		case "+" : result = 1;   
		case "o" : result = 0;   
		case "-" : result = -1;  
		case "--" : result = -2; 
	}
	
	return result;
}
