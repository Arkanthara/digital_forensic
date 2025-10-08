close all;
clear all;
I_orig = double(imread('Lena_512.bmp'));
[row coln]= size(I_orig);

%----------------------------------------------------------
% Quality Factor = [1,100]
QF1 = 50;
QF2 = 75;

%----------------------------------------------------------
% Quality Matrix Formulation
%----------------------------------------------------------
Q50 = [ 16 11 10 16 24 40 51 61;
        12 12 14 19 26 58 60 55;
        14 13 16 24 40 57 69 56;
        14 17 22 29 51 87 80 62;
        18 22 37 56 68 109 103 77;
        24 35 55 64 81 104 113 92;
        49 64 78 87 103 121 120 101;
        72 92 95 98 112 100 103 99];

    
%----------------------------------------------------------
% Quality Matrix for QF1    
    
if QF1 > 50
    QM1 = round(Q50.*(ones(8)*((100-QF1)/50)));
    QM1 = uint8(QM1);
elseif QF1 < 50
    QM1 = round(Q50.*(ones(8)*(50/QF1)));
    QM1 = uint8(QM1);
elseif QF1 == 50
    QM1 = Q50;
end
QM1 = double(QM1);


%----------------------------------------------------------
% Quality Matrix for QF2 

if QF2 > 50
    QM2 = round(Q50.*(ones(8)*((100-QF2)/50)));
    QM2 = uint8(QM2);
elseif QF2 < 50
    QM2 = round(Q50.*(ones(8)*(50/QF2)));
    QM2 = uint8(QM2);
elseif QF2 == 50
    QM2 = Q50;
end
QM2 = double(QM2);



dct_domain = zeros(size(I_orig));
dct_quantized = zeros(size(I_orig));
dct_quantized_coeff = zeros(64,length(1:8:row)*length(1:8:coln));


dct_dequantized = zeros(size(I_orig));
dct_restored = zeros(size(I_orig));

dct_domain2 = zeros(size(I_orig));
dct_quantized2 = zeros(size(I_orig));
dct_quantized2_coeff = zeros(64,length(1:8:row)*length(1:8:coln));

%---------------------------------------------------------
% Subtracting each image pixel value by 128
%--------------------------------------------------------
I = I_orig - 128;


%----------------------------------------------------------
% Jpeg Encoding
%----------------------------------------------------------
k = 1;
for i1=1:8:row
    for i2=1:8:coln
        zBLOCK=I(i1:i1+7,i2:i2+7);
        %----------------------------------------------------------
        % Forward Discret Cosine Transform
        win1 = dct2(zBLOCK);
        dct_domain(i1:i1+7,i2:i2+7)=win1;
        %-----------------------------------------------------------
        % Quantization of the DCT coefficients
        win2=round(win1./QM1);
        dct_quantized(i1:i1+7,i2:i2+7)=win2;
        dct_quantized_coeff(:,k) = zigzag(win2);
        k = k+1;
    end
end



%-----------------------------------------------------------
% Jpeg Decoding
%----------------------------------------------------------
for i1=1:8:row
    for i2=1:8:coln
        win2 = dct_quantized(i1:i1+7,i2:i2+7);
        %-----------------------------------------------------------
        % Dequantization of DCT Coefficients
        win3 = win2.*QM1;
        dct_dequantized(i1:i1+7,i2:i2+7) = win3;
        %-----------------------------------------------------------
        % Inverse DISCRETE COSINE TRANSFORM
        win4 = idct2(win3);
        dct_restored(i1:i1+7,i2:i2+7)=win4;
    end
end

I_reconst=dct_restored;




%----------------------------------------------------------
% Jpeg Encoding 2
%----------------------------------------------------------

k = 1;
for i1=1:8:row
    for i2=1:8:coln
        zBLOCK=I_reconst(i1:i1+7,i2:i2+7);
        %----------------------------------------------------------
        % Forward Discret Cosine Transform
        win5 = dct2(zBLOCK);
        dct_domain2(i1:i1+7,i2:i2+7)=win5;
        %-----------------------------------------------------------
        % Quantization of the DCT coefficients
        win6=round(win5./QM2);
        dct_quantized2(i1:i1+7,i2:i2+7)=win6;
        dct_quantized2_coeff(:,k) = zigzag(win6);
        k = k+1;
       
    end
end

figure;imagesc(dct_quantized); colorbar; colormap(gray); title('DCT 1st quant');
figure;imagesc(dct_quantized2); colorbar; colormap(gray); title('DCT 2nd quant');




% Global analysis of DCT coefficients

min_dct = min(min(dct_quantized(:)), min(dct_quantized2(:)));
max_dct = max(max(dct_quantized(:)), max(dct_quantized2(:)));


x_bin = min_dct:max_dct;
[y_quantized, x_bin1] = hist(dct_quantized(:), x_bin);
[y_quantized2, x_bin2] = hist(dct_quantized2(:), x_bin);

figure; 
    
subplot(2,1,1);
bar(y_quantized)
title('One time compressed')
    
subplot(2,1,2);
bar(y_quantized2)
title('Double compressed')
    
suptitle({'Global histogram of DCT coeff';['QF1 = ',num2str(QF1),'; QF2 = ',num2str(QF2)]})
    



% Pairwise analysis of DCT coefficients

for i = 1:10%64
    min_dct = min(min(dct_quantized_coeff(i,:)), min(dct_quantized2_coeff(i,:)));
    max_dct = max(max(dct_quantized_coeff(i,:)), max(dct_quantized2_coeff(i,:)));

    x_bin = min_dct:max_dct;

    [y_quantized_coeff, x_bin1]  = hist(dct_quantized_coeff(i,:), x_bin);
    [y_quantized2_coeff, x_bin2] = hist(dct_quantized2_coeff(i,:), x_bin);

    
    figure; 
    
    subplot(2,1,1);
    bar(y_quantized_coeff)
    title('One time compressed')
    
    subplot(2,1,2);
    bar(y_quantized2_coeff)
    title('Double compressed')
    
    suptitle({['Histogram of ',num2str(i),'th DCT coeff'];['QF1 = ',num2str(QF1),'; QF2 = ',num2str(QF2)]})
    
end





