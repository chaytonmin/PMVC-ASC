function X =normalize(X)
%%�淶����ʽ
%%����һ������ת��Ϊ��0Ϊ��ֵ�����������и���
%%������������ת������0,1��֮��
% %�淶����ʽһ��z-score
parfor i = 1 :v
    for  j = 1:num
        X{i}(j,:) = ( X{i}(j,:) - mean( X{i}(j,:) ) ) / (std( X{i}(j,:) )+eps) ;%eps��ֹ��ĸΪ0
    end
end
% %�淶����ʽ����max-min
% parfor i = 1 :v
%     for  j = 1:num
%         X{i}(j,:) = ( X{i}(j,:) - min( X{i}(j,:) ) ) / (max( X{i}(j,:) )-min( X{i}(j,:) )+eps) ;%eps��ֹ��ĸΪ0
%     end
% end