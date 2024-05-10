video = VideoReader('videoplayback.mp4');

%% After reading the video - we can read the frames

frames = [];
for i=1:10
    current_frame = read(video,170 + i*6);
    frames = [frames, current_frame];
    % figure;
    string = "current_" + i + ".png";
    imwrite(current_frame, string);
end

