function T=btms_nasa_validate(filePath)
% NASA Ames B0005: oryginalne pomiary pojemnosci w cyklach rozladowania.
% 70/30 PODZIAL CHRONOLOGICZNY; prosty model Q=a+b*sqrt(cycle).
% NIE waliduje modelu cieplnego EV ani prognozy SOH 10-letniej.
root=fileparts(fileparts(mfilename('fullpath')));
if nargin<1 || isempty(filePath)
    filePath=fullfile(root,'nasa_data','B0005.mat');
end
if ~isfile(filePath),error('NASA: brak pliku %s',filePath);end
S=load(filePath);
if isfield(S,'B0005')
    r=S.B0005;
else
    vars=fieldnames(S);
    if isempty(vars),error('NASA: pusty plik MAT');end
    r=S.(vars{1});
end
if ~isstruct(r)||~isfield(r,'cycle')
    error('NASA: oczekiwano struktury B0005.cycle');
end
cycles=r.cycle;
capacities=zeros(numel(cycles),1); kvalid=0;
for k=1:numel(cycles)
    entry=cycles(k);
    if ~isfield(entry,'type')||~strcmpi(strtrim(char(entry.type)),'discharge')
        continue
    end
    if ~isfield(entry,'data')||~isstruct(entry.data)||~isfield(entry.data,'Capacity')
        continue
    end
    v=double(entry.data.Capacity);
    if isempty(v),continue;end
    v=v(1);
    if ~isfinite(v)||v<=0,continue;end
    kvalid=kvalid+1;capacities(kvalid)=v;
end
capacities=capacities(1:kvalid);
N=numel(capacities);
if N<15,error('NASA: za malo prawdziwych cykli rozladowania (N=%d)',N);end
cy=(1:N)';ntrain=floor(.7*N);
X=[ones(N,1),sqrt(cy)];
b=X(1:ntrain,:)\capacities(1:ntrain);
pred=X*b;
rmseTrain=sqrt(mean((capacities(1:ntrain)-pred(1:ntrain)).^2));
rmseTest=sqrt(mean((capacities(ntrain+1:end)-pred(ntrain+1:end)).^2));
T=table(N,ntrain,N-ntrain,rmseTrain,rmseTest,capacities(1),capacities(end),...
    'VariableNames',{'n_cycles','train_n','test_n','RMSE_train_Ah','RMSE_test_Ah','C_first_Ah','C_last_Ah'});
if ~isfolder(fullfile(root,'results')),mkdir(fullfile(root,'results'));end
if ~isfolder(fullfile(root,'figures')),mkdir(fullfile(root,'figures'));end
writetable(T,fullfile(root,'results','nasa_validation_matlab.csv'));
values=table(cy,capacities,pred,'VariableNames',{'discharge_index','capacity_Ah','capacity_fit_Ah'});
writetable(values,fullfile(root,'results','nasa_B0005_discharge_matlab.csv'));
f=figure('Color','w','Name','NASA B0005 - rzeczywiste dane');
plot(cy,capacities,'.','MarkerSize',10,'Color',[.08,.45,.74]); hold on;
plot(cy,pred,'-','LineWidth',1.8,'Color',[.86,.35,.16]);
xline(ntrain,'--','70% uczenie / 30% test');
grid on; xlabel('Numer cyklu rozladowania');ylabel('Pojemnosc [Ah]');
title('NASA B0005: pomiary vs prosty model sqrt(N)');
legend('Pomiary NASA','Model bazowy','Podzial chronologiczny','Location','best');
try, gca.Toolbar.Visible='off';catch,end
exportgraphics(f,fullfile(root,'figures','nasa_B0005_matlab.png'),'Resolution',160);
disp(T);
fprintf('NASA: %d rzeczywistych pomiarow rozladowania. RMSE_test=%.5f Ah.\n',N,rmseTest);
end
