import cv2
import os
import re

# Each video has a frame per second which is number of frames in every second
frame_per_second = 1
DURATION = 1

# files_and_duration = [
#     ('../tennis_ball_frames/Tennis_edit_1.png', DURATION),
#     ('../tennis_ball_frames/Tennis_edit_2.png', DURATION),
#     ('../tennis_ball_frames/Tennis_edit_3.png', DURATION),
#     ('../tennis_ball_frames/Tennis_edit_4.png', DURATION),
#     ('../tennis_ball_frames/Tennis_edit_5.png', DURATION),
#     ('../tennis_ball_frames/Tennis_edit_6.png', DURATION),
#     ('../tennis_ball_frames/Tennis_edit_7.png', DURATION),
#     ('../tennis_ball_frames/Tennis_edit_8.png', DURATION),
#     ('../tennis_ball_frames/Tennis_edit_9.png', DURATION),
#     ('../tennis_ball_frames/Tennis_edit_10.png', DURATION)
# ]
#
# files_and_duration = [
#     ('../tennis_ball_frames/current_1.png', DURATION),
#     ('../tennis_ball_frames/current_2.png', DURATION),
#     ('../tennis_ball_frames/current_3.png', DURATION),
#     ('../tennis_ball_frames/current_4.png', DURATION),
#     ('../tennis_ball_frames/current_5.png', DURATION),
#     ('../tennis_ball_frames/current_6.png', DURATION),
#     ('../tennis_ball_frames/current_7.png', DURATION),
#     ('../tennis_ball_frames/current_8.png', DURATION),
#     ('../tennis_ball_frames/current_9.png', DURATION),
#     ('../tennis_ball_frames/current_10.png', DURATION)
# ]

# Get all files from a given directory
directory = '../tennis_ball_frames/'
all_files = os.listdir(directory)
image_files = [file for file in all_files if (file.endswith(('.png', '.jpg', '.jpeg', '.gif')) and "edit" not in file)]
# extracting frame number for correct sorting:
def extract_number(filename):
    match = re.search(r'(\d+)', filename)
    return int(match.group(1)) if match else float('inf')

# Sort the image files based on the numerical part of the filenames
image_files.sort(key=extract_number)
files_and_duration = [(os.path.join(directory, file), DURATION) for file in image_files]
print(files_and_duration)


w, h = None, None
for file, duration in files_and_duration:
    frame = cv2.imread(file)

    if w is None:
        # Setting up the video writer
        h, w, _ = frame.shape
        fourcc = cv2.VideoWriter_fourcc('m', 'p', '4', 'v')
        writer = cv2.VideoWriter('outputRGB.mp4', fourcc, frame_per_second, (w, h))

    # Repating the frame to fill the duration
    for repeat in range(duration * frame_per_second):
        writer.write(frame)

writer.release()
