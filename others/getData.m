% load('HWfold.mat');
% load('HWMean.mat');
% load('UCI_handwritten_digit.mat');
% s=X;

a=[4,3;5,6];b=[3,4;7,8];
num=2;
for i=1:num
    for j=1:num
        d(i,j)=sum(a(i,:).*b(j,:))/(norm(a(i,:))*norm(b(j,:)));
    end
end
d=1-d;%d:�������ƶȣ�1-d�������
d =normalize(d,1);%������淶�����ɳ��Զ��ֹ淶������