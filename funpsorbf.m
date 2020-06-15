function [out1,out2,out3] =fun(num)
tic;
num=num;%��Ӧ��������

InDim=1;                            %��������ά��
UnitNum=2;                          %���ڵ���
MaxEpoch=1200;                      %���ѵ������
%E0=0.2;                             %Ŀ�����
gbesthistory=[];
% ����Ŀ�꺯������������������ѵ��������
rand('state',sum(100*clock));
%NoiseVar=0.0005;
%Noise=NoiseVar*randn(1,SamNum);
data=csvread('data.csv',1,1);
%��һ��
data1=data';
data=mapminmax(data1,0,1);
data=data';

%����ѵ�������Լ�
x_train=data(:,1:5).';
y_train=data(:,5+num).';
SamIn=x_train;
SamOut=y_train;
%��������
TargetIn=x_train;
TargetOut=y_train;
SamNum=length(SamIn);                         %ѵ��������
TargetSamNum=length(SamOut);                   %����������

%����Ⱥ�㷨�е���������
c1 = 1.49445;
c2 = 1.49445;
popcount=10;   %������
poplength=6;  %����ά��
Wstart=0.9;%��ʼ����Ȩֵ
Wend=0.2;%�����������ʱ����Ȩֵ
%������ٶ������Сֵ
Vmax=1;
Vmin=-1;
popmax=4;
popmin=-4;
%����λ���ٶȺ�����ֵ��ʼ��

for i=1:popcount
    pop(i,:)=rand(1,9);%��ʼ������λ��
    V(i,:)=rand(1,9);%��ʼ�������ٶ�
    %����������Ӧ��ֵ
    Center=pop(i,1:3);
    SP=pop(i,4:6); 
    W=pop(i,7:9);
    Distance=dist(Center',SamIn);
    SPMat=repmat(SP',1,SamNum);%repmat��������
    UnitOut=radbas(Distance./SPMat);%���������
    NetOut=W*UnitOut;%�������
    Error=SamOut-NetOut;%�������
    %SSE=sumsqr(Error);
    %fitness(i)=SSE;
    RMSE=sqrt(sumsqr(Error)/SamNum);
    fitness(i)=RMSE;
    %fitness(i)=fun(pop(i,:));
end
%��Ӧ�Ⱥ�������Ӧ��ֵΪRBF��������


[bestfitness bestindex]=min(fitness);
gbest=pop(bestindex,:);%ȫ������ֵ
pbest=pop;%��������ֵ
pbestfitness=fitness;%����������Ӧ��ֵ
gbestfitness=bestfitness;%ȫ��������Ӧ��ֵ
%����Ѱ��
for i=1:MaxEpoch
   Vmax=1.00014^(-i);
   Vmin=-1.00014^(-i);
    for j=1:popcount
       % if (fitness(j)<gbestfitness|fitness==gbestfitness)
           % S(j)=0;
        %end
        %S(j)=1-(fitness(j)/100)^2;
       % GW(j)=Wstart-S(j)*(Wstart-Wend);
       % GW(j)=Wend+(GW(j)-Wend)*(MaxEpoch-i)/MaxEpoch;
        GW=Wstart-(Wstart-Wend)*i/MaxEpoch;
        %�ٶȸ���(��һ�ַ����������)
        V(j,:) = 1.000009^(-i)*(gbestfitness/fitness(j)+2)*rand*V(j,:) + c1*rand*(pbest(j,:) - pop(j,:)) + c2*rand*(gbest - pop(j,:));
        %V(j,:) = GW*((fitness(j)/2000)^2+1)*rand*V(j,:) + c1*rand*(pbest(j,:) - pop(j,:)) + c2*rand*(gbest - pop(j,:));
        %V(j,:) = GW*V(j,:) + c1*rand*(pbest(j,:) - pop(j,:)) + c2*rand*(gbest - pop(j,:));
        %V(j,:) = 0.9*V(j   ,:) + c1*rand*(pbest(j,:) - pop(j,:)) + c2*rand*(gbest - pop(j,:));
        %V(j,:) = 0.9*1.0003^(-j)* V(j,:) + c1*rand*(pbest(j,:) - pop(j,:)) + c2*rand*(gbest - pop(j,:));
        %V(j,:) = (gbestfitness/(exp(-fitness(j))+1)+0.5)*rand*V(j,:) + c1*rand*(pbest(j,:) - pop(j,:)) + c2*rand*(gbest - pop(j,:));
        V(j,find(V(j,:)>Vmax))=Vmax;
        V(j,find(V(j,:)<Vmin))=Vmin;
        
        %���Ӹ���
        pop(j,:)=pop(j,:)+0.5*V(j,:);
        pop(j,find(pop(j,:)>popmax))=popmax;
        pop(j,find(pop(j,:)<popmin))=popmin;
        %����������Ӧ��ֵ
        Center=pop(j,1:3);
        SP=pop(j,4:6); 
        W=pop(j,7:9);
        Distance=dist(Center',SamIn);
        SPMat=repmat(SP',1,SamNum);%repmat��������
        UnitOut=radbas(Distance./SPMat);
        NetOut=W*UnitOut;%�������
        Error=SamOut-NetOut;%�������
        %SSE=sumsqr(Error);
        %fitness(j)=SSE;
        RMSE=(sumsqr(Error)/SamNum);
        fitness(j)=RMSE;
       % Center=pop(j,1:10);
       % SP=pop(j,11:20);
       % W=pop(j,21:30);
       % fitness(j)=fun(pop(j,:));
    end
    for j=1:popcount
        
        %�������Ÿ���
        if fitness(j) < pbestfitness(j)
            pbest(j,:) = pop(j,:);
            pbestfitness(j) = fitness(j); 
        end
        
        %Ⱥ�����Ÿ���
        if fitness(j) < gbestfitness
            gbest = pop(j,:);
            gbestfitness = fitness(j);
        end
    end
    gbesthistory=[gbesthistory,gbest];
    %mse(i)=gbestfitness;
    %��Ⱥ������ֵ����RBF����
    Center=gbest(1,1:3);
    SP=gbest(1,4:6); 
    W=gbest(1,7:9);
    %Center=gbest(1,1:5);
    %SP=gbest(1,11:20); 
    % W=gbest(1,21:30);
     Distance=dist(Center',SamIn);
     SPMat=repmat(SP',1,SamNum);%repmat��������
     UnitOut=radbas(Distance./SPMat);
     NetOut=W*UnitOut;%�������
     Error=SamOut-NetOut;%�������
     %sse(i)=sumsqr(Error);
     mse(i)=(sumsqr(Error)/SamNum);
   % sse(i)=fun(gbest);
   %if sse(i)<E0,break,end 
end
toc;
% ���� 
Center=gbest(1,1:3);
SP=gbest(1,4:6); 
W=gbest(1,7:9);
TestDistance=dist(Center',TargetIn);
TesatSpreadsMat=repmat(SP',1,TargetSamNum);
TestHiddenUnitOut=radbas(TestDistance./TesatSpreadsMat);
TestNNOut=W*TestHiddenUnitOut;

%������ ѵ�����Ͳ��Լ�
err=SamOut-NetOut;
train_error=(err.*err)/length(SamOut);

%  ����ѧϰ�������
mse=mse;

out1=NetOut;
out2=train_error;
out3=mse;
end