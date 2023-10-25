flag = 0
for i = 1:4
    data = ['cardboard',num2str(i),'.jpg'];
    ICTM_CV(data,300,0.03,0.03,2,3,1,i,'cardboardRGB');
    ICTM_CV(data,300,0.03,0.03,2,1,1,i,'cardboard');
    % Best param ini, untuk objek ambil ketengah misalkan 60:100
    ICTM_LIF(data,300,5,500,20,1.0,1.0,1,1,i,'cardboardGray-Object')
    % ICTM_LSAC(image,iterNum, r, sigma, tau, alpha,save,mode,indicator,name)
    ICTM_LSAC(data,300,20,5,0.03,(0.26/sqrt(pi)),1,1,i,'cardboardGrayscale')
    data = ['metal',num2str(i),'.jpg'];
    ICTM_CV(data,300,0.03,0.03,2,3,1,i,'metalRGB');
    ICTM_CV(data,300,0.03,0.03,2,1,1,i,'metal');
    % Best param ini, untuk objek ambil ketengah misalkan 60:100
    ICTM_LIF(data,300,5,500,20,1.0,1.0,1,1,i,'metalGray-Object')
    % ICTM_LSAC(image,iterNum, r, sigma, tau, alpha,save,mode,indicator,name)
    ICTM_LSAC(data,300,20,5,0.03,(0.26/sqrt(pi)),1,1,i,'metalGrayscale')
    data = ['paper',num2str(i),'.jpg'];
    ICTM_CV(data,300,0.03,0.03,2,3,1,i,'paperRGB');
    ICTM_CV(data,300,0.03,0.03,2,1,1,i,'paper');
    % Best param ini, untuk objek ambil ketengah misalkan 60:100
    ICTM_LIF(data,300,5,500,20,1.0,1.0,1,1,i,'paperGray-Object')
    % ICTM_LSAC(image,iterNum, r, sigma, tau, alpha,save,mode,indicator,name)
    ICTM_LSAC(data,300,20,5,0.03,(0.26/sqrt(pi)),1,1,i,'paperGrayscale')
    data = ['plastic',num2str(i),'.jpg'];
    ICTM_CV(data,300,0.03,0.03,2,3,1,i,'plasticRGB');
    ICTM_CV(data,300,0.03,0.03,2,1,1,i,'plastic');
    % Best param ini, untuk objek ambil ketengah misalkan 60:100
    ICTM_LIF(data,300,5,500,20,1.0,1.0,1,1,i,'plasticGray-Object')
    % ICTM_LSAC(image,iterNum, r, sigma, tau, alpha,save,mode,indicator,name)
    ICTM_LSAC(data,300,20,5,0.03,(0.26/sqrt(pi)),1,1,i,'plasticGrayscale')
    data = ['glass',num2str(i),'.jpg'];
    ICTM_CV(data,300,0.03,0.03,2,3,1,i,'glassRGB');
    ICTM_CV(data,300,0.03,0.03,2,1,1,i,'glass');
    % Best param ini, untuk objek ambil ketengah misalkan 60:100
    ICTM_LIF(data,300,5,500,20,1.0,1.0,1,1,i,'glassGray-Object')
    % ICTM_LSAC(image,iterNum, r, sigma, tau, alpha,save,mode,indicator,name)
    ICTM_LSAC(data,300,20,5,0.03,(0.26/sqrt(pi)),1,1,i,'glassGrayscale')
end