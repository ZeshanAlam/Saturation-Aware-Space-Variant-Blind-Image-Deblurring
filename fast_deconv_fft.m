function [Y Z]= fast_deconv_fft( X, fH, pad_value )
% Convolve with a large support kernel in the Fourier domain.
%
% Y = fast_conv_fft( X, fH, pad_value )
%
% X - image to be convolved (in spatial domain)
% fH - filter to convolve with in the Fourier domain, idealy 2x size of X
% pad_value - value to use for padding when expanding X to the size of fH
%
% (C) Rafal Mantiuk <mantiuk@gmail.com>
% This is an experimental code for internal use. Do not redistribute.

pad_size = (size(fH)-size(X));

%mX = mean( X(:) );
X=double(X);
% fX = fft2( padarray( X, pad_size,pad_value,'post') );
fX = fft2( padarray( X, pad_size, 'symmetric','post' ) );
ig=fX.*fH;
id=fX./fH;
Yl = real(ifft2( ig, size(fX,1), size(fX,2), 'symmetric' ));
Yp = real(ifft2( id, size(fX,1), size(fX,2), 'symmetric' ));
Y = Yl(1:size(X,1),1:size(X,2));
Z = Yp(1:size(X,1),1:size(X,2));

end