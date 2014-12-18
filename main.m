function main()
% Turn off warnings
warning('off', 'all');

%fil = ls('../../newvideos/vid2');
framesSet = '../frames_set/vid2/';
framesExt = '*.jpg';
outputFramesDirectory = 'test';
if exist(outputFramesDirectory) == 0
	mkdir(outputFramesDirectory);
end
fil = dir(fullfile(framesSet, framesExt));
[n,m] = size(fil);
idealFret = -1;
strings = [11/12 3/4 7/12 5/12 1/4 1/12];

%outFrets = [1674, 1548, 1428, 1317, 1210, 1111, 1018, 930, 845, 764, 690, 619, 522, 489, 430, 375, 322, 271, 225, 180, 138, 99, 60, 25];
outFrets = [1745, 1611, 1488, 1373, 1264, 1161, 1065, 974, 888, 805, 750, 640, 590, 506, 460, 403, 349, 297, 248, 203, 159, 119, 80, 43];
outStrings = [165, 138, 110, 83, 56, 27];
outputFretboard = imread('outputFretboardClean.png');

writeFlag = 1;
showFlag = 0;
maskSet = 0;
for i = 5:20
    origFrame = imread(fullfile(framesSet, fil(i).name));
	segImg = segment(origFrame);
    if maskSet == 0
        idealMask = uint8(zeros(size(segImg)));
        maskSet = 1;
    end
	img = imread(fullfile(framesSet, fil(i).name));
    [p,flag, fCount] = newskel(segImg);
    fCount
    if fCount > 20
        [bwp, labels] = bwlabel(p);
        fret1 = (bwp == labels);
        fret2 = (bwp == labels - 1);
        indFret1 = find(fret1 == 1);
        [x1, y1] = ind2sub(size(bwp), indFret1);
        indFret2 = find(fret2 == 1);
        [x2, y2] = ind2sub(size(bwp), indFret2);
        toExtend = floor(mean(y1(:)) - mean(y2(:)));
        Bw = bwconvhull(p);
        Bw(min(x1(:)):max(x1(:)), floor(mean(y1(:))):floor(mean(y1(:)))+toExtend) = 1;
        idealMask = idealMask | Bw;
        idealp = p;
        maskSet = 1;
        break;
    end
end
%figure, imshow(idealMask);
%figure, imshow(idealp);
[bwp, plabels] = bwlabel(idealp);
fprintf('Number of plabels: %d\n', plabels);


for i = 5:50
	origFrame = imread(fullfile(framesSet, fil(i).name));
	segImg = segment(origFrame);
   % imwrite(segImg,'segmented.jpg');
	img = imread(fullfile(framesSet, fil(i).name));
    img = imrotate(img,-12);
   % imwrite(img,'Original.jpg');
	%figure,imshow('segmented.jpg');
	[p,flag, fCount] = newskel(segImg);
    %imwrite(p,'skeleton.jpg');
	if showFlag == 1
		fprintf('number of frets, fCount = %d\n', fCount);
	end

%	fprintf('size(segImg) = %d %d\n', size(segImg, 1), size(segImg, 2));
	%[out, theta] = getFrets(segImg);

	%figure,imshow(p);
	%[n,m]  = size(im(:,:,1));
	kernel = uint8(zeros(15,15));
	kernel(8,8) = 1;
%	im = zeros(size(img, 1), size(img, 2), size(img, 3));
	im(:,:,1) = uint8(conv2(img(:,:,1),kernel));
	im(:,:,2) = uint8(conv2(img(:,:,2),kernel));
	im(:,:,3) = uint8(conv2(img(:,:,3),kernel));
%	im = img;
	if showFlag == 1
%		figure,imshow(im);
%		figure,imshow(imresize(p,[n,m]));
	end
	r = im(:,:,1);
	g = im(:,:,2);  
	b = im(:,:,3);
	Bw = bwconvhull(p);
	[bwp, labels] = bwlabel(p);
	fret1 = (bwp == labels);
	fret2 = (bwp == labels - 1);
	indFret1 = find(fret1 == 1);
	[x1, y1] = ind2sub(size(bwp), indFret1);
	indFret2 = find(fret2 == 1);
	[x2, y2] = ind2sub(size(bwp), indFret2);
	toExtend = floor(mean(y1(:)) - mean(y2(:)));
	Bw(min(x1(:)):max(x1(:)), floor(mean(y1(:))):floor(mean(y1(:)))+toExtend) = 1;

    %nmask = uint8(zeros(size(im)));
    %nmask(:,:,1) = uint8(Bw);
    %nmask(:,:,2) = nmask(:,:,1);
    %nmask(:,:,3) = nmask(:,:,1);
	%newSegImg = segment(nmask.*im);
	%[pNew, flag, fCount] = newskel(newSegImg);
	if showFlag == 1
		%fprintf('fCountNew = %d\n', fCountNew);
	end
%	if fCount == 24
%		idealFret = i;
		%idealMask = Bw;
	if fCount ~= 24
		%fprintf('Using ideal mask now\n');
		Bw = idealMask;
        p = idealp;
	end

	r = uint8(Bw) .* r;
	g = uint8(Bw) .* g;
	b = uint8(Bw) .* b;
	im(:,:,1) = r;
	im(:,:,2) = g;
	im(:,:,3) = b;
    %figure,imshow(im);
    imwrite(im,strcat('output/',num2str(i),'.jpg'));
%    imwrite(im,'output.jpg');
	if flag==1
		imwrite(im,'crop.jpg');
    end
    ycbcr = rgb2ycbcr(im);
    ind = find(ycbcr(:,:,1) > 70 & ycbcr(:,:,3) > 145 & ycbcr(:,:,3) < 180);
    t = ycbcr(:,:,1);
    t(:,:) = 0;
    t(ind) = 255;
    %figure,subplot(1,3,1),imshow(im);
    %subplot(1,3,2),imshow(t);
    linese = strel('line',50,0);
    falsefing = imopen(t,linese);
    t = t - falsefing;
    %imwrite(t,'fingerafter.jpg');
	[bwt, tlabels] = bwlabel(t);
    maxx = 0;
    for lab = 1:tlabels
        if sum(sum(bwt == lab)) > maxx
            maxx = sum(sum(bwt == lab));
            index = lab;
        end
    end
	for lab = 1:tlabels
		if lab ~= index
			t(find(bwt == lab)) = 0;
		end
    end
   % imwrite(t,'maxfingafter.jpg');
    %figure,imshow(t);
    
    %subplot(1,3,3),imshow(t);
    %continue;
%	[bwt, tlabels] = bwlabel(t);
%	fprintf('Number of labels: %d\n', tlabels);
    
	ind = find(t == 255);
	if(numel(ind) == 0)
		fprintf('Could not find finger for frame %d\n', i);
		[oRows, oCols, colours] = size(outputFretboard);
		[fRows, fCols, colours] = size(origFrame);
		numCols = max([fCols, oCols]);
		outputFrame = 125*uint8(zeros(oRows + fRows + 90, numCols+200, 3));
		outputFrame(30:30+oRows-1, floor(numCols/2+100-oCols/2):floor(numCols/2+100-oCols/2)+oCols-1, :) = outputFretboard;
		outputFrame(60+oRows:60+oRows+fRows-1, floor(numCols/2+100-fCols/2):floor(numCols/2+100-fCols/2)+fCols-1, :) = origFrame;
		if writeFlag == 1
			imwrite(outputFrame, sprintf('%s/%s', outputFramesDirectory, fil(i).name), 'JPG');
		end
		continue;
	end

	[fingerX, fingerY] = ind2sub(size(t), ind);
	[fingerTopX, indMinX] = min(fingerX(:));
	fingerTopY = fingerY(indMinX);
	fprintf('fingerTopX = %d\tfingerTopY = %d\n', fingerTopX, fingerTopY);
    yCol = Bw(:, fingerTopY);
	if showFlag == 1
	
		temp = zeros(size(Bw));
		temp(:, fingerTopY) = Bw(:, fingerTopY);	
		%disp(transpose(Bw(floor(size(segImg, 1)/2):floor(3*size(segImg, 1)/4), fingerTopY)));
%		figure, imshow(temp);
		figure, imshow(Bw); hold on;
		plot(fingerTopY, fingerTopX, 'r*');
		hold off;
	end
	r1 = fingerTopX - min(find(yCol == 1));
	r2 = max(find(yCol == 1)) - fingerTopX;
	blength = r2+r1;
	r1 = r1 + 2/9*blength;
	r2 = r2 - 2/9*blength;
	fraction = r1/(r1 + r2);
	[minDist, pressedString] = min(abs(strings - fraction));
	if showFlag == 1
		fprintf('r1 = %f\n', r1);
		fprintf('r2 = %f\n', r2);
		fprintf('fraction = %f\n', fraction);
		disp(abs(strings - fraction));
	end

	% Now find the fret.
	shift = 0;
	nFret = 1;
    [bwp, plabels] = bwlabel(idealp);
    for plab = 1:plabels
        labInd = find(bwp == plab);
        [labX, labY] = ind2sub(size(bwp), labInd);
        if mean(labY(:)) > fingerTopY
            nFret = nFret + 1;
        end
    end
%	while shift <= size(p, 2) - fingerTopY
%		if p(fingerTopX, fingerTopY + shift) == 1
%			nFret = nFret + 1;
%			while p(fingerTopX, fingerTopY + shift) == 1
%				shift = shift + 1;
%			end
%		end
%		shift = shift + 1;
%	end

	fprintf('Frame %d: Fret = %d; String = %d\n', i, nFret, pressedString);
	modFretboard = outputFretboard;
	modFretboard(outStrings(pressedString) - 10:outStrings(pressedString) + 10, outFrets(nFret)-10:outFrets(nFret)+10, 1) = 0;
	modFretboard(outStrings(pressedString) - 10:outStrings(pressedString) + 10, outFrets(nFret)-10:outFrets(nFret)+10, 2) = 0;
	modFretboard(outStrings(pressedString) - 10:outStrings(pressedString) + 10, outFrets(nFret)-10:outFrets(nFret)+10, 3) = 255;

	[oRows, oCols, colours] = size(modFretboard);
	[fRows, fCols, colours] = size(origFrame);
	numCols = max([fCols, oCols]);
	outputFrame = 125*uint8(zeros(oRows + fRows + 90, numCols+200, 3));
	outputFrame(30:30+oRows-1, floor(numCols/2+100-oCols/2):floor(numCols/2+100-oCols/2)+oCols-1, :) = modFretboard;
	outputFrame(60+oRows:60+oRows+fRows-1, floor(numCols/2+100-fCols/2):floor(numCols/2+100-fCols/2)+fCols-1, :) = origFrame;
	%figure, imshow(outputFrame);
	if writeFlag == 1
		imwrite(outputFrame, sprintf('%s/%s', outputFramesDirectory, fil(i).name), 'JPG');
	end
	%subplot(1, 1, 1); imshow(outputFrame);
	%subplot(2, 1, 1); imshow(origFrame);

%	pause(2);
	if showFlag == 1
		FIg = figure(i);
		subplot(1,2,1),imshow(t);
		subplot(1,2,2),imshow(im);
	end
	%saveas(FIg,strcat('result4/',num2str(i),'.jpg'));
	%close all
end
end