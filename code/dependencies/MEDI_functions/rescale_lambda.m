function lam = rescale_lambda(lam_in,delta_TE,CF) 
    % MEDI+0, Magnetic Resonance in Medicine 79:2795–2803 (2018)
    % The optimized parameters values were lambda_1 = 0,001 for MEDI and lambda_1 = 0,001, 
    % lambda_2 = 0.1, R = 5s^{-1} for MEDI+0. These values were used throughout this work.
    % Keeping R fixed at 5s^{-1} RMSE for MEDI+0 was minimized at 73.7% for lambda_2 = 0.1 
    % (Supporting Fig. S2a)
    % In the simulation, CF = 127736944 and delta_TE = 0.0026
    % Finally, in this code lambda_2 is given with respect to lambda_1, so that for the 
    % code lam2 is 0.01/0.001 = 100
    lam = lam_in*(127736944*0.0026)/(delta_TE*CF);
    % lam2 = 100.0f*(127736944.0f*0.0026f)/(para.delta_TE*para.CF);