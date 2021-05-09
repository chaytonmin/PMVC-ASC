% compute ���Ҿ���

function d = L2_distance_2(a,b)
% a,b: two matrices. each column is a data
% d:   distance matrix of a and b

a=a';b=b';%��Ҫת�ó�n*d��ʽ
num=size(a,1);
d=zeros(num,num);
parfor i=1:num
    for j=1:num
        d(i,j)=sum(a(i,:).*b(j,:))/((norm(a(i,:))*norm(b(j,:)))+eps);
    end
end
d=1-d;%
d = real(d);
%������淶�����ɳ��Զ��ֹ淶������
    for  i = 1:num
        d(i,:) = (d(i,:) - min( d(i,:) ) ) / (max( d(i,:) )-min( d(i,:) )+eps) ;%eps��ֹ��ĸΪ0
    end