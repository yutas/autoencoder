function numgrad = computeNumericalGradient(J, theta)
    % numgrad = computeNumericalGradient(J, theta)
    % theta: a vector of parameters
    % J: a function that outputs a real-number. Calling y = J(theta) will return the
    % function value at theta. 

    % Initialize numgrad with zeros
    numgrad = zeros(size(theta));

    %% ---------- YOUR CODE HERE --------------------------------------
    % Instructions: 
    % Implement numerical gradient checking, and return the result in numgrad.  
    % (See Section 2.3 of the lecture notes.)
    % You should write code so that numgrad(i) is (the numerical approximation to) the 
    % partial derivative of J with respect to the i-th input argument, evaluated at theta.  
    % I.e., numgrad(i) should be the (approximately) the partial derivative of J with 
    % respect to theta(i).
    %                
    % Hint: You will probably want to compute the elements of numgrad one at a time. 

    eps = 1e-4;

    perturb = zeros(size(theta));
    for p = 1:numel(theta)
        % Set perturbation vector
        perturb(p) = eps;
        numgrad(p) = (J(theta + perturb) - J(theta - perturb)) / (2*eps);
        perturb(p) = 0;
        if (mod(p,1000) == 0)
            fprintf('Processed %d\n', p);
        end
    end
    %% ---------------------------------------------------------------
end
