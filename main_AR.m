clear
clc
close all

%�������ݼ���Ӧ��ѵ����������
load('randomfaces4ar.mat');
load('Tr_ind_AR.mat')

experiments = size(Tr_ind,1);%�ظ�10��ʵ��
acc = zeros(1,experiments);%����ÿ�ε�׼ȷ��

ClassNum = length(unique(gnd));%�����
%��������
params.model_type = 'ProCRC';
params.gamma = 1e-3;
params.lambda = 1e-2;
sparsity = 50;

for ii=1:experiments
    ii
    %ѵ���Ͳ�����������
    train_ind = logical(Tr_ind(ii,:));
    test_ind = ~train_ind;
    
    %ѵ���Ͳ���������Ӧ�����ݺͱ�ǩ
    training_feats = fea(:,train_ind);
    testing_feats = fea(:,test_ind);
    train_label = gnd(:,train_ind);
    test_label = gnd(:,test_ind);
    
    %ѵ��������ǩ����
    H_train = full(ind2vec(train_label,ClassNum));
    
    %��λ��
    train = normc(training_feats);
    Y = normc(testing_feats);
    
    Phi = train;
    
    %ProCRC��������
    fr_dat_split = [];
    fr_dat_split.tr_descr = train;
    fr_dat_split.tr_label = vec2ind(H_train);
    fr_dat_split.tt_descr = testing_feats;
    fr_dat_split.tt_label = test_label;
    
    params.class_num = size(H_train,1);
    
    %ProCRC�õ��ı�ʾϵ������
    A_check = ProCRC(fr_dat_split, params);
    
    %SRC�õ��ı�ʾϵ������
    G = Phi'*Phi;
    A_hat = omp(Phi'*Y,G,sparsity);
    
    %��ǿ�ı�ʾϵ��
    A_aug = normc(A_check + A_hat);
    
    %���ಢ�õ�׼ȷ��
    Score = H_train * A_aug;
    [~,pre_label] = max(Score);
    acc(ii) = sum(pre_label==test_label)/length(test_label)*100
end
%10��ʵ��׼ȷ�ʵľ�ֵ�ͱ�׼��
mean(acc)
std(acc)