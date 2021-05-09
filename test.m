clear; clc
%%�����в���������ͼ�����㷨GPMVC��MIC,IMG,PVC��MKKIK,USL,�ҵ�PMLAN

addpath(genpath('measure/'));
addpath(genpath('misc/'));
addpath(genpath('PVC/'));
addpath(genpath('MIC/'));
addpath(genpath('print/'));
addpath(genpath('IMG/'));
addpath(genpath('GPMVC/'));
addpath(genpath('MKKIK/'));
addpath(genpath('USL/'));
addpath(genpath('PMLAN/'));%�����޸�PMLAN�Ĵ���
addpath(genpath('MVL-IV/'));

%��Ҫ�޸ĵ�
datasetdir='data/PMLAN/';%����λ��
resultdir='Result/PMLAN/';%��ͬʵ����Ҫ�޸Ľ��λ��
dataname={'HW-22-0.1-PMLAN'};
per=0.1;%��������pairPortion����Ҫ�޸�###
VIR=0.5;
%��Ҫ�޸�###

for id=1:length(per)
    dataf=strcat(datasetdir,dataname,'.mat');%num2str(per(id))
    datafname=cell2mat(dataf(1));
    load (datafname);    
end

%��Ҫ�޸�
numClust =length(unique(gt));%������Ŀ
%ѡ��ʵ�鷽����PMLAN,GPMVC,IMG,MIC,USL,MVL-IV
switch ('PMLAN')  %��Ҫ�޸�
%��Ҫ�޸�

case'MVL-IV'
r=[32];%NMF��r
deta=[0.5];%������lambdaÿ�����ӵ�С��   
lambdaMax=[5];%������lambda�����ֵ
gemaMin=[0.5];%�������ж���������Ҫ�޸�

options = [];
for a=1:length(r)
    for b=1:length(deta)
        for l=1:length(lambdaMax)    
            for p=1:length(gemaMin)  
        options.r=r(a);
        options.deta=deta(b);
        options.lambdaMax=lambdaMax(l);
        options.gemaMin=gemaMin(p);%�������ж���������Ҫ�޸�
        options.numClust=numClust;
        options.kmeans=10;%kmeans�ظ��Ĵ���
        options.rounds=30;%��������ߴ���
        options.error=1e-6;
        options.maxIter=30;
        options.nRepeat=30;
        options.minIter=50;
        options.meanFitRatio=0.3;     
        
        %��PO
%X:���������ݼ�������feature���������ݵ�!!!!!
m=size(X,2);% number of views 
n=size(X{1},2);
for i=1:m
    PO{i}=zeros(size(X{i},1),n);
    for j=1:length(idPaired)%idPaired;ÿ��view�¶��е����ݵ��id
        PO{i}(:,idPaired(j))=ones(size(X{i},1),1);%���ڵ����ݵ���1ָʾ
    end
    for j=1:length(idSingle{i})%idSingle;ÿ��view�µ��е����ݵ��id
        PO{i}(:,idSingle{i}(j))=ones(size(X{i},1),1);%���ڵ����ݵ���1ָʾ
    end
    X{i}=PO{i}.*X{i};%ȥ��ȱʧ�����ݵ�
end 
        
         tic;
        [result]=MVLIVclust(X,PO,gt,options);
        result2=strcat(resultdir,'MVL-IV''-',dataname,'-', 'r','-',num2str(r(a)),'-', 'deta','-',num2str(deta(b)),'lambdaMax','-',num2str(lambdaMax(l)), 'getaMin','-',num2str(gemaMin(p)),'.mat');  
        time=toc;
        save(cell2mat(result2),'result','time'); 
        fprintf('r:%d deta:%d lambdaMax:%d gemaMin:%d  Acc: %.4f  NMI: %.4f AR: %.4f F: %.4f  P: %.4f R: %.4f Purity: %.4f \n',r(a),deta(b),lambdaMax(l),gemaMin(p),result); 

            end
        end
    end
end   
                
case'MKKIK'
 %û����Ҫ���Ĳ���
 %KH���ˣ���ǰ�����ã� Y����ꣻ S���ĸ����ݵ�ȱʧ
addpath(genpath('ClusteringEvaluation/'));
addpath(genpath('lmkkmeans-master/'));

numclass = length(unique(Y));
numker = size(KH,3);
num = size(KH,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KH = kcenter(KH);
KH = knorm(KH);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
qnorm = 2;
   
        tic;
        algorithm_choose3 = 'algorithm0';
        [H_normalized,gamma,obj,KH] = myabsentmultikernelclustering(KH,S,numclass,qnorm,algorithm_choose3);
        timingcost = toc;
        res = myNMIACC(H_normalized,Y,numclass);
         fprintf('Acc: %.4f  NMI: %.4f AR: %.4f F: %.4f  P: %.4f R: %.4f Purity: %.4f\n',res); 
         result2=strcat(resultdir,'MKKIK''-',dataname,'_',num2str(per),'.mat');  
         save(cell2mat(result2),'res','timingcost'); 
      
%PMLAN
case'PMLAN'
    
tic


%��Ҫ������������k��lambda
k=[4];%���ڵĸ�����һ���С
lambda=[1e-5];
alpha=[100];
fai=0;

for i=1:length(k) 
    for j=1:length(lambda)
        for l=1:length(alpha)
        options.alpha=alpha(l);
        options.I=I;
        options.J=J;
        options.lambda=lambda(j);
        options.k=k(i);
         options.VIR=VIR;
         options.fai=fai;
        options.pairPortion=per;
        [result]=MLAN_Clustering(X,numClust,gt,options);%������,Xȱʧʹ��0���棬�����Ѿ��淶����z-score����max-min�淶��������ע��淶��ʱ��ֹ��ĸΪ0
        result2=strcat(resultdir,'PMLAN''-',dataname,'_',num2str(per),'-', 'k','_',num2str(k(i)),'-','lambda','-',num2str(lambda(j)),'.mat');  
        time=toc;
        save(cell2mat(result2),'result','time'); 
        fprintf('k:%3d lambda:%d alpha:%d  Acc: %.4f  NMI: %.4f Purity: %.4f F: %.4f  P: %.4f R: %.4f AR: %.4f\n',k(i),lambda(j),alpha(l),result); 
        end
    end
end


%GPMVC    
case 'GPMVC'
tic
views=length(Xpaired);

 for v=1:views
     Xpaired{v}=Xpaired{v};%��Ҫ����n*d������
     Xsingle{v}=Xsingle{v};
 end 
 
% Parameters for the model 
options = [];
% alpha=[1000,100,10,1,0.1,0.01,1e-3,1e-4,1e-5,1e-6];
alpha=[0.03];
for i=1:length(alpha)
options.alpha=alpha(i);  %GPMVCΨһ��Ҫ���Ĳ���alpha,�����Ĳ���Ҫ��

options.maxIter = 100;
options.error = 1e-6;
options.nRepeat = 30;
options.minIter = 50;
options.meanFitRatio = 0.3;%ԭ����0.3
options.rounds = 30;
options.WeightMode='Binary';
options.alphas=ones(1,views).*options.alpha;
option.latentdim=numClust;
options.kmeans = 30;
options.beta=10;%ԭ����10
options.gamma = 2;%ԭ����2
options.varWeight = 0;%ԭ����0
options.lamda=0.3;    %Graph Regularization parameterԭ����0.3

[U,  Paired, result,objValue] = GPMVCclust(Xpaired,Xsingle,numClust,gt,options);
time=toc;
                    
result=strcat(resultdir,dataname,'_',num2str(per),'_', num2str(options.alpha),'.mat');  
save(cell2mat(result),'U','Paired','result','objValue'); 
end
%IMG
case 'IMG'
views=length(Xpaired);
 for v=1:views
     Xpaired{v}=Xpaired{v};
     Xsingle{v}=Xsingle{v};
 end 
option.lamda=0.1;
option.gamma=0.1;
option.beta=0.3;
option.latentdim=numClust;
option.option = numClust;
option.truth = truthF;
tic
                   
[Ui1 Ui2 Pi2 Pi1 Pi3 aci Fi Pi Ri nmii avgenti ARi] = IMGclust(xpaired,ypaired,xsingle,ysingle,numClust,truthF,option);
result2=strcat(resultdir,'IMG',dataname,'_',num2str(per),'_', num2str(options.alpha),'.mat');  
time=toc;
save(cell2mat(result2),'Ui1','Ui2','Pi2','Pi1','Pi3','aci','Fi','Pi','Ri','nmii','avgenti','ARi','truthF','time'); 

case 'MIC'
    
%alpha,beta����Ҫ���Ĳ���
%Rounds����������ߴ���
%K��������
%C���Խ�ϵ������W,��Ҫ��ǰ�����

view=length(X);%X������

options = [];
options.alpha=[0.01,0.01];%����
options.beta=[10000,10000];
options.kmeans=1;%kmeans�ظ��Ĵ���
options.rounds=30;%��������ߴ���
options.error=1e-6;
options.maxIter=100;
options.nRepeat=30;
options.minIter=50;
options.meanFitRatio=0.3; 
tic

label=gt;%��ͬ���ݼ���Ҫ�޸����
K=numClust;

[result] = MultiNMF_incomplete_original_l21(X, W, K, label, options);%������

result3=strcat(resultdir,'MIC',dataname,'_',num2str(per),'_', num2str(options.alpha(1)),'_', num2str(options.beta(1)),'.mat');  
time=toc;
save(cell2mat(result3),'result','time'); 

case'USL'
%X����Ϊ�У����ݵ㣬�У�feature    

maxiter=100;
para=[0.001,0.003,0.005,0.007,0.009,0.01];
k=numClust;
options=[];
options.WeightMode = 'HeatKernel';
options.t = 1;
%learning 
for id=1:length(per)
    dataf=strcat(datasetdir,dataname,'.mat');
    datafname=cell2mat(dataf(1));
    load (datafname);
    views=length(Xpaired);
    npaired=size(Xpaired{1,1},1);
    Yc0=rand(npaired,k);
    
 % compute L
   for i=1:views
       Xpaired{i}=Xpaired{i};
       Xsingle{i}=Xsingle{i};
        Xa{i}=[Xpaired{i};Xsingle{i}];
        gnd_all{i}=[gtPaired;gtSingle{i}];
        [nsingle(i),dims(i)]=size(Xsingle{i});
        Y0{i}=rand(nsingle(i),k);
        U0{i}=rand(dims(i),k);
   end
     gamma=para(4);
     beta=para(3);
    L=computeL(Xa,gnd_all,options);
   tic
   for i=1:views
       Xpaired{i}=Xpaired{i}';
       Xsingle{i}=Xsingle{i}';
       Xa{i}=Xa{i}';
   end
    [U,Yall,obj, acc_sym] =unified_subspace(L, Xpaired, Xsingle, Xa,gamma, beta,maxiter, Yc0, Y0,U0,gt);
    time=toc;
    fmodel2=sprintf('Results/%s.mat','wiki');
save(fmodel2,'acc_sym','time','U','Yall');
end
end

       



