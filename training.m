%% Database Processing
function training()
    fprintf('Please select training data set: \n');
    x = input('Select training data set => ','s');
    if strcmp(x, 'UIUC') == 1
        model.svm = UIUC_train();
        save svmModel model
    elseif strcmp(x, 'IMAGENET') == 1
        model.svm = IMAGENET_train();
        save svmModel model
    elseif strcmp(x, 'CASE') == 1
        model.svm = CASE_train();
        save svmModel model
    else
        fprintf('Invalid input! \n');
    end
end

%% UIUC database processing
function svm = UIUC_train()
    img_file_dir = 'pictures\UIUC\101_ObjectCategories\car_side\';
    ann_file_dir = 'pictures\UIUC\Annotations\car_side\';
    Readlist.Img_file = dir(fullfile(img_file_dir,'*.jpg'));
    Readlist.Ann_file = dir(fullfile(ann_file_dir,'*.mat'));
    model.label = [];
    model.insc = [];

    for i = 1:length(Readlist.Img_file)
        img_file = [img_file_dir, Readlist.Img_file(i).name];
        ann_file = [ann_file_dir, Readlist.Ann_file(i).name];
        % ��UIUC�����ݿ���Ҫ����ͨ��annotation.m�ű������߿�����
        contour = show_annotation(img_file, ann_file);       
        % ��ÿһ��ͼƬ��ת���ɵ��ֽڸ�ʽ�ڰ�ͼƬ�ĸ�ʽ
        im = imread(img_file);
        try
            img_single = im2single(rgb2gray(im));
        catch
            img_single = im2single(im);
        end
        img_car = img_single(contour(1):contour(2), contour(3):contour(4));
        img_single(contour(1):contour(2), contour(3):contour(4)) = 0;
        % ��������������һ������׼��С������ѡ��64x64
        car.img = imresize(img_car, [64, 64]);
        bac.img = imresize(img_single, [64, 64]);
        % ͨ��vl_hog()����������ݶȷֲ�ֱ��ͼ
        % �����������8��ʾ��8x8Ϊ��Ԫ�����
        car.hog = vl_hog(car.img, 8);
        bac.hog = vl_hog(bac.img, 8);
        hog_sz = size(car.hog);
        
        % ͨ��svm_hog()���������������������HOG���ʽ���ʺ�svmtrain()����
        % car sample input
        [model.label, model.insc] = svm_hog(car.hog, hog_sz, model.label, model.insc, 1);
        % background sample input
        [model.label, model.insc] = svm_hog(bac.hog, hog_sz, model.label, model.insc, -1);
    end
    
    % svmtrain()Ҫ������Ϊdouble���ͣ�����ͨ��double()�������и�ʽת��
    model.label = double(model.label);
    model.insc = double(model.insc);
    % ͨ���Ѿ��õ��İ�����������������HOG���ݾ�����svmtrain()��������svmֵ
    model.svm = svmtrain(model.label, model.insc, '-s 0 -t 0');
    svm = model.svm;
end 

%% IMAGENET database processing
function svm = IMAGENET_train()
    %training with IMAGENET database and output the parameters
    % van_file_dir = 'pictures\IMAGENET\van\';
    vehicle_file_dir = 'pictures\IMAGENET\vehicle_0522\';
    negative_file_dir = 'pictures\NEGATIVE\0524\';
    % Readlist.Van_file = dir(fullfile(van_file_dir,'*.JPEG'));
    Readlist.Vehicle_file = dir(fullfile(vehicle_file_dir,'*.JPEG'));
    Readlist.Negative_file = dir(fullfile(negative_file_dir,'*.jpg'));

    model.label = [];
    model.insc = [];

    % 'IMAGENET'���ݿ⣬���������������
    for i = 1:length(Readlist.Vehicle_file)
        img_file = [vehicle_file_dir, Readlist.Vehicle_file(i).name];
        
        im = imread(img_file);
        try
            img_single = im2single(rgb2gray(im));
        catch
            img_single = im2single(im);
        end
        img_car = img_single;
        car.img = imresize(img_car, [64, 64]);
        
        car.hog = vl_hog(car.img, 8);
        hog_sz = size(car.hog);
%         sample_num = hog_sz(1) * hog_sz(2);
        
        %% car sample input
        [model.label, model.insc] = svm_hog(car.hog, hog_sz, model.label, model.insc, 1);
    end
    
    % for i = 1:length(Readlist.Van_file)
    %     img_file = [van_file_dir, Readlist.Van_file(i).name];
    %     
    %     im = imread(img_file);
    %     try
    %         img_single = im2single(rgb2gray(im));
    %     catch
    %         img_single = im2single(im);
    %     end
    %     img_car = img_single;
    %     car.img = imresize(img_car, [64, 64]);
    %     
    %     car.hog = vl_hog(car.img, 8);
    %     hog_sz = size(car.hog);
    %     sample_num = hog_sz(1) * hog_sz(2);
    %     
    %     %% car sample input
    %     model.label = [model.label; 1];
    %     car.insc = [];
    %     for sp_num = 1:sample_num
    %         for hog_num = 1:hog_sz(3)
    %             col = ceil(sp_num / hog_sz(1));
    %             row = sp_num - (col - 1) * hog_sz(1);
    %             car.insc = [car.insc, car.hog(row, col, hog_num)];
    %         end
    %     end
    %     model.insc = [model.insc; car.insc];
    % end

    % ��������Ӹ�����
    for i = 1:length(Readlist.Negative_file)
        img_file = [negative_file_dir, Readlist.Negative_file(i).name];
        
        im = imread(img_file);
        try
            img_single = im2single(rgb2gray(im));
        catch
            img_single = im2single(im);
        end
        img_car = img_single;
        car.img = imresize(img_car, [64, 64]);
        
        car.hog = vl_hog(car.img, 8);
        hog_sz = size(car.hog);
%         sample_num = hog_sz(1) * hog_sz(2);
        
        %% car sample input
        [model.label, model.insc] = svm_hog(car.hog, hog_sz, model.label, model.insc, -1);
    end

    model.label = double(model.label);
    model.insc = double(model.insc);
    %input the label and hog��then output the parameters
    model.svm = svmtrain(model.label, model.insc, '-s 0 -t 0');
    svm = model.svm;
end

%% transformng label into proper format
function [label, insc] = svm_hog(hog, hog_sz, label, insc, x)
  %adjust the format of label and calculate insc
    sample_num = hog_sz(1) * hog_sz(2);
    % ������Ϊ1��������Ϊ-1
    label = [label; x];
    img.insc = [];
    % �����еķ�ʽ�����ҡ����ϵ��½�HOG���������һ�У���ӵ��ܵ�HOG���ݾ���
    for sp_num = 1:sample_num
        for hog_num = 1:hog_sz(3)
            col = ceil(sp_num / hog_sz(1));
            row = sp_num - (col - 1) * hog_sz(1);
            img.insc = [img.insc, hog(row, col, hog_num)];
        end
    end
    insc = [insc; img.insc];
end

%% User-given database traing
function svm = CASE_train()
    c1_file_dir = 'pictures\train_case\answer1\';
    c2_file_dir = 'pictures\train_case\answer2\';
    negative_file_dir = 'pictures\NEGATIVE\';

    Readlist.c1_file = dir(fullfile(c1_file_dir,'*.jpg'));
    Readlist.c2_file = dir(fullfile(c2_file_dir,'*.jpg'));
    Readlist.Negative_file = dir(fullfile(negative_file_dir,'*.jpg'));

    model.label = [];
    model.insc = [];

    for i = 1:length(Readlist.c1_file)
        img_file = [c1_file_dir, Readlist.c1_file(i).name];
        
        im = imread(img_file);
        try
            img_single = im2single(rgb2gray(im));
        catch
            img_single = im2single(im);
        end
        img_car = img_single;
        car.img = imresize(img_car, [64, 64]);
        
        car.hog = vl_hog(car.img, 8);
        hog_sz = size(car.hog);
        
        %% car sample input
        [model.label, model.insc] = svm_hog(car.hog, hog_sz, model.label, model.insc, 1);
    end

    for i = 1:length(Readlist.Negative_file)
        img_file = [negative_file_dir, Readlist.Negative_file(i).name];
        
        im = imread(img_file);
        try
            img_single = im2single(rgb2gray(im));
        catch
            img_single = im2single(im);
        end
        img_car = img_single;
        car.img = imresize(img_car, [64, 64]);
        
        car.hog = vl_hog(car.img, 8);
        hog_sz = size(car.hog);
        
        %% car sample input
        [model.label, model.insc] = svm_hog(car.hog, hog_sz, model.label, model.insc, -1);
    end

    model.label = double(model.label);
    model.insc = double(model.insc);
    %input the label and hog��then output the parameters
    model.svm = svmtrain(model.label, model.insc, '-s 0 -t 0');
    svm = model.svm;

    % ��������ڶ������������������������������
    model.label = [];
    model.insc = [];

    for i = 1:length(Readlist.c2_file)
        img_file = [c2_file_dir, Readlist.c2_file(i).name];
        
        im = imread(img_file);
        try
            img_single = im2single(rgb2gray(im));
        catch
            img_single = im2single(im);
        end
        img_car = img_single;
        car.img = imresize(img_car, [64, 64]);
        
        car.hog = vl_hog(car.img, 8);
        hog_sz = size(car.hog);
%         sample_num = hog_sz(1) * hog_sz(2);
        
        %% car sample input
        [model.label, model.insc] = svm_hog(car.hog, hog_sz, model.label, model.insc, 1);
    end

    for i = 1:length(Readlist.Negative_file)
        img_file = [negative_file_dir, Readlist.Negative_file(i).name];
        
        im = imread(img_file);
        try
            img_single = im2single(rgb2gray(im));
        catch
            img_single = im2single(im);
        end
        img_car = img_single;
        car.img = imresize(img_car, [64, 64]);
        
        car.hog = vl_hog(car.img, 8);
        hog_sz = size(car.hog);
%         sample_num = hog_sz(1) * hog_sz(2);
        
        %% car sample input
        [model.label, model.insc] = svm_hog(car.hog, hog_sz, model.label, model.insc, -1);
    end

    model.label = double(model.label);
    model.insc = double(model.insc);
    %input the label and hog��then output the parameters
    model.svm = svmtrain(model.label, model.insc, '-s 0 -t 0');
    % ������ѵ�����Ĳ�ͬ��svmֵ�����ͬһ�����飨1xN����
    svm = [svm, model.svm];
end