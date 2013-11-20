module util::Sanitizer

import String;

// sanitize lines 
list[str] sanitizeLines(list[str] lines, list[str] chars) {
	list[str] result = [];
	str tmp;
	for(line <- lines) {
		tmp = line;
		for(char <- chars) {
			tmp = trim(replaceAll(tmp, char, ""));
		}
		
		result += tmp;			
	}
	
	return result;
}

bool isComment(str line) {
	str trimmedLine = trim(line);
	return startsWith(trimmedLine, "//") 
			|| startsWith(trimmedLine, "/*") 
			|| startsWith(trimmedLine, "*") 
			|| startsWith(trimmedLine, "*/");
}

bool isProductionSourceFile(str path) {
	return startsWith(path, "/src/")
			&& !contains(path, "/generated/")
			&& !contains(path, "/sample/")
			&& !contains(path, "/samples/")
			&& !contains(path, "/test/") 
			&& !contains(path, "/tests/") 
			&& !contains(path, "/junit/")
			&& !contains(path, "/junits/");
}
