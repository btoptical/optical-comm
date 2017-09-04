function SE = capacity_linear_regime(X, E, Pump, Signal, spanAttdB, Namp, df)
%% Compute system capacity in linear regime for a particular EDF length and power loading specificied in vector X
% X(1) is the EDF length, and X(2:end) has the signal power ate each
% wavelength. Simulations assume ideal gain flatenning, resulting in the
% simplified capacity formula
% Inputs:
% - X: vector containing EDF length and power load
% - E: instance of class EDF
% - Pump: instance of class Channels corresponding to pump
% - Signal: instance of class Channels corresponding to signals
% - spanAttdB: span attenuation in dB
% - Namp: number of amplifiers in the chain
% - df: frequency spacing used for computing ASE power
% Output:
% - SE: spectral efficiency i.e., capacity normalized by bandwidth

E.L = X(1);
Signal.P = X(2:end);

GaindB = E.semi_analytical_gain(Pump, Signal);
Pase = (Namp-1)*analytical_ASE_PSD(E, Pump, Signal)*df;   

Gain = 10.^(GaindB/10);
SNR = Gain.*Signal.P./Pase;
SE = sum(log2(1 + SNR(GaindB >= spanAttdB)));  