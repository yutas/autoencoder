function [ y, p, z2, a2, z3 ] = forwardPropagation( W1, W2, b1, b2, x )
    m = size(x,2);
    z2 = W1*x + repmat(b1,1,m);
    a2 = sigmoid(z2);
    p = sum(a2, 2)/m;   % average activation of hidden units
    z3 = W2 * a2 + repmat(b2,1,m);
    y = sigmoid(z3);
end


function sigm = sigmoid(x)
    sigm = 1 ./ (1 + exp(-x));
end