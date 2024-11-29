function filt = gsf2filter( f_size, pix_per_unit, psf, pos )
% filt = gsf2filter( f_size, pix_per_deg, d, psf )
%
% f_size      - size of the filter [rows columns]
% pix_per_unit - pixels per unit of the GSF filter
%                Example: if the image resolution is scaled by 0.25, 
%                pix_per_unit should be 0.25, because
%                1 pixel in the image / 4 pixels on the sensor = 0.25
% psf         - PSF function taking arguments:
%               psf( R )
%               where R is the distance from the center in the GSF units
% pos - [optional] the position of the the center of the filter 
%
% GSF unit could be a pixel width on the sensor. If image from the sensor
% has been resized to 0.5 of the original resolution, pix_per_unit should
% be set to 0.5. 
%
% Note that the function assumes that the GSF is a combination of an arbitrary 
% fuction and a Dirac peak for pfs(0).
%
% @author Rafal Mantiuk

hd_thresh = 10;

%pix_rho = 1/pix_per_unit; % size of a single pixel (center) in vis deg
%pix_m = 2 * tan( pix_rho / 2 / 180 * pi ) * d; % size of a single pixel in meters
%pix_area = (pix_rho/180*pi)^2; % Pixel area in steradians

pix_area = (1/pix_per_unit)^2;

%size_m2 = f_size/2;

% Coarse sampling for theta >= 1

med_pos = floor(f_size/2)+1;

k_shift = [0 0];
if exist( 'pos', 'var' )
    k_shift = pos-med_pos;
    med_pos = pos;
end

% the pixel coords for the convolution kernel
KX0 = (-floor(f_size(2)/2)-k_shift(2)):((ceil(f_size(2)/2)-1)-k_shift(2));
KY0 = (-floor(f_size(1)/2)-k_shift(1)):((ceil(f_size(1)/2)-1)-k_shift(1));

[XX, YY] = meshgrid( KX0, KY0 );

rho = sqrt( (XX/pix_per_unit).^2 + (YY/pix_per_unit).^2 );

filt = zeros( size(rho) );
filt(rho >= hd_thresh) = psf( rho(rho >= hd_thresh) ) * pix_area; 

% Dense sampling for theta < hd_thresh
sampl_rate = 10;

ind_x = find( rho(med_pos(1),:)<hd_thresh );
ind_y = find( rho(:,med_pos(2))<hd_thresh );
ul = [ind_y(1) ind_x(1)];
br = [ind_y(end) ind_x(end)];
d_size = (br-ul)+1;

%size_md2 = size_m2 - [(ul(1)-1) (ul(2)-1)]*pix_m + pix_m/2;


[XX, YY] = meshgrid( linspace( XX(1,ul(2)), XX(1,br(2)), d_size(2)*sampl_rate + 1 ), ...
                    linspace( YY(ul(1),1), YY(br(1),1), d_size(1)*sampl_rate + 1 ) );
                
rho_d = sqrt( (XX/pix_per_unit).^2 + (YY/pix_per_unit).^2 );               

% Create larger filter, than downsample using integral
P = psf( rho_d ) * pix_area; 
P(rho_d==0) = psf( 0 ); % do not integrate over Dirac peak
P_int = cumtrapz( P, 1) / sampl_rate;
P_int2 = cumtrapz( P_int(1:sampl_rate:end,:), 2) / sampl_rate;
f1 = diff( P_int2(:,1:sampl_rate:end), 1, 2 );
filt_d = diff( f1, 1, 1 );

filt(ul(1):br(1), ul(2):br(2)) = filt_d;

end