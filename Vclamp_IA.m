%%
cd 'Z:\MOVE_TO_ARCHIVE\To_backup_to_GD\david_hampton\Data\894'
%addpath(genpath('C:\Users\moroz\Dropbox\codes_Katya\'))

for i=1
    switch i
        case 1
            folder{i}='\894_146' % pH down
         case 2
             folder{i}='\894_140' % pH down
    end
end
%% load data
DataI=[];

for j=1
    j
    directory=[pwd,folder{j},'\I_A'];
    file_search = strcat(directory, '\', '*.abf');
    files=dir(file_search);
    for i = 1:length(files)
        file_names{i}=files(i).name;
        fullfile_name = fullfile(directory, file_names(i));
        [DataI{j,i},step,h] = abfload((fullfile_name{1}));
        Fs=1/step*10^6;
        
    end
end

%% plot raw data
x=1/Fs:1/Fs:length(DataI{jj,j}(:,1))/Fs;
clf, subplot(2,2,1), plot(x,squeeze(DataI{jj,j}(:,2,:)),'k','linewidth',2)
ylim([-50 50]); xlim([0 x(end)])
ylabel('Current, nA')
subplot(2,2,3), plot(x,squeeze(DataI{jj,j}(:,1,:)),'k','linewidth',2)
xlim([0 x(end)])
ylabel('Voltage, mV'); xlabel('Time, sec')

%% IA
IA=[]; EK=-80; V=-50:40; gA=[]; IA_1=[];
for jj=1 %experiment
    for j=1:size(DataI,2) % pH
        IA_1{jj,j}=squeeze(DataI{jj,j}(:,2,1:10));
        IA{jj,j}=squeeze(DataI{jj,j}(:,2,1:10)-DataI{jj,j}(:,2,1)); % subtract the first step
        for i=1:10 % V steps
            gA{jj,j}(i,:)=IA{jj,j}(:,i)./(V(i)-EK);
            gA_1{jj,j}(i,:)=IA_1{jj,j}(:,i)./(V(i)-EK);
        end
    end
end

%% find the peak of the current trace
maxg=[]; maxng=[]; maxIa=[]; maxnIa=[];

[maxI,maxIidx] = max(squeeze(diff(DataI{jj,j}(:,1,:)))); % start of the positive current steps
istart = maxIidx(1)+0.02*Fs;

for jj=1 %experiment
    for j=1:size(DataI,2) % pH
        for i=1:size(DataI{1},3) % current step
            [maxg{jj,j}(i),maxng{jj,j}(i)]=max(smooth(gA{jj,j}(i,istart:end))); 
            [maxIa{jj,j}(i),maxnIa{jj,j}(i)]=max(smooth(IA{jj,j}(istart:end,i))); 
        end
    end
end

%% plot current traces and activation curve
jj=1; j=1;
c=jet(20);
clf, subplot(3,4,[1,5]) % plot current
x=1/Fs:1/Fs:length(IA{jj,j})/Fs;
for i=1:size(DataI{1},3) % current step
    plot(x,(IA_1{jj,j}(:,i)),'linewidth',2,'color',c(i,:,:)), hold on
end
xlabel('time, ms');ylabel('I, nA')
xlim([maxIidx(1)/Fs-0.1 x(end)]);
set(gca,'Fontsize',14)

axes('Position',[.17 .75 .1 .15]) % inset to zoom in on the peaks
for i=1:size(DataI{1},3) % current step
    plot(x,(IA{jj,j}(:,i)),'linewidth',2,'color',c(i,:,:)), hold on
end
xlim([maxIidx(1)/Fs maxIidx(1)/Fs+0.1]);

subplot(3,4,[2,6]) % plot subtracted current
x=1/Fs:1/Fs:length(IA{jj,j})/Fs;
for i=1:size(DataI{1},3) % current step
    plot(x,(IA{jj,j}(:,i)),'linewidth',2,'color',c(i,:,:)), hold on
end
xlabel('time, ms');ylabel('I-I(V=-40mV), nA')
xlim([maxIidx(1)/Fs-0.1 x(end)]);
set(gca,'Fontsize',14)

subplot(3,4,9) % voltage steps
for i=1:size(DataI{1},3) % current step
    plot(x,squeeze(DataI{jj,j}(:,1,i)),'linewidth',2,'color',c(i,:,:)), hold on
end
ylabel('Voltage,mV')
xlim([maxIidx(1)/Fs-0.1 x(end)]);
ylim([min(min(squeeze(DataI{jj,j}(:,1,:))))-5 max(max(squeeze(DataI{jj,j}(:,1,:))))+5])
set(gca,'Fontsize',14) 

subplot(3,4,[3,7])
x=1/Fs:1/Fs:length(gA{jj,j})/Fs;
for i=4:size(DataI{1},3) % current step
    plot(x,(gA{jj,j}(i,:)'),'linewidth',2,'color',c(i,:,:)), hold on
end
xlabel('time, ms'); ylabel('gA, uS')
xlim([maxIidx(1)/Fs-0.1 x(end)]);
hold on, plot(maxng{jj,j}(4:10)/Fs+istart/Fs,maxg{jj,j}(4:10),'o','linewidth',2,'color','k')
set(gca,'Fontsize',14)
axes('Position',[.6 .7 .09 .2])
for i=1:size(DataI{1},3) % current step
    plot(x,(gA{jj,j}(i,:)),'linewidth',2,'color',c(i,:,:)), hold on
end
hold on, plot(maxng{jj,j}(4:10)/Fs+istart/Fs,maxg{jj,j}(4:10),'o','linewidth',2,'color','k')
xlim([maxIidx(1)/Fs maxIidx(1)/Fs+0.1]);

% fit sigmoid function to the activation curve and plot
subplot(3,4,[4,8]) 
V=-50:10:40;
plot(V,maxg{jj,j},'.-','markersize',15,'linewidth',1,'color','k')
V1=-50:0.1:80;
y=maxg{jj,j};
fun=@(x)(x(3)./(1+exp((x(1)-V)/x(2)))).^3-y;
x0 = [-30, 17,1];
x = lsqnonlin(fun,x0)
yfit=(x(3)./(1+exp((x(1)-V1)/x(2)))).^3;
Vhalf(jj,j)=x(1); % half activation voltage
kA(jj,j)=x(2); % slope
A(jj,j)=x(3); % madnitude

plot(V,y,'ko',V1,yfit,'b-','linewidth',2)
xlim([V1(1)-5 V1(end)+5])
legend('Data','Best fit','location','northwest')
xlabel('Voltage, mV')
title('Activation curve')
set(gca,'Fontsize',14)

% fit double exponential decay of IA and plot
yfit1=yfit./max(yfit); % normalize
subplot(3,4,10)
for i=4:size(DataI{1},3) % current steps
    gA11=gA{jj,j}(i,maxng{jj,j}(i)+istart:3*Fs)-min(gA{jj,j}(i,maxng{jj,j}(i)+istart:3*Fs));
    d=1:length(gA11);
    fun=@(x)x(1).*(yfit1(i)*exp(-d./x(2)+(1-yfit1(i))*exp(-d./x(3))))-gA11;
    x0 = [1, 300, 500];
    x = lsqnonlin(fun,x0);
    yfittau1=x(1).*(yfit1(i)*exp(-d./x(2)+(1-yfit1(i))*exp(-d./x(3))));
    tau_inact1{jj}(i)=x(2); tau_inact2{jj}(i)=x(3);
    plot(d,gA11,'k.',d,yfittau1,'b-','linewidth',2), hold on
    legend('Data','Best fit')
    xlabel('time, ms')
    hold on
end
title('Inactivation')

% fit exponential rise
subplot(3,4,11)
for i=4:size(DataI{1},3)
    gA11=gA{jj,j}(i,istart-0.01*Fs:maxng{jj,j}(i)+istart)-min(gA{jj,j}(i,istart-0.01*Fs:maxng{jj,i}(i)+istart));   
    d=1:length(gA11);
    fun=@(x)(x(1).*(1-exp(-d./x(2)))).^3-gA11;
    x0 = [1, 30];
    x = lsqnonlin(fun,x0);
    yfittauact1=(x(1).*(1-exp(-d./x(2)))).^3;
    tau_act{jj}(j,i)=x(2);
     plot(d,gA11,'k.',d,yfittauact1,'b-','linewidth',2)
     legend('Data','Best fit')
     hold on
end
title('Activation'); xlabel('time, ms')

subplot(3,4,12)
yyaxis left
plot(V(5:10),tau_inact1{jj}(j,5:10)./Fs*10^3,'.-','markersize',15,'linewidth',1.5), hold on
%plot(V(5:10),tau_inact2{jj}(j,5:10)./Fs*10^3,'.-','markersize',15,'linewidth',1)
ylabel('Inactivation time constant, ms')
yyaxis right
plot(V(5:10),tau_act{jj}(j,5:10)./Fs*10^3,'.-','markersize',15,'linewidth',1.5)
ylabel('Activation time constant, ms')
xlabel('Voltage,mV')
title('Activation/Inactivation time constants')
set(gca,'Fontsize',14)
