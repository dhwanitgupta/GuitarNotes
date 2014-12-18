function [out, theta] = getFrets(seg)
    THRESH = 100;
    
    strel = ones(10, 1);
    seg = imerode(seg, strel);
    figure, imshow(seg);
%    seg = imdilate(seg, [1 1 1 1; 1 1 1 1; 1 1 1 1]);
%    seg = imdilate(seg, strel);
%    figure, imshow(seg);
    [bwl, labels] = bwlabel(seg);
    
    fprintf('N  umber of labels: %d\n', labels);
    
    out = uint8(zeros(size(seg)));
    fretboard = uint8(zeros(size(seg)));
    
    minR = size(seg, 1);
    minC = size(seg, 2);
    minLabel = 0;
    
    validL = 0;
    theta = 0;
    
    for i = 1:labels
        ind = find(bwl == i);
        if size(ind, 1) >= THRESH
            validL = validL + 1;
            out(ind) = 255;
            [rind, cind] = ind2sub(size(seg), ind);
            [maxR, x] = max(rind);
            maxC = cind(x);
    
            [minR, x] = min(rind);
            minC = cind(x);
            theta = theta + atan((maxC - minC)/(maxR - minR));
    %        fprintf('angle = %f\n', atan((maxC - minC)/(maxR - minR)));
	    %fprintf('Updating at (%d, %d) and (%d, %d)\n', minR, minC, maxR, maxC);
            fretboard(minR, minC) = 255;
            fretboard(maxR, maxC) = 255;
	    %pause(1);
  %          theta = (theta*(validL - 1) + atan((maxC - minC)/(maxR - minR)))/validL;
        end
    end
    
    fprintf('validL = %d\n', validL);
    figure, imshow(fretboard);
    %figure, imshow(uint8(bwconvhull(logical(fretboard))));
    %figure, imshow(bwl == minLabel);
    %figure, imshow(bwmorph(bwl == minLabel, 'skel', 'inf'));
    fprintf('theta = %f degrees = %f radians\n', rad2deg(theta/validL), theta/validL);
end
