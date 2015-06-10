%% Calculate pdf of a random variable generated by the weighted sum of 
%% N noncentral chi square with 2 degrees of freedom and a Guassian r.v.
% Input:
% pX(x)
% D (Nx1) = weights of noncentral chi square with 2 degrees of freedom.
% xn (N x Nsymb) = used to calculate the noncetrality parameter of individual chi squares
% distributions. Each column of xn corresponds to a symbol, and each row 
% corresponds to a chi square distribution. xn = mu1 + 1jmu2, where mu1 and
% mu2 are the means of the original gaussian r.v.s.
% varASE (1x1) = 
% varTher = variance of Gaussian r.v. 

% Output
% px = pdf of the output decision variable at x for all transmitted symbols

function px = pdf_saddlepoint_approx(x, D, xn, varASE, varTher, verbose)
    if nargin == 6 && verbose
        figure(100), hold on
    end
    Nsymb = size(xn, 2);
    px = zeros(length(x), Nsymb);
    for k = 1:Nsymb
        for kk = 1:length(x)
            [shat, ~, exitflag] = fzero(@(s) d1expoent(s, x(kk), D, xn(:, k), varASE, varTher), 1e-3);

            if exitflag ~= 1
                warning('(%d, %g) resulted in exitflag = %d\n', k, x(kk), exitflag);
            end

            Ksx = expoent(shat, x(kk), D, xn(:, k), varASE, varTher);
            d2Ksx = d2expoent(shat, D, xn(:, k), varASE, varTher);
            
%             if d2Ksx < 0
%                 warning('(%d, %g) resulted in kp2 < 0\n', k, x(kk));
%                 d2Ksx
%             end

            px(kk, k) = real(exp(Ksx)/sqrt(2*pi*d2Ksx)); 

        end
    
        if nargin == 6 && verbose           
            plot(x, px(:, k))
        end
        
        px(:, k) =  px(:, k)/trapz(x,  px(:, k));
    end
end

% Expoent, and its first and second derivatives. 
% In this case K(s, x) = log(M(s)) - sx.
function Ksx = expoent(s, x, D, xnt, varASE, varTher) 
    Ksx = sum(-log(1-D*varASE*s) + (D.*abs(xnt).^2*s)./(1-D*varASE*s)) + 0.5*varTher*s^2 - s*x;
end

% First derivative    
function d1Ksx = d1expoent(s, x, D, xnt, varASE, varTher) 
    d1Ksx = sum(D.*(abs(xnt).^2 + varASE - varASE^2*s)./((1-D*varASE*s).^2)) + varTher*s - x;
end

% Second derivative
function d2Ksx = d2expoent(s, D, xnt, varASE, varTher) 
    d2Ksx = sum((D*varASE).^2./(1 - D*varASE*s).^2 + (2*varASE*(D.^2).*abs(xnt).^2)./((1 - D*varASE*s).^3)) + varTher;
end
    