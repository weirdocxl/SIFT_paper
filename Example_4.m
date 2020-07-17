clear ; close all ;

addpath('.\Conceft') ;
addpath('.\Conceft\tool') ;
% initstate(1) ;

name_file='Ex4';

%% How we generated the simulated data
% 	% the sampling time (100Hz sampling rate)
% 	% high sampling rate to avoid sampling issue
% Hz = 100 ;
% time = [1/Hz:1/Hz:16]' ;
% N = length(time) ;
% 
%         % Setup parameters
%         % the number of random Multitaper (rMT)
% MT = 100 ;
% DDD = 1200*1000*5 ;
% 
% initstate(1) ;
% dim = 2 ;
% 
% 
% 	%% the amplitude modulation of the simulated signal
% am1 = smooth(cumsum(randn(N,1)) ./ Hz, 200, 'loess') ;
% am1 = 2 + am1 ./ max(abs(am1)) ;
% am2 = smooth(cumsum(randn(N,1)) ./ Hz, 200, 'loess') ;
% am2 = 2 + am2 ./ max(abs(am2)) ;
% 
% % am1(1:500) = 0 ;
% % am2(end-600:end) = 0 ;
% 
% 
%     %% the instantaneous frequency of the simulated signal
% 
% if1 = smooth(cumsum(randn(N,1)) ./ Hz, 200, 'loess') ;
% if1 = 5 + time*20/16 + 1*if1 ./ max(abs(if1)) ;
% 
% if2 = smooth(cumsum(randn(N,1)) ./ Hz, 300, 'loess') ;
% if2 = 20 - time*15/16 + 1*if2 ./ max(abs(if2)) ;
% 
% phi1 = cumsum(if1) / Hz ; 
% phi2 = cumsum(if2) / Hz ; 
% 
% 	% the simulated signal.
% s1 = am1 .* cos(2*pi*phi1) ; 
% s2 = am2 .* cos(2*pi*phi2) ; 
% 
% clean = s1 + s2;
% 
% % if1(1:500) = nan ;
% % if2(end-600:end) = nan ;
% % am1(1:500) = nan ;
% % am2(end-600:end) = nan ;
% 
% 
% 
% 
% 	%% add noise (Gaussian white noise)
% sigma = 1;%sqrt( var(clean)*10.^( -snrdb /10 ) );
% noise = random('T',4,N,1) ;
% noise = sigma * noise ; 
% var(noise)
% snrdb = 20 * log10(std(clean)./std(noise)) ;
% fprintf(['snrdb = ',num2str(snrdb),'\n']) ;
% 
% 	%% simulated observed time series
% xm = clean + noise ;
% 
% Smooth = 0 ;
% Hemi = 0 ;
% 

load('Ex4_data')

%% plot Signal

hq = figure;

subplot(3, 2, 1) ;
plot(time, s1, 'color', [.7 .7 .7]) ; axis([1 15 -3 3]) ; set(gca, 'fontsize', 20) ; 
hold on; plot(time, am1, 'k', 'linewidth', 2) ;
set(gca, 'xtick', []) ; ylabel('$s_1(t)$','Interpreter','latex');

subplot(3, 2, 2) ;
plot(time, if1, 'k', 'linewidth', 2) ; set(gca, 'fontsize', 20) ; hold on ;
plot(time, if2, 'k--', 'linewidth', 2) ; %axis([0 12 0 18]) ; 
text(4, if1(400)-2, '$$\varphi''_1(t)$$', 'Interpreter','latex', 'fontsize', 20) ;
text(4, if2(400)+2, '$$\varphi''_2(t)$$', 'Interpreter','latex', 'fontsize', 20) ; set(gca, 'xtick', []) ;
axis([1 15 -Inf Inf])

subplot(3, 2, 3) ;
plot(time, s2, 'color', [.7 .7 .7]) ; axis([1 15 -3 3]) ; set(gca, 'fontsize', 20) ; 
hold on; plot(time, am2, 'k', 'linewidth', 2) ; set(gca, 'xtick', []) ; ylabel('$s_2(t)$','Interpreter','latex');

subplot(3, 2, 4) ;
plot(time, clean, 'k', 'linewidth', 2) ; set(gca, 'fontsize', 20) ;
set(gca, 'xtick', []) ; ylabel('$s_1(t)+s_2(t)$','Interpreter','latex'); axis tight ; axis([1 15 -8 10])

subplot(3, 2, 5) ;
plot(time, noise, 'color', [.7 .7 .7]) ; axis tight ; set(gca, 'fontsize', 20) ;
xlabel('Time (s)','Interpreter','latex'); ylabel('$\xi(t)$','Interpreter','latex'); axis([1 15 -8 10])

subplot(3, 2, 6) ; hold off ;
plot(time, xm, 'color', [.3 .3 .3]) ; axis tight ; set(gca, 'fontsize', 20) ;
xlabel('Time (s)','Interpreter','latex'); ylabel('$s_1(t)+s_2(t)+\xi(t)$','Interpreter','latex'); axis([1 15 -8 10])
set(hq,'PaperPositionMode','auto');
%axis xy ; set(gca,'fontsize', 30) ; axis tight ;
set(hq,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);

saveas(hq,[name_file '_Fig1.eps'],'epsc')

%% TFR calculation

% setup parameters for the SST or ConceFT
% number of chosen orthonormal windows for ConceFT
NoWindowsInConceFT = 2 ;
% number of random linear combinations of chosen windows
NoConceFT = 1 ;
%the window length. Ideally, it should be chosen so that
% roughly 7-10 oscillations (ignore the multiples) are
% included in the window. Must be odd, See hermf.m
WindowLength = 377 ;
% this is the bandwith of the chosen window. See hermf.m
% in the attached code for details.
WindowBandwidth = 10 ;
SamplingRate = Hz ;
% Setup the frequency range for the analysis
% The allowed range is 0-0.5
% This part might be tricky. This 0-0.5 limitation is
% setup under the assumption that the sampling rate is 1Hz
% After the analysis, the sampling rate should be adjusted
% so that the result is associated with the original
% sampling rate.
% In this example, the true range is [0, 0.5]*SamplingRate
HighFrequencyLimit = 0.5 ;
LowFrequencyLimit = 0 ;
% the frequency axis resolution in the final time-frequency representation
FrequencyAxisResolution = 0.0001 ;

% call the main code, which is the ConceFT based on
% synchrosqueezed short time Fourier transform (STFT)
% Output:
% tfr: STFT result
% tfrtic: frequency axis tic for the STFT
% tfrsq: synchrosqueezed STFT (it is equivalent to running ConceFT only one time)
% ConceFT: ConceFT of synchrosqueezed STFT.
% tfrsqtic: frequency axis tic for the tfrsq and ConceFT
[tfr, tfrtic, tfrsq, ConceFT, tfrsqtic] = ConceFT_STFT(xm, LowFrequencyLimit,...
    HighFrequencyLimit, FrequencyAxisResolution, 1, WindowLength, NoWindowsInConceFT, WindowBandwidth, NoConceFT, 0, 0, 0) ;

%% We use the ground truth frequency patterns for the instantaneous frequency curves

int1=[8,20];
int2=[1,11];
freq=tfrsqtic*Hz;

M_n(:,1)=if1;
M_n(:,2)=if2;

for ii=1:length(if1)
    [val,curve_n(ii,1)]=min(abs(freq-if1(ii)));
    [val,curve_n(ii,2)]=min(abs(freq-if2(ii)));
end

%% figure

hq = figure;
imageSQ(time, tfrsqtic*Hz, abs(tfrsq), .995) ; colormap(1-gray) ;
axis xy ; set(gca,'fontsize', 30) ; 
hold on ;
% plot(time, if1, 'k', 'linewidth', 2) ; set(gca, 'fontsize', 30) ; hold on ;
% plot(time, if2, 'k', 'linewidth', 2) ; %axis([0 12 0 18]) ; 
% text(4, if1(400)+1, '$$\varphi''_1(t)$$', 'Interpreter','latex', 'fontsize', 36) ;
% text(6, if2(600)+1, '$$\varphi''_2(t)$$', 'Interpreter','latex', 'fontsize', 36) ; %set(gca, 'xtick', []) ;
x1=xlabel('time (s)','Interpreter','latex');
y1=ylabel('frequency (Hz)','Interpreter','latex');
plot(time, M_n(:,1), 'b', 'linewidth', 2) ;
plot(time, M_n(:,2), 'r', 'linewidth', 2) ;
lg=legend('$$\varphi''_1(t)$$','$$\varphi''_2(t)$$');
set(lg,'Interpreter','latex');
axis([1 15 4 26])
set(hq,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(hq,[name_file '_if.eps'],'epsc')

%% We split the first curve into three subcurves

temp_curve1=M_n(:,2);
temp_curve2=M_n(:,1);

M_n(550:end,2)=temp_curve2(550:end)+temp_curve1(550)-temp_curve2(550);
M_n(:,3)=temp_curve2;
% we reduce the overlapping at the crossing
M_n(540:844,3)=M_n(540:844,3).*(0.1*sin(pi*(1:(844-540+1))/(844-540+1))+1)';

M_n(:,4)=temp_curve1;
M_n(1:550,4)=ones(1,550)*temp_curve1(550);

M_n(:,1)=temp_curve1+4;
M_n(725:end,1)=temp_curve2(725:end)+M_n(725,1)-temp_curve2(725);

hq = figure;
imageSQ(time, tfrsqtic*Hz, abs(tfrsq), .995) ; colormap(1-gray) ;
axis xy ; set(gca,'fontsize', 30) ; 
hold on ;
% plot(time, if1, 'k', 'linewidth', 2) ; set(gca, 'fontsize', 30) ; hold on ;
% plot(time, if2, 'k', 'linewidth', 2) ; %axis([0 12 0 18]) ; 
% text(4, if1(400)-2, '$$\varphi''_1(t)$$', 'Interpreter','latex', 'fontsize', 36) ;
% text(4, if2(400)+2, '$$\varphi''_2(t)$$', 'Interpreter','latex', 'fontsize', 36) ; %set(gca, 'xtick', []) ;
x1=xlabel('time (s)','Interpreter','latex');
y1=ylabel('frequency (Hz)','Interpreter','latex');
plot(time, M_n(:,1), 'b', 'linewidth', 2) ;
plot(time, M_n(:,2), 'r', 'linewidth', 2) ;
plot(time, M_n(:,3), 'g', 'linewidth', 2) ;
plot(time, M_n(:,4), 'y', 'linewidth', 2) ;
lg=legend('$$\varphi''_1(t)$$','$$\varphi''_2(t)$$','$$\varphi''_3(t)$$','$$\varphi''_4(t)$$');
set(lg,'Interpreter','latex');
axis([1 15 0 30])
set(hq,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);

%% ALIF decomposition using manualy designed curves build using the observed frequencies

addpath('.\ALIF')

% First component

opt = Settings_ALIF('ALIF.NIMFs',1,'plots',0,'saveplots',0,'ALIF.xi',1.4,'ALIF.delta',10^-6);

mask1 = opt.ALIF.xi*1./(M_n(:,1)')*Hz;

IMT1=ALIFv5_1(xm,opt,mask1);

% second IMT
opt = Settings_ALIF('ALIF.NIMFs',1,'plots',0,'saveplots',0,'ALIF.xi',1.4,'ALIF.delta',10^-6);

mask2 = opt.ALIF.xi*1./M_n(:,1)'*Hz;

IMT2=ALIFv5_1(IMT1(2,:),opt,mask2);

% third IMT
% opt = Settings_ALIF('ALIF.NIMFs',1,'plots',0,'saveplots',0,'ALIF.xi',1.1,'ALIF.delta',10^-5);
% 
% mask3 = opt.ALIF.xi*1./(M_n(:,2)')*Hz;
% 
% IMT3=ALIFv5_1(IMT2(2,:),opt,mask3);
% 
% plot_imf_v8([IMT3],time);

IMT3=[zeros(size(IMT2(2,:)));IMT2(2,:)];
%plot_imf_v8([IMT3],time);
% fourth IMT
opt = Settings_ALIF('ALIF.NIMFs',1,'plots',0,'saveplots',0,'ALIF.xi',1.4,'ALIF.delta',10^-7);

mask4 = opt.ALIF.xi*1./(M_n(:,2)')*Hz;

IMT4=ALIFv5_1(IMT3(2,:),opt,mask4);

% fifth IMT
opt = Settings_ALIF('ALIF.NIMFs',1,'plots',0,'saveplots',0,'ALIF.xi',1.1,'ALIF.delta',10^-5);

mask5 = opt.ALIF.xi*1./(M_n(:,3)')*Hz;

IMT5=ALIFv5_1(IMT4(2,:),opt,mask5);

% sixth IMT
opt = Settings_ALIF('ALIF.NIMFs',1,'plots',0,'saveplots',0,'ALIF.xi',1.4,'ALIF.delta',10^-6);

mask6 = opt.ALIF.xi*1./(M_n(:,3)')*Hz;

IMT6=ALIFv5_1(IMT5(2,:),opt,mask6);

% 7th IMT
opt = Settings_ALIF('ALIF.NIMFs',1,'plots',0,'saveplots',0,'ALIF.xi',1.1,'ALIF.delta',10^-5);

mask7 = opt.ALIF.xi*1./(M_n(:,4)')*Hz;

IMT7=ALIFv5_1(IMT6(2,:),opt,mask7);

% 8th IMT
opt = Settings_ALIF('ALIF.NIMFs',1,'plots',0,'saveplots',0,'ALIF.xi',1.4,'ALIF.delta',10^-4);

mask8 = opt.ALIF.xi*1./(M_n(:,4)')*Hz;

IMT8=ALIFv5_1(IMT7(2,:),opt,mask8);
%
close all
IMT=[IMT1(1,:);IMT2(1,:);IMT3(1,:);IMT4(1,:);IMT5(1,:);IMT6(1,:);IMT7(1,:);IMT8];

%%
hq=plot_imf_v11([sum(IMT([4 8],:),1);IMT(6,:)],[s2';s1'],time,2,[],[],[],[],'IMTs','Ground truth');
saveas(hq,[name_file '_ALIF_IMTs.eps'],'epsc')

% Comparisons with ground truth
[val,crossing_pos]=min(abs(time-6.93));% the if curves they interesct visually around 6.97 seconds

%% differences IMTs
hf = figure ;
plot(time,IMT(6,:)-s1','r')
axis xy ; set(gca,'fontsize', 30) ; 
axis([1 15 -6 6])
set(hf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(hf,[name_file '_IMT1_diff.eps'],'epsc')

err_IMT1_ALIF=norm(IMT(6,Hz:end-Hz)-s1(Hz:end-Hz)',2)/norm([s1(Hz:end-Hz)'],2)

hf = figure ;
plot(time,sum(IMT([4 8],:),1)-s2','r')
axis xy ; set(gca,'fontsize', 30) ; 
axis([1 15 -6 6])
set(hf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(hf,[name_file '_IMT2_diff.eps'],'epsc')

err_IMT2_ALIF=norm(sum(IMT([4 8],Hz:end-Hz),1)-s2(Hz:end-Hz)',2)/norm(s2(Hz:end-Hz)',2)

%% TFR calculation of each ALIF IMT 

[tfr, tfrtic, tfrsq_1, ConceFT, tfrsqtic] = ConceFT_STFT(IMT(6,:)', LowFrequencyLimit,...
    HighFrequencyLimit, FrequencyAxisResolution, 1, WindowLength, NoWindowsInConceFT, WindowBandwidth, NoConceFT, 0, 0, 0) ;

[tfr, tfrtic, tfrsq_2, ConceFT, tfrsqtic] = ConceFT_STFT(sum(IMT([4 8],:),1)', LowFrequencyLimit,...
    HighFrequencyLimit, FrequencyAxisResolution, 1, WindowLength, NoWindowsInConceFT, WindowBandwidth, NoConceFT, 0, 0, 0) ;
hq = figure;
imageSQ(time, tfrsqtic*Hz, abs(tfrsq_1+tfrsq_2), .995) ; colormap(1-gray) ;
axis xy ; set(gca,'fontsize', 30) ;
hold on
x1=xlabel('time (s)','Interpreter','latex');
y1=ylabel('frequency (Hz)','Interpreter','latex');
plot(time, temp_curve1, 'b', 'linewidth', 2) ;
plot(time, temp_curve2, 'r', 'linewidth', 2) ;
lg=legend('$$\varphi''_1(t)$$','$$\varphi''_2(t)$$');
set(lg,'Interpreter','latex');
axis([1 15 4 26])
set(hq,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(hq,[name_file '_SST_IMTs.eps'],'epsc')

