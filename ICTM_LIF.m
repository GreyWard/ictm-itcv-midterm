%------------------------------------------------------------------------
% This demo function implements the ICTM method applied into the LIF model.
% Author: Michael Harditya (Universitas Indonesia)
%
% Reference:
%   Dong Wang, Haohan Li, Xiaoyu Wei, and Xiao-Ping Wang*, 
%   An efficient iterative thresholding method for image segmentation, 
%   J. Comput. Phys., 350, 657-667, 2017.
%------------------------------------------------------------------------  
% image = image path
% iterNum = max iteration
% tau = variabel pada persamaan Gaussian untuk segment pertama
% sigma = variabel pada persamaan Gaussian untuk segment kedua
% mu = mu value untuk hasil integral gaussian
% lambda1 = 1st lambda value
% lambda2 = 2nd lambda value
% mode = 0: take 1st layer only, 1: convert to grayscale
% save = 1:save to mpeg; 0:unsave
%--------------------------------------------------------------------
function code = ICTM_LIF(image,iterNum, tau, mu, sigma, lambda1, lambda2, mode, save, indicator, name)
    I = imread(image);
    if mode == 0
        I = double(I(:,:,1));
    elseif mode == 1
        I = double(rgb2gray(I));
    end
    I = I(1:2:end,1:2:end);
    % Starting point initialization
    initialLSF = ones(size(I(:,:,1)))-0.01;
    initialLSF(60:100,60:100) = 0.01;
    u = initialLSF;
    % Save initialization
    if save
        filename = ['example-',num2str(indicator),name,'-LIF'];
        Ve = VideoWriter(filename,'MPEG-4');
        FrameRate = max(floor(iterNum/10),1);
        open(Ve);
        figure;imagesc(I, [0, 255]);colormap(gray);hold on;
        title('Initial contour');
        [c,h] = contour(u,[0.5 0.5],'b','LineWidth',2);
        axis off; axis equal
        hold off;
        currentFrame = getframe(gcf);
        writeVideo(Ve,currentFrame);
        pause(0.2)
    end
    
    % Start process
    K=fspecial('gaussian',round(2*sigma)*2+1,sigma);  
    K2 = fspecial('gaussian',round(2*tau)*2+1,tau); 
    KI=conv2(I,K,'same');                                           
    KONE=conv2(ones(size(I)),K,'same');  
    tic;
    for n=1:iterNum
        Ik=I.*u;
        c1=conv2(u,K,'same');
        c2=conv2(Ik,K,'same');
        f1=(c2)./(c1);
        f2=(KI-c2)./(KONE-c1);
        phi1 = lambda1*conv2(f1.^2,K,'same')-lambda1*2*I.*conv2(f1,K,'same')+mu*conv2(1-u,K2,'same');
        phi2 = lambda2*conv2(f2.^2,K,'same')-lambda2*2*I.*conv2(f2,K,'same')+mu*conv2(u,K2,'same');

        u_af = double(phi1-phi2<0)*0.98+0.01;
        change = sum(abs(u_af(:)-u(:)));
        u = u_af;

        if change==0
            break;
        end 

        if save
            imagesc(I, [0, 255]);colormap(gray);hold on;
            [c,h] = contour(phi1-phi2,[0 0],'r','LineWidth',2);
            iterNum=[num2str(n), ' iterations'];
            title(iterNum);hold off;
            axis off; axis equal
            hold off;
            currentFrame = getframe(gcf);
            writeVideo(Ve,currentFrame);
            pause(0.2)
        end   

    end
    toc;
    if save
        close(Ve)
    end
end