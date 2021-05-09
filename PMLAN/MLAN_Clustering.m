function [result]= MLAN_Clustering(X,c,groundtruth,options)
% X:                cell array, 1 by view_num, each array is num by d_v
% c:                number of clusters
% v:                number of views
% k:                number of adaptive neighbours
%lambda             ����
%alpha              S�Ĳ���
%beta��             ȱʧ��Ĳ���
%groundtruth��      groundtruth of the data, num by 1
%pairPortion        ��������

I=options.I;
J=options.J;
lambda=options.lambda;
k=options.k;
alpha=options.alpha;
pairPortion=options.pairPortion;
fai=options.fai;
VIR=options.VIR;
v= size(X,2);
num = size(X{1},1);
NITER = 30;%��������ߴ���
pairedNum=floor(num*pairPortion);%���еĸ���
singledNum=ceil((num-pairedNum)*VIR);%���еĸ���
% c1=repmat((pairedNum+singledNum)/num,num,1);
c1=ones(num,1);%��ʼʱȱʧ֮�͵���1
% c2=repmat((1-(pairedNum+singledNum)/num),num,1);
c2=ones(num,1);%��ʼʱȱʧ֮�͵���1
%% =====================  Initialization =====================
% for i = 1 :v
%     for  j = 1:num
%         X{i}(j,:) = ( X{i}(j,:) - mean( X{i}(j,:) ) ) / (std( X{i}(j,:) )+eps) ;%eps��ֹ��ĸΪ0
%     end
% end
%initialize weighted_distX
SUM = zeros(num);
%   d= I{3}.* L2_distance_1( X{3}',X{3}' );   %���ڲ��Ը�ֵ
%    for  j = 1:size(d,1)
%                  d(j,:) = (d(j,:) - min( d(j,:) ) ) / (max( d(j,:) )-min( d(j,:) )+eps) ;%eps��ֹ��ĸΪ0
%    end
for i = 1:v
    %%�˴���Ҫ����view�������ͣ��ֶ�ѡ�������뷽����L2_distance_1��ŷʽ���룬L2_distance_1�����Ҿ��룬���ѹ淶��
%       if i==1
          d= I{i}.* L2_distance_1( X{i}',X{i}' );%ͼƬʹ��ŷʽ����L1������ʹ�����Ҿ���L2������BDGP���ݣ�����2      
%      else
%           d= I{i}.* L2_distance_2( X{i}',X{i}' );
%       end
      for  j = 1:size(d,1)
                 d(j,:) = (d(j,:) - min( d(j,:) ) ) / (max( d(j,:) )-min( d(j,:) )+eps) ;%eps��ֹ��ĸΪ0
      end
%          for  j = 1:size(d,1)
%                  d(j,:) = (d(j,:) - mean( d(j,:) ) ) / (std( d(j,:)) +eps) ;%eps��ֹ��ĸΪ0
%          end
      distX_initial(:,:,i)=d;
    SUM = SUM + distX_initial(:,:,i);
end

% SUM=fullSUM(SUM,pairedNum,singledNum,num,v);%��ʼ����ȫ����
distX=(1/v)*J.*SUM;
[distXs, idx] = sort(distX,2);

%initialize S
S = zeros(num);
rr = zeros(num,1);
for i = 1:pairedNum
    di = distXs(i,2:k+2);
     rr(i) = 0.5*(k*di(k+1)-sum(di(1:k)));
    id = idx(i,2:k+2);
    S(i,id) = (di(k+1)-di)/(k*di(k+1)-sum(di(1:k))+eps); %initialize S�����õ�k+1���ľ�����þ���֮�����k��k+1�ľ�����ǰk������֮�ͣ�eps�Ƿ�ֹΪ0
end;
% for i = pairedNum+1:num
%         b=num-singledNum-pairedNum+2; 
%         di = distXs(i,b:k+b);
%         rr(i) = 0.5*(k*di(k+1)-sum(di(1:k)));
%         id = idx(i,b:k+b);
%         S(i,id) = (di(k+1)-di)/(k*di(k+1)-sum(di(1:k))+eps);
% end
for i = pairedNum+1:pairedNum+singledNum
        b=num-singledNum-pairedNum+2; 
        di = distXs(i,b:k+b);
        rr(i) = 0.5*(k*di(k+1)-sum(di(1:k)));
        id = idx(i,b:k+b);
        S(i,id) = (di(k+1)-di)/(k*di(k+1)-sum(di(1:k))+eps);
end
for i = pairedNum+singledNum+1:num
        b=singledNum+2; 
        di = distXs(i,b:k+b);
        rr(i) = 0.5*(k*di(k+1)-sum(di(1:k)));
        id = idx(i,b:k+b);
        S(i,id) = (di(k+1)-di)/(k*di(k+1)-sum(di(1:k))+eps);
end
beta = mean(rr);%��ʼ��beta

% initialize F
S = (S+S')/2;                                                        
D = diag(sum(S));
L = D - S;
[F, temp, evs]=eig1(L, c, 0);

if sum(evs(1:c+1)) < 0.00000000001
    error('The original graph has more than %d connected component', c);
end;
p=1;

%% =====================  updating =====================
for iter = 1:NITER
    % update weighted_distX
    SUM = zeros(num,num);
    for i = 1 : v
        if iter ==1  
            distX_updated = distX_initial;
        end
             Wv(i) = (0.5*p)/(sum(sum(I{i}.* distX_updated(:,:,i).*S))+eps)^((2-p)/2); %����ϵ��
        distX_updated(:,:,i) =Wv(i)*distX_updated(:,:,i) ;
        SUM = SUM + distX_updated(:,:,i);
    end
    distX = J.*SUM;
    [distXs, idx] = sort(distX,2);
    
    %update S
    %update S������ͼ��Ϣ����,����һ����
    distf = L2_distance_1(F',F');
    S = zeros(num);
    
      for i = 1:pairedNum
        a=2;     
        idxa0 = idx(i,a:a+k-1);
        dfi = distf(i,idxa0);
        dxi = distX(i,idxa0);
        ad = -(dxi+lambda*dfi)/(2*beta);
        S(i,idxa0) = EProjSimplex_new(ad);   
      end
%       for i = pairedNum+1:num
%         b=num-singledNum-pairedNum+2; 
%         idxa0 = idx(i,b:b+k-1);
%         dfi = distf(i,idxa0);
%         dxi = distX(i,idxa0);
%         ad = -(dxi+lambda*dfi)/(2*beta);
%         S(i,idxa0) = EProjSimplex_new(ad,c1(i));
%         c22(i)=1-sum(S(i,idxa0));
%        end
       for i = pairedNum+1:pairedNum+singledNum
        b=num-singledNum-pairedNum+2; 
        idxa0 = idx(i,b:b+k-1);
        dfi = distf(i,idxa0);
        dxi = distX(i,idxa0);
        ad = -(dxi+lambda*dfi)/(2*beta);
        S(i,idxa0) = EProjSimplex_new(ad,c1(i));
        c22(i)=1-sum(S(i,idxa0));
       end
       for i = pairedNum+singledNum+1:num
        b=singledNum+2; 
        idxa0 = idx(i,b:b+k-1);
        dfi = distf(i,idxa0);
        dxi = distX(i,idxa0);
        ad = -(dxi+lambda*dfi)/(2*beta);
        S(i,idxa0) = EProjSimplex_new(ad,c1(i));
        c22(i)=1-sum(S(i,idxa0));
       end
%        
% %      update S ������ͼ��Ϣȱʧ�����ȱʧ�����ƶ�
         h = fullLack(S,pairedNum,singledNum,num,v);%���õõ������ƶȼ���ȱʧ�����ƶ�

         for i=pairedNum+1:num
             sumS=0;
             for j=1:num
                 if h(i,j)~=0
                     S(i,j)=(fai-((lambda*distf(i,j)-2*alpha*h(i,j)))/(2*(alpha+beta)));
                     S(i,j);
                     sumS=sumS+S(i,j);
                 end                 
             end
             c1(i)=1-sumS;
         end
%         save('D:\���״���\S','S');
    %update F
    S = (S+S')/2;                                                      
    D = diag(sum(S));
    L = D-S;
    F_old = F;
    [F, temp, ev]=eig1(L, c, 0);
    evs(:,iter+1) = ev;
    
    %������ͼ
%     A=distX.*S;
    %obj(iter)=trace(F'*L*F);
%     obj(iter)=sum(A(:))+beta*norm(S,'fro')+2*lambda*trace(F'*L*F);
    
    %update lambda  �����з���
%     thre = 1*10^-10;
%     fn1 = sum(ev(1:c));                                                
%     fn2 = sum(ev(1:c+1));
%     if fn1 > thre
%         lambda = 2*lambda;   %��ʼ��2
%     elseif fn2 < thre
%         lambda = lambda/2;  F = F_old;
%     else
%         break;
%     end;
%  lambda
%  iter
     %update lambda  ʵ�����Ľ��ķ���
    [clusternum, y]=graphconncomp(sparse(S)); 
     if clusternum > c
        lambda = lambda/2;F = F_old;
    elseif clusternum < c
        lambda = 2*lambda; 
     else
        break;
    end;
% % lambda   
% % iter
   %sprintf('iter = %d',iter);
%    [clusternum, y]=graphconncomp(sparse(S)); y = y';
% 
%     result = ClusteringMeasure(groundtruth, y);
%     nmi=result(2)
%     obj2(iter)=nmi;
end
%% =====================  result =====================
% plot(obj);
[clusternum, y]=graphconncomp(sparse(S)); y = y';%һ�־����㷨�����㷨����k-means
if clusternum ~= c
    sprintf('Can not find the correct cluster number: %d', c)
end;
result= ClusteringMeasure(groundtruth, y);