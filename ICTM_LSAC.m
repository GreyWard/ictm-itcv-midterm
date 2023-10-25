%------------------------------------
% This demo function implements the ICTM method applied into the LSAC
% model. 
% Author: Michael Harditya (Universitas Indonesia)
%
% Reference:
%   Dong Wang, Haohan Li, Xiaoyu Wei, and Xiao-Ping Wang*, 
%   An efficient iterative thresholding method for image segmentation, 
%   J. Comput. Phys., 350, 657-667, 2017.
%
%   *Sub functions ``computed_b,_c,_s,_d'' can be refered to Lei Zhang's
%   software at http://www4.comp.polyu.edu.hk/~cskhzhang/.
%------------------------------------------------------------------------
% image = image path
% iterNum = max iteration
% r = untuk inisiasi titik awal
% sigma = untuk persamaan Gaussian
% tau = bagian dari kernel
% alpha = for the gamma value (alpha/sqrt(pi))
% save = 1 to save mpeg, 0 to not save it
% mode = 1 to convert RGB to gray, 0 to only use the first layer
%------------------------------------------------------------------------
function code = ICTM_LSAC(image,iterNum, r, sigma, tau, alpha,save,mode,indicator,name)
    I = imread(image); % for 3t MRI
    if mode == 0
        I = double(I(:,:,1));
    elseif mode == 1
        I = double(rgb2gray(I));
    end
    [nrow,ncol] = size(I);
    ic = nrow/2;
    jc = ncol/2;
    gamma = alpha;
    %--------------------------------------------------------------------------
    K = 1/(2*sigma+1)/(2*sigma+1)*ones(2*sigma+1);%The constant kernel with a small size
    KF = meshgrid(-nrow/2:1:nrow/2-1,-ncol/2:ncol/2-1)';
    KF = fftshift(exp(-KF.^2*tau)); % Fourier transform of Heat kernel
    %--------------------------------------------------------------------------


    dim = 2; % two phase model


    %Parameter initialization
    b(1:nrow,1:ncol) = 1;
    for i = 1:dim
        s(1:nrow,1:ncol,i) = i;
    end
    % Point initialization
    phi = sdf2circle(nrow,ncol, ic,jc,r); 
    
    % Save mpeg initialization
    Wanttosaveamovie = 1; % Decide to make a video
if save
    filename = ['example-',num2str(indicator),name,'-LSAC'];
    Ve = VideoWriter(filename,'MPEG-4');
    FrameRate = max(floor(iterNum/10),1);
    open(Ve);
    figure;imagesc(I, [0, 255]);colormap(gray);hold on; axis off;
    title('Initial contour');
    [c,h] = contour(phi,[0 0],'b','LineWidth',2);
    axis off; axis equal
    hold off;
    currentFrame = getframe(gcf);
    writeVideo(Ve,currentFrame);
    pause(0.2)
end

    phi0 = 0;
    u(:,:,1) = double(phi<0);
    u(:,:,2) = 1-u(:,:,1);
    phi(:,:) = u(:,:,1);
    Energy = zeros(1,1);

    tic;
    for i = 1:iterNum
        c = compute_c(I,K,u,b);
        b = compute_b(I,K,u,c,s);
        s = compute_s(I,b,K,c,u); 
        d = computer_d(I,K,s,b,c);
        phidiff2 = ifft2(KF.*fft2(phi));    
        phi = double((d(:,:,1)+sqrt(pi)*gamma/sqrt(tau)*(1-2*phidiff2))<d(:,:,2));
        change = sum((phi(:)-phi0(:)).^2);
        if change < 1
            break;
        end
        phi0 = phi;
        u(:,:,1) = phi;
        u(:,:,2) = 1-phi;
        if save
            imagesc(I,[0 255]);colormap(gray)
            hold on;
            contour(phi,[0.5 0.5],'r','LineWidth',2);
            iterNum=[num2str(i), ' iterations'];
            title(iterNum);hold off;
            axis off
            axis equal
            currentFrame = getframe(gcf);
            writeVideo(Ve,currentFrame);
            pause(0.2)
        end   
    end

    toc;

    if Wanttosaveamovie
        close(Ve)
    end
end