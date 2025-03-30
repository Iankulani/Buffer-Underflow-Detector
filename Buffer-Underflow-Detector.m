function bufferUnderflowAnalysis()
    % Prompt the user to input the C/C++ file path
    [fileName, filePath] = uigetfile({'*.c;*.cpp', 'C/C++ Files (*.c, *.cpp)'}, 'Select a C/C++ file');
    
    if isequal(fileName, 0)
        disp('No file selected. Exiting.');
        return;
    end
    
    % Read the content of the selected C/C++ file
    fullPath = fullfile(filePath, fileName);
    try
        fileContent = fileread(fullPath);
    catch
        disp('Error reading the file. Please ensure the file exists and is readable.');
        return;
    end
    
    % Process the file content for potential buffer underflow vulnerabilities
    checkForUnderflows(fileContent, fileName);
end

function checkForUnderflows(fileContent, fileName)
    % Regular expressions to identify potential underflow issues in the code
    % Checking for common signs like accessing before initialization
    pattern = '([a-zA-Z_][a-zA-Z0-9_]*)\s*\[\s*(\d+)\s*\]\s*=\s*.*';  % Detect array assignment
    
    % Apply the regular expression to find array usages
    arrayAssignments = regexp(fileContent, pattern, 'tokens');
    
    if isempty(arrayAssignments)
        disp('No potential buffer issues detected based on array assignments.');
        return;
    end
    
    % Process the array assignment occurrences
    fprintf('\nPotential buffer underflow issues found in file: %s\n', fileName);
    disp('-------------------------------------------------------');
    
    % For each detected array access, print information about the possible issue
    for i = 1:length(arrayAssignments)
        assignment = arrayAssignments{i};
        arrayName = assignment{1};
        index = str2double(assignment{2});
        
        % Check for potential issues with index access before initialization
        if index < 0
            fprintf('Potential buffer underflow detected: %s[%d] is out of bounds (index < 0).\n', arrayName, index);
        elseif index == 0
            fprintf('Potential buffer underflow detected: %s[0] might be uninitialized (zero index).\n', arrayName);
        end
    end
    
    % Additional heuristics could be added here for more in-depth analysis.
end
