% This function implements SNEDDON results (SNEDDON 1946) concerning the
% indentation of a flat circular punch on a elastic half-space.  Multiple
% (small) punchs (i.e. point loads) can be used and stress sum up by 
% superposition.  Some errors could be found in (SNEDDON 1946) and were 
% corrected in (Fischer-Cripps 2007, Chapter 5).
%
% % Inputs : P indentation force applied on the punch
%          Ploc, 2D coordinates of the location of each punch (npins,2)
%          ReceptorLoc, 2D coordinates of receptors location in mm (nrec,2)
%          ReceptorDepth, depth of the receptor in mm (nrec)
%          StrainComp, strain component (scalar):
%             1. eps_z              9. sigma_z
%             2. eps_h             10. sigma_h
%             3. eps_c             11. sigma_c
%             4. eps_t             12. sigma_t
%             5. eps_m             13. sigma_m
%             6. StrainTrace       14. StressTrace
%             7. StrainDet         15. StressDet
%             8. AreaChange        16. SED
%                                  17. Volume Change
%                                  18. Maximum shearing abs((e1-e3)/2)

function [strain,names]=CircLoadVertStress(P,PLoc,PRad,AffLoc,AffDepth)

[~,npin] = size(P); %(nsamp,npin)
%nrec=size(AffLoc,1);

%nu = 0.4;
v=ver('matlab');
if(str2double(v.Version)>9)
    x = AffLoc(:,1)'-PLoc(:,1);    % (npin,nrec)
    y = AffLoc(:,2)'-PLoc(:,2);    % (npin,nrec)
    z = ones(npin,1).*AffDepth(:)'; % (npin,nrec)
else
    x = bsxfun(@minus,AffLoc(:,1)',PLoc(:,1));    % (npin,nrec)
    y = bsxfun(@minus,AffLoc(:,2)',PLoc(:,2));    % (npin,nrec)
    z = bsxfun(@times,ones(npin,1),AffDepth(:)'); % (npin,nrec)
end

%tt = atan2(y,x); % (npin,nrec)
%s = sin(tt);     % (npin,nrec)
%c = cos(tt);     % (npin,nrec)

r = hypot(x,y);

% Pressure stress matrix (r,t,z)  (SNEDDON 1946)
XSI = z/PRad;
RHO = r/PRad;

rr=sqrt(1+XSI.^2);
R=sqrt((RHO.^2 + XSI.^2 -1).^2+4*XSI.^2);
theta=atan(1./XSI);
phi=atan2(2*XSI,(RHO.^2 + XSI.^2 -1));

J01 = sin(phi/2)./sqrt(R);
J02 = rr.*sin(3/2*phi-theta)./R.^(3/2);
%J10sRHO = (1-sqrt(R).*sin(phi/2))./RHO./RHO;
%J11sRHO = rr.*sin(theta-phi/2)./RHO./RHO./sqrt(R);
%J12 = RHO .* sin(3/2*phi)./R.^(3/2);

%rho0idx=abs(RHO)<1e-12;
%J10sRHO(rho0idx) = .5./(1+XSI(rho0idx).^2);
%J11sRHO(rho0idx)=XSI(rho0idx)./(1+XSI(rho0idx).^2).^2;


%s_rz =  (XSI.*J12);
%s_t  =  ((2*nu)* J01 - XSI.*J11sRHO + (1-2*nu).*J10sRHO);
%s_r  =  (J01 - XSI.*(J02 - J11sRHO) - (1-2*nu)*J10sRHO);

% Pressure rotated stress matrix (x,y,z)
eps=P/2/PRad/PRad/pi;

%s_x    = eps*(s_r.*c.^2 + s_t.*s.^2);
%s_y    = eps*(s_r.*s.^2 + s_t.*c.^2);
s_z    = eps*(J01+XSI.*J02);
%s_xy   = eps*((s_r-s_t).*s.*c);
%s_xz   = eps*(s_rz.*c);
%s_yz   = eps*(s_rz.*s);

% sigma=zeros(nsamp,nrec,6);
% sigma(:,:,1)    = s_x;  % (nsamp,nrec,6)
% sigma(:,:,2)    = eps*s_y;
% sigma(:,:,3)    = eps*s_z;
% sigma(:,:,4)    = eps*s_xy;
% sigma(:,:,5)    = eps*s_xz;
% sigma(:,:,6)    = eps*s_yz;

%[strain,names]=stressmat2singlecomp(sigma,StrainComp);
strain=s_z;
