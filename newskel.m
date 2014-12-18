function [newimg, flag, count] = newskel(img)
%img = imread('segmented.jpg');
[n,m] = size(img);
bw = logical(zeros(n,m));
ind = find(img > 100);
bw(ind) = 1;
%figure,imshow(bw);
change = 0;
max = 0;
i = n;
while i >= 1
    change = 0;
    [l,num ] = bwlabel(bw(i,10:end-10));
    if num > max
        max = num;
        lineno = i;
        
    end
    i = i- 1;
end
%figure,imshow(bw);
bw(1:lineno-n/8,:) = 0;
bw(lineno+n/8:end,:) = 0;
%imshow(bw);
Th = 200;
[l,num] = bwlabel(bw);
%y = zeros(num,1);

for i = 1:num
    th = find(l == i);
    [sizx,sizy] = size(th);
    [x,ty] = ind2sub(size(l),th);
    sum(x)/size(x,1);
     if sizx < Th
        bw(th) = 0;
     end
end
%figure,imshow(bw);
t = num - 24;
% for i = 1:t
%     th = find(l == i);
%     bw(th) = 0;
% end
%[l,num] = bwlabel(bw);
count = 0;
pdist = 0;
for i = num:-1:1
    th = find(l==i);
    if count >= 24
        bw(th) = 0;
        continue;
    end
    if i==num
        [x,y] = ind2sub(size(l),th);
        avgy = sum(y)/size(y,1);
        avgx = sum(x)/size(x,1);
    else
        [x,y] = ind2sub(size(l),th);
        tempy = sum(y)/size(y,1);
        tempx = sum(x)/size(x,1);
        dist = abs(avgy - tempy);
        if dist > pdist + 20 &  i < num/4
            bw(th) = 0;
        end
        if abs(avgx-tempx) > 50
            bw(th) = 0;
        else
            count = count+1;
            avgx = tempx;
        end
        dist;
        pdist;
        avgy =tempy;
        pdist = dist;
    end
end
count;
flag = 0;
if count==24
    imwrite(bw,'mask.jpg');
    flag = 1;
elseif count<24
    bw(:,:) = 0;
    temp = imread('mask.jpg');
    t = find(temp>100);
    bw(t) = 1;
    
end

%figure,imshow(bw);
newimg = bw;
end
