clear all;

% Generate a video clip using the processed pictures

WriterObj=VideoWriter('output_0704.avi');
% 'video_file.avi'��ʾ���ϳɵ���Ƶ����������avi��ʽ�����ļ�·��
WriterObj.FrameRate = 15; % FrameRateѡ��֡��
WriterObj.Quality = 100;  % Qualityѡ����Ƶ����

open(WriterObj);
img_file_dir = 'output_0704\'; % img_file_dirѡ��֡ͼƬ���·��
Readlist.Img_file = dir(fullfile(img_file_dir,'*.jpg'));
for i = 1:length(Readlist.Img_file)
    img_file = [img_file_dir, Readlist.Img_file(i).name];
    im = imread(img_file);
    writeVideo(WriterObj, im);
end
close(WriterObj);