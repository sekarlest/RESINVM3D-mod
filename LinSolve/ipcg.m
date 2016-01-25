function [x,numiter,res] = ipcg(MTX, regpar, b, tol, intol, max_it)
% [x,numiter] = ipcg(MTX, REGPAR, b, tol, k)
% 
% Preconditioned CG for the system
%  (J'*J + regpar*L)x = r
% where J*v is computed indirectly J*v = -Q*(A^{-1}*(G*v))
%
% Copyright (c) 2007 by the Society of Exploration Geophysicists.
% For more information, go to http://software.seg.org/2007/0001 .
% You must read and accept usage terms at:
% http://software.seg.org/disclaimer.txt before use.
% 
% Revision history:
% Original SEG version by Adam Pidlisecky and Eldad Haber
% Last update, July 2006
   
  disp('            PCG -----');
  
  %initialize starting variables
  r = b;
  n = length(b);
  x = zeros(n,1);
  rho = r'*r;
  
  if  ( rho == 0.0 ), rho = 1.0; end

  err = norm( r ) / sqrt(rho);
  if ( err < tol ) disp('err < tol'); return, end

  for iter = 1:max_it                       % begin iteration

     % preconditioning step %%%%%%
 
  
     z = matsol(0.1*speye(n) + regpar*MTX.WTW, r, 1e-6);  
     
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     rho_1 = rho;
     rho = (r'*z);
     if iter == 1, rho0 = norm(z); end;

     if ( iter > 1 ),                       % compute the direction vector
        beta = rho / rho_1;
        p = z + beta*p;
     else
        p = z;
     end
     %%%%%%  Matrix times a vector %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % q = (J'*J) + regpar*W'*W)*p
     
     % regpar*W'*W*p
     q0 = regpar*MTX.WTW*p;
        
     % Calculate (J'*J) in 4 steps
     gp = calcGv(mkvc(MTX.mc), MTX.U , MTX, p);

     q1 = -(Qu(MTX.OBS, Asol(MTX, gp, intol),MTX.SRCNUM));
     
     q2 = -ATsol(MTX, Qtu(MTX.OBS, q1, MTX.SRCNUM), intol); 
  
     q3 = calcGvT(mkvc(MTX.mc), MTX.U , MTX ,q2);

     % Sum the result to get q = (J'*J) + regpar*W'*W)*p
     q = q0 + q3;
 
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

     alpha = rho / (p'*q );
     x = x + alpha * p;                    % update approximation vector

     r = r - alpha*q;                      % compute residual
     err = norm( r ) / rho0;               % check convergence
     numiter = iter;
     fprintf('        PCG iteration %d, Relative residual = %e\n',iter, err);
     if ( err <= tol )
        break, 
     end 
     res(iter) = err;
     
  end 
  disp('            Done pcg -----');
% END ipcg.m

