%------------------------------------------------------------------------
% This demo function implements the ICTM method applied into the Chan-Vese model.
% Author: Michael Harditya (Universitas Indonesia)
%
% Reference:
%   Dong Wang, Haohan Li, Xiaoyu Wei, and Xiao-Ping Wang*, 
%   An efficient iterative thresholding method for image segmentation, 
%   J. Comput. Phys., 350, 657-667, 2017.
%------------------------------------------------------------------------  
% image = image path
% iterNum = max iteration
% dt = time step
% alpha = parameter of lambda init, alpha *sgrt(pi)/sqrt(dt)
% segments = total number of segments, 2 or 4
% channels = total number of channels, 1 (greyscale) or 3 (RGB)
% save = 1:save to mpeg; 0:unsave
%--------------------------------------------------------------------
function code = ICTM_CV(image, iterNum, dt, alpha, segments, channels, save,indicator,name)
    I = imread(image);
    M = size(I,1);
    N = size(I,2);
    if channels == 1
        P = rgb2gray(uint8(I));
        P = double(P);
        P = P./max(max(abs(P)));
    elseif channels == 3
        P = double(I);
        for i = 1:3
            P(:,:,i) = P(:,:,i)./max(max(abs(P(:,:,i))));
        end
        f1 = P(:,:,1); % first color channel
        f2 = P(:,:,2); % second
        f3 = P(:,:,3); % third
    end
    lamda = alpha * sqrt(pi)/sqrt(dt);
    % Segment starting point initialization
    if segments == 2
        u1 = zeros(M,N);
        u1(50:M-50,50:N-50) = ones(M-100+1,N-100+1);
        u2 = ones(M,N)-u1;
    elseif segments == 4
        u1 = zeros(M,N);
        u1(50:125,40:90) = 1;
        u2 = zeros(M,N);
        u2(175:200,50:200) = 1;
        u3 = zeros(M,N);
        u3(50:75,150:200) = 1;
        u4 = 1 - u1 - u2 - u3;
    end
    
 % Save initialization
    if save
        filename = ['example-',num2str(indicator),name,'-CV'];
        Ve = VideoWriter(filename,'MPEG-4');
        FrameRate = max(floor(iterNum/10),1);
        open(Ve);
        imagesc(P, [0, 1]);hold on;
        title('Initial contour');
        if segments==2
        contour(u1,[0.5 0.5],'b','LineWidth',2);
        elseif segments == 3
            contour(u2,[0.5 0.5],'b','LineWidth',2);
        elseif segments == 4
            contour(u2,[0.5 0.5],'b','LineWidth',2);
            contour(u3,[0.5 0.5],'b','LineWidth',2);
        else
            disp('edit the plotting part to validate to your cases')
        end
        axis off; axis equal
        hold off;
        currentFrame = getframe(gcf);
        writeVideo(Ve,currentFrame);
        pause(0.2)
    end
    %--------------------------------------------------------------------------
    change = 1;
    tic;
    % Start process iteration
    for n=1:iterNum
        % for 2 segments gray image
        if segments == 2 && channels ==1
            [f1,f2] = daterm(P,u1,u2);
            [uh1,uh2] = HeatConv(dt,u1,u2);
            index1 = f1+lamda*uh2;
            index2 = f2+lamda*uh1;
            u1_af = double(index1<=index2);
            u2_af = 1-u1_af;
            change = sum(abs(u1_af(:)-u1(:)));
            u1 = u1_af;
            u2 = u2_af;
            if save
                imagesc(P, [0, 1]);colormap(gray);hold on;
                contour(u1,[0.5 0.5],'b','LineWidth',2);
                iterNum=[num2str(n), ' iterations'];
                title(iterNum);hold off;
                axis off
                axis equal
                currentFrame = getframe(gcf);
                writeVideo(Ve,currentFrame);
                pause(0.2)
            end
       
        % for 2 segments RGB
        elseif segments == 2 && channels == 3
            [f11,f21] = daterm(f1,u1,u2); % data term of first color channel
            [f12,f22] = daterm(f2,u1,u2); % data term of second color channel
            [f13,f23] = daterm(f3,u1,u2); % data term of third color channel
            [uh1,uh2] = HeatConv(dt,u1,u2); % heat kernel convolution
            index1 = f11+f12+f13-lamda*uh1;
            index2 = f21+f22+f23-lamda*uh2;
            u1_af = double(index1<=index2); % thresholding if u1>u2 then u1=1 vise versa
            u2_af = 1-u1_af; 
            change = sum(abs(u1_af(:)-u1(:)));
            u1 = u1_af;
            u2 = u2_af;
            if save
                imagesc(P, [0, 1]);hold on;
                contour(u1,[0.5 0.5],'k','LineWidth',2);
                iterNum=[num2str(n), ' iterations'];
                title(iterNum);hold off;
                axis off
                axis equal
                currentFrame = getframe(gcf);
                writeVideo(Ve,currentFrame);
                pause(0.2)
            end
        % 4 segments RGB
        elseif segments == 4 && channels ==3
            %------------------------------------------------------------------
            % 4 segments for color images
            [f11,f21,f31,f41] = daterm(f1,u1,u2,u3,u4); % data term of first color channel
            [f12,f22,f32,f42] = daterm(f2,u1,u2,u3,u4); % data term of second color channel
            [f13,f23,f33,f43] = daterm(f3,u1,u2,u3,u4); % data term of third color channel
            [uh1,uh2,uh3,uh4] = HeatConv(dt,u1,u2,u3,u4); % heat kernel convolution
            index1 = f11+f12+f13-lamda*uh1;
            index2 = f21+f22+f23-lamda*uh2;
            index3 = f31+f32+f33-lamda*uh3;
            index4 = f41+f42+f43-lamda*uh4;

            % -- thresholding: if ui is the largest value then ui=1 and
            % uj=0 for j!=i
            u1_af = double(index1<=index2).*double(index1<=index3).*double(index1<=index4);
            u2_af = double(index2<index1).*double(index2<=index3).*double(index2<=index4).*double(u1==0);
            u3_af = double(index3<index1).*double(index3<index2).*double(index3<=index4).*double(u2==0).*double(u1==0);
            u4_af = 1-u1_af-u2_af-u3_af;
            change = norm(u1-u1_af) + norm(u2-u2_af) + norm(u3-u3_af);
            u1 = u1_af;
            u2 = u2_af;
            u3 = u3_af;
            u4 = u4_af;

            if save
                imagesc(P, [0, 1]);hold on;
                contour(u1,[0.5 0.5],'k','LineWidth',2);
                contour(u2,[0.5 0.5],'k','LineWidth',2);
                contour(u3,[0.5 0.5],'k','LineWidth',2);
                iterNum=[num2str(n), ' iterations'];
                title(iterNum);hold off;
                axis off
                axis equal
                currentFrame = getframe(gcf);
                writeVideo(Ve,currentFrame);
                pause(0.2)
            end
        end
        if change==0
            break;
        end 
    end
    toc;
    if save
        close(Ve)
    end
end
