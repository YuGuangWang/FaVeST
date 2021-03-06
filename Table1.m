%% Program for Table 1

clear,clc
close all
p1 = pwd;
addpath(genpath(p1))

subdir = '/'; % for OSX
% subdir = '\'; % fof Windows
%% Generate an artificial vector filed by vector spherical harmonics with random coefficients
% QH = 'GL';
QH = 'SD';
fprintf('******* FaVeST for Simulated Fields *******\n');
fprintf('Quadrature rule for evaluation: %s\n',QH);
Lv = [10 30 50 100 120 150];
relaerr = zeros(3,numel(Lv));
for ivf = 1:3
    switch ivf
        case 1
            vf = @flow1;
            vf_txt = 'Tangent Field A';
        case 2
            vf = @flow2;
            vf_txt = 'Tangent Field B';
        case 3
            vf = @flow3;
            vf_txt = 'Tangent Field C';
    end
fprintf('****** Compute relative errors for %s ******\n',vf_txt);
for i =1:length(Lv)
    L = Lv(i);
    [w_gl,x_gl,X_gl] = QpS2(L,QH);
    [lam,th,r] = cart2sph(X_gl(1,:)',X_gl(2,:)',X_gl(3,:)');
    Y_tar = vf(X_gl);
    %% Running FaVeST_fwd and FaVeST_adj
    % Fast evaluate Fourier coefficients for divergent-free and curl-free parts
    [F1,F2] = FaVeST_fwd(Y_tar',L,x_gl,w_gl);
    % Fast compute Fourier summation with the given Fourier coefficients
    Y_rec = FaVeST_adj(F1,F2,x_gl);
    Y_rec = real(Y_rec);
    % Calculate the approximation error
    err_pntwise = Y_rec-Y_tar;
    err_abs = norm(err_pntwise);
    relaerr(ivf,i) = err_abs/norm(Y_tar);
    fprintf('* L: %d,  Absolute Error: %.4e,  Relative Errors: %.4e\n',L,err_abs,relaerr(ivf,i));
end
end
% save data
sv_dir = ['data' subdir];
if ~exist(sv_dir,'dir')
    mkdir(sv_dir);
end
sv = [sv_dir 'table1_' QH '.mat'];
save(sv,'relaerr','Lv')
