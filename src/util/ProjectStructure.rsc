module util::ProjectStructure

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import String;
import List;

import util::Sanitizer;

// map of path -> list of file and list of method asts (only for production code -> excluding junit, samples and generated code)
map[str,tuple[list[loc], list[Declaration]]] readProjectStructure(loc project) {
	// create M3 model from the project
	M3 model = createM3FromEclipseProject(project);

	// filter out any files that are not production code (such as junit, samples, generated code, etc.)
	list[loc] productionSourceFiles = [file | file <- files(model), isProductionSourceFile(file.path)];
	
	// map of path -> list of file and list of method asts
	map[str,tuple[list[loc], list[Declaration]]] packages = ();
	
	// group files and method asts into each package path 
	for(loc file <- productionSourceFiles) {
		list[Declaration] newMethodAsts = [ d | /Declaration d := createAstFromFile(file, true), d is method];		 
		str path = substring(file.path, 0, findLast(file.path, "/"));
		if(path in packages) {
			list[loc] files = (packages[path])[0] + file;
			list[Declaration] methodAsts = (packages[path])[1] + newMethodAsts;
			packages += (path: <files, methodAsts>);
		} else {
			packages += (path: <[file], newMethodAsts>);
		}		
	}
	
	return packages;
}

// list of packages and its files
map[str,list[loc]] getPackages(loc project) {
	// create M3 model from the project
	M3 model = createM3FromEclipseProject(project);

	// filter out any files that are not production code (such as junit, samples, generated code, etc.)
	list[loc] productionSourceFiles = [file | file <- files(model), isProductionSourceFile(file.path)];
	
	// map of path -> list of file and list of method asts
	map[str,list[loc]] packages = ();
	
	// group files and method asts into each package path 
	for(loc file <- productionSourceFiles) {
		str path = substring(file.path, 0, findLast(file.path, "/"));
		if(path in packages) {
			list[loc] files = packages[path] + file;
			packages += (path: files);
		} else {
			packages += (path: [file]);
		}		
	}
	
	return packages;
}
