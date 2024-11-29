function G = camera_gsf( R, pars )
% Glare spread functions of a camera
%
% G = camera_gsf( R, pars )
% G = camera_gsf( R, camera_name )
%
% R - distance from the centre in pixels
% pars - 7 parameters controlling the GSF, used only when fitting
% camera_name - the name of a camera and lens
%

if ~exist( 'pars', 'var' )
    pars = '';
end

if( 0 ) % A more complex model

if ischar( pars )
    switch pars
        case {'', 'canon-2000d' }
            pars = [ 0.941155, 1.60387, 0.999069, 7.27489, 0.0133445, 0.0781611, 1.0017 ];
        case 'sony-7r1-55'
            pars = [ 0.973034, 216.164, 0.998055, 11.7877, 0.406497, 0.048441, 1.00088 ];
        case 'sony-7r1-50'
            pars = [ 0.956533, 1.595, 0.999458, 12.454, 0.855856, 0.0461258, 1.00223 ];
        otherwise
            error( 'Unrecognized camera' );    
    end
end

a1 = pars(1);
b1 = pars(2);
c1 = pars(3);
a2 = pars(4);
b2 = pars(5);
c2 = pars(6);
v0 = pars(7);

G = exp( -a1*abs(R).^c1 )*b1 + exp( -a2*abs(R).^c2 )*b2;

else % A simple model

    
    if ischar( pars )
    switch pars
        case {'', 'canon-2000d' }
            pars = [ 45.4842, 2.09977e+15, 0.0195372, 99.2499 ];
        case 'sony-7r1-55'
            pars = [ 49.0013, 1.26469e+16, 0.015201, 99.6761 ];
        case 'sony-7r1-50'
            pars = [ 48.2565, 5.84812e+15, 0.0151168, 99.6236 ];
        case 'Sony-55mm-F1.8'
            pars = [31.0622, 5.45523e+09, 0.0486953, 46.0016];
        case 'IDS-APmax'    
              pars = [ 51.9673, 1.1503e+19, 0.0271011, 97.8896];
        case 'IDS-APmax_noise'    
              pars = [51.3221553412939,1.32165991582356e+19,0.0309197384611532,111.762439847366];      
         case 'IDS-APmax-noise1'      
              pars = [52.1200170669205 ,1.14124388590836e+19 ,0.0273418649885583 ,96.7667376605683];
         case 'IDS-APmax-noise2'      
              pars = [52.9018648716947, 1.11275562292499e+19, 0.0270998753076621, 96.36312723075011];
         case 'Canon-50mm'              
              pars = [ 32.2162, 4.40381e+08, 0.0392506, 53.2176];    
       
        otherwise
            error( 'Unrecognized camera' );    
    end
end    
  
a1 = pars(1);
b1 = pars(2);
c1 = pars(3);
v0 = pars(4);

G = exp( -a1*abs(R).^c1 )*b1;
    
end

G(R==0) = v0;

end
