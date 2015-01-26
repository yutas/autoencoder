%% CS294A/CS294W Programming Assignment Starter Code

%  Instructions
%  ------------
% 
%  This file contains code that helps you get started on the
%  programming assignment. You will need to complete the code in sampleIMAGES.m,
%  sparseAutoencoderCost.m and computeNumericalGradient.m. 
%  For the purpose of completing the assignment, you do not need to
%  change the code in this file. 
%
%%======================================================================
%% STEP 0: Here we provide the relevant parameters values that will
%  allow your sparse autoencoder to get good filters; you do not need to 
%  change the parameters below.

visibleSize = 8*8;   % number of input units 
hiddenSize = 25;     % number of hidden units 
sparsityParam = 0.01;   % desired average activation of the hidden units.
                     % (This was denoted by the Greek alphabet rho, which looks like a lower-case "p",
		     %  in the lecture notes). 
lambda = 0.0001;     % weight decay parameter       
beta = 3;            % weight of sparsity penalty term       

%%======================================================================
%% STEP 1: Implement sampleIMAGES
%
%  After implementing sampleIMAGES, the display_network command should
%  display a random sample of 200 patches from the dataset

all_patches = sampleIMAGES;
train_data = all_patches(:, 1:7000);
test_data = all_patches(:, 7001:10000);
display_network(train_data(:,randi(size(train_data,2),200,1)),8);

%  Obtain random parameters theta
theta = initializeParameters(hiddenSize, visibleSize);
use_checks = false;

%%======================================================================
%% STEP 2: Implement sparseAutoencoderCost
%
%  You can implement all of the components (squared error cost, weight decay term,
%  sparsity penalty) in the cost function at once, but it may be easier to do 
%  it step-by-step and run gradient checking (see STEP 3) after each step.  We 
%  suggest implementing the sparseAutoencoderCost function using the following steps:
%
%  (a) Implement forward propagation in your neural network, and implement the 
%      squared error term of the cost function.  Implement backpropagation to 
%      compute the derivatives.   Then (using lambda=beta=0), run Gradient Checking 
%      to verify that the calculations corresponding to the squared error cost 
%      term are correct.
%
%  (b) Add in the weight decay term (in both the cost function and the derivative
%      calculations), then re-run Gradient Checking to verify correctness. 
%
%  (c) Add in the sparsity penalty term, then re-run Gradient Checking to 
%      verify correctness.
%
%  Feel free to change the training settings when debugging your
%  code.  (For example, reducing the training set size or 
%  number of hidden units may make your code run faster; and setting beta 
%  and/or lambda to zero may be helpful for debugging.)  However, in your 
%  final submission of the visualized weights, please use parameters we 
%  gave in Step 0 above.

if (use_checks)
    testpatches = train_data(:, 10);

    [cost, grad] = sparseAutoencoderCost(theta, visibleSize, hiddenSize, lambda, ...
                                         sparsityParam, beta, testpatches);
end

%%======================================================================
%% STEP 3: Gradient Checking
%
% Hint: If you are debugging your code, performing gradient checking on smaller models 
% and smaller training sets (e.g., using only 10 training examples and 1-2 hidden 
% units) may speed things up.

if (use_checks)
    % First, lets make sure your numerical gradient computation is correct for a
    % simple function.  After you have implemented computeNumericalGradient.m,
    % run the following: 
    checkNumericalGradient();

    % Now we can use it to check your cost function and derivative calculations
    % for the sparse autoencoder.  
    numgrad = computeNumericalGradient( @(x) sparseAutoencoderCost(x, visibleSize, ...
                                                      hiddenSize, lambda, ...
                                                      sparsityParam, beta, ...
                                                      testpatches), theta);

    % Use this to visually compare the gradients side by side
    %disp([numgrad grad]); 

    % Compare numerically computed gradients with the ones obtained from backpropagation
    diff = norm(numgrad-grad)/norm(numgrad+grad);
    disp(diff); % Should be small. In our implementation, these values are
                % usually less than 1e-9.

                % When you got this working, Congratulations!!! 
    if (diff > 1e-4)
        fprintf('Derivatives differ too much! Stopping execution...\n')
        return
    end
end

%%======================================================================
%% STEP 4: After verifying that your implementation of
%  sparseAutoencoderCost is correct, You can start training your sparse
%  autoencoder with minFunc (L-BFGS).

%  Randomly initialize the parameters
theta = initializeParameters(hiddenSize, visibleSize);

%  Use minFunc to minimize the function
addpath minFunc/
options.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost
                          % function. Generally, for minFunc to work, you
                          % need a function pointer with two outputs: the
                          % function value and the gradient. In our problem,
                          % sparseAutoencoderCost.m satisfies this.
options.maxIter = 400;	  % Maximum number of iterations of L-BFGS to run 
options.display = 'off';

% lambdas = [0.0001; 3e-4; 1e-3; 3e-3; 1e-2; 3e-2; 1e-1; 3e-1; 1; 3; 10];
% betas = [0.01; 0.03; 0.1; 0.3; 1; 3; 10];
lambdas = 1e-2;
betas = 1;
points_number = size(lambdas,1)*size(betas,1);
% points_number = size(lambdas,1);
errors = zeros(points_number, 1);
points = zeros(points_number, 2);
ps = zeros(points_number, hiddenSize);

thetas = zeros(size(theta, 1), points_number);

point = 1;
for k=1:size(lambdas)
    lambda = lambdas(k);
    for b=1:size(betas)
        beta = betas(b);
        theta = initializeParameters(hiddenSize, visibleSize);
        opttheta = minFunc( @(x) sparseAutoencoderCost(x, ...
                                           visibleSize, hiddenSize, ...
                                           lambda, sparsityParam, ...
                                           beta, train_data), ...
                                      theta, options);

        W1 = reshape(opttheta(1:hiddenSize*visibleSize), hiddenSize, visibleSize);
        W2 = reshape(opttheta(hiddenSize*visibleSize+1:2*hiddenSize*visibleSize), visibleSize, hiddenSize);
        b1 = opttheta(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize);
        b2 = opttheta(2*hiddenSize*visibleSize+hiddenSize+1:end);


        % Counting error of model
        m = size(train_data, 2);
        [hx, ps(point, :)] = forwardPropagation(W1, W2, b1, b2, test_data);
        errors(point) = 1/(2*m)*sum(sum((hx - test_data).^2));
        points(point, 1) = lambda;
        points(point, 2) =  beta;
        thetas(:, point) = opttheta;
        fprintf('Test error with lambda = %d and beta = %d is equal to %d\n', lambda, beta, errors(k))
        point = point + 1;
    end
end

%%======================================================================
%% STEP 5: Visualization 
[min_error, idxe] = min(errors);
% plot(points(:,1),errors);
ps_sums = sum(ps,2);
% figure
% plot(points(:,2),ps_sums);
[min_p, point] = min(ps_sums);
best_lambda = points(point, 1);
best_beta = points(point, 2);
fprintf('Using model with best lambda = %d and beta = %d\n', best_lambda, best_beta);
model = thetas(:, point);

W1 = reshape(model(1:hiddenSize*visibleSize), hiddenSize, visibleSize);
W2 = reshape(model(hiddenSize*visibleSize+1:2*hiddenSize*visibleSize), visibleSize, hiddenSize);
b1 = model(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize);
b2 = model(2*hiddenSize*visibleSize+hiddenSize+1:end);

[h, p] = forwardPropagation(W1, W2, b1, b2, test_data);
W1 = reshape(model(1:hiddenSize*visibleSize), hiddenSize, visibleSize);
% figure
display_network(W1', 12); 

print -djpeg weights.jpg   % save the visualization to a file

